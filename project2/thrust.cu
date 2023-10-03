#include "util.hpp"
#include <thrust/copy.h>
#include <thrust/device_vector.h>
#include <thrust/execution_policy.h>
#include <thrust/host_vector.h>
#include <thrust/iterator/constant_iterator.h>
#include <thrust/reduce.h>
#include <thrust/sequence.h>
#include <thrust/sort.h>

struct Diff_Functor {
  double *input;
  double *centroid;
  int dim;
  int centroid_count;

  Diff_Functor(double *_input, double *_centroid, int _dim, int _centroid_count)
      : input(_input), centroid(_centroid), dim(_dim),
        centroid_count(_centroid_count) {}

  __device__ double operator()(int idx) const {
    int input_idx = idx / centroid_count;
    int centroid_idx = idx % centroid_count;
    double total_diff = 0;

    double *my_input = input + input_idx * dim;
    double *my_centroid = centroid + centroid_idx * dim;
    for (int i = 0; i < dim; i++) {
      double diff = my_centroid[i] - my_input[i];
      total_diff += diff * diff;
    }
    return total_diff;
  }
};

struct Idx_Functor {
  double *distance;
  int centroid_count;

  Idx_Functor(double *_distance, int _centroid_count)
      : distance(_distance), centroid_count(_centroid_count) {}

  __device__ int operator()(int idx) const {
    double *my_distance = distance + idx * centroid_count;
    int min_idx = 0;
    double min_distance = my_distance[0];
    for (int i = 1; i < centroid_count; i++) {
      if (my_distance[i] < min_distance) {
        min_distance = my_distance[i];
        min_idx = i;
      }
    }
    return min_idx;
  }
};

void FindNearestCentroid(Arg *arg, thrust::device_vector<double> &input,
                         thrust::device_vector<int> &label,
                         thrust::device_vector<double> &distance,
                         double *centroid_ptr, int iteration) {
  thrust::counting_iterator<int> diff_begin(0);
  thrust::counting_iterator<int> diff_end =
      diff_begin + arg->input_len * arg->num_cluster;
  double *input_ptr = thrust::raw_pointer_cast(input.data());
  thrust::transform(
      diff_begin, diff_end, distance.begin(),
      Diff_Functor(input_ptr, centroid_ptr, arg->dims, arg->num_cluster));
  thrust::counting_iterator<int> label_begin(0);
  thrust::counting_iterator<int> label_end = label_begin + arg->input_len;
  double *distance_ptr = thrust::raw_pointer_cast(distance.data());
  thrust::transform(label_begin, label_end, label.begin(),
                    Idx_Functor(distance_ptr, arg->num_cluster));
}

struct Label_Transform_Functor {
  int *label;
  int dim;

  Label_Transform_Functor(int *_label, int _dim) : label(_label), dim(_dim) {}

  __device__ int operator()(int idx) const {
    int my_idx = idx / dim;
    int my_dim = idx % dim;
    int my_label = label[my_idx];
    return my_label * dim + my_dim;
  }
};

struct Centroid_Transform_Functor {
  double *sum;
  int *count;
  int dim;

  Centroid_Transform_Functor(double *_sum, int *_count, int _dim)
      : sum(_sum), count(_count), dim(_dim) {}

  __device__ double operator()(int idx) const {
    int my_count = count[idx / dim];
    return sum[idx] / my_count;
  }
};

void AverageLabeledCentroids(Arg *arg,
                             const thrust::device_vector<double> &input,
                             thrust::device_vector<double> &sorted_input,
                             thrust::device_vector<int> &label,
                             thrust::device_vector<int> &sorted_label,
                             thrust::device_vector<double>::iterator centroid,
                             thrust::device_vector<double> &sum,
                             thrust::device_vector<double> &sum_key,
                             thrust::device_vector<int> &key,
                             thrust::device_vector<int> &count,
                             thrust::device_vector<int> &bykey) {

  thrust::counting_iterator<int> lbl_transform_begin(0);
  thrust::counting_iterator<int> lbl_transform_end =
      lbl_transform_begin + arg->input_len * arg->dims;
  int *label_ptr = thrust::raw_pointer_cast(label.data());

  thrust::transform(lbl_transform_begin, lbl_transform_end, bykey.begin(),
                    Label_Transform_Functor(label_ptr, arg->dims));
  thrust::copy(input.begin(), input.end(), sorted_input.begin());
  thrust::stable_sort_by_key(thrust::device, bykey.begin(), bykey.end(),
                             sorted_input.begin());
  thrust::reduce_by_key(bykey.begin(), bykey.end(), sorted_input.begin(),
                        sum_key.begin(), sum.begin());
  thrust::copy(label.begin(), label.end(), sorted_label.begin());
  thrust::stable_sort(sorted_label.begin(), sorted_label.end());
  thrust::constant_iterator<int> one(1);
  thrust::reduce_by_key(sorted_label.begin(), sorted_label.end(), one, key.begin(),
                        count.begin());

  thrust::counting_iterator<int> centroid_begin(0);
  thrust::counting_iterator<int> centroid_end =
      lbl_transform_begin + arg->num_cluster * arg->dims;
  double *sum_ptr = thrust::raw_pointer_cast(sum.data());
  int *count_ptr = thrust::raw_pointer_cast(count.data());
  thrust::transform(centroid_begin, centroid_end, centroid,
                    Centroid_Transform_Functor(sum_ptr, count_ptr, arg->dims));
}

struct LogicalAnd {
  __device__ bool operator()(const bool &a, const bool &b) { return a && b; }
};

struct Converge_Functor {
  double *ptr1;
  double *ptr2;
  int dim;
  double threshold;

  Converge_Functor(double *_ptr1, double *_ptr2, int _dim, double _threshold)
      : ptr1(_ptr1), ptr2(_ptr2), dim(_dim), threshold(_threshold) {}

  __device__ bool operator()(int idx) const {
    double *my_ptr1 = ptr1 + idx * dim;
    double *my_ptr2 = ptr2 + idx * dim;
    double total_diff = 0.0;
    for (int i = 0; i < dim; i++) {
      double diff = my_ptr1[i] - my_ptr2[i];
      total_diff += diff * diff;
    }
    return total_diff < threshold;
  }
};

bool Converge(Arg *arg, thrust::device_vector<bool> &converge,
              thrust::device_vector<double> &centroid) {
  thrust::counting_iterator<int> partial_begin(0);
  thrust::counting_iterator<int> partial_end = partial_begin + arg->num_cluster;
  double *ptr1 = thrust::raw_pointer_cast(centroid.data());
  double *ptr2 = ptr1 + arg->dims * arg->num_cluster;
  thrust::transform(partial_begin, partial_end, converge.begin(),
                    Converge_Functor(ptr1, ptr2, arg->dims, arg->threshold));
  return thrust::reduce(converge.begin(), converge.end(), true, LogicalAnd());
}

KMeans_Ret KMeans(Arg *arg) {
  double *centroid = GetRandomCentroid(arg);

  int iteration = 0;
  bool done = false;

  int input_total = arg->input_len * arg->dims;
  thrust::device_vector<double> device_input(input_total);
  thrust::copy(arg->input, arg->input + input_total, device_input.begin());
  thrust::device_vector<double> sorted_device_input(input_total);

  size_t label_size = sizeof(int) * arg->input_len;
  int *label = (int *)malloc(label_size);

  int centroid_count = arg->dims * arg->num_cluster;
  thrust::device_vector<double> device_centroid(centroid_count * 2);
  thrust::copy(centroid, centroid + centroid_count, device_centroid.begin());

  thrust::device_vector<int> device_label(arg->input_len);
  thrust::device_vector<int> sorted_device_label(arg->input_len);
  int distance_count = arg->input_len * arg->num_cluster;
  thrust::device_vector<double> device_distance(distance_count);
  thrust::device_vector<bool> device_converge(arg->num_cluster);

  thrust::device_vector<double> device_sum(arg->dims * arg->num_cluster);
  thrust::device_vector<double> device_sum_key(arg->dims * arg->num_cluster);
  thrust::device_vector<int> device_key(arg->num_cluster);
  thrust::device_vector<int> device_count(arg->num_cluster);
  thrust::device_vector<int> device_bykey(arg->input_len * arg->dims);
  thrust::device_vector<double>::iterator new_centroid_iter;
  TICK();
  while (!done) {
    double *old_centroid_ptr =
        thrust::raw_pointer_cast(device_centroid.data()) +
        centroid_count * (iteration % 2);
    new_centroid_iter =
        device_centroid.begin() + centroid_count * ((iteration + 1) % 2);
    FindNearestCentroid(arg, device_input, device_label, device_distance,
                        old_centroid_ptr, iteration);
    AverageLabeledCentroids(
        arg, device_input, sorted_device_input, device_label, sorted_device_label, new_centroid_iter,
        device_sum, device_sum_key, device_key, device_count, device_bykey);

    bool converged = Converge(arg, device_converge, device_centroid);
    ++iteration;
    done = iteration >= arg->max_num_iter || converged;
  }
  TOCK(iteration);
  thrust::copy(device_label.begin(), device_label.end(), label);
  thrust::copy(new_centroid_iter, new_centroid_iter + centroid_count, centroid);
  return KMeans_Ret{centroid, label};
}

int main(int argc, char *argv[]) {
  Arg arg = GetArg(argc, argv);
  KMeans_Ret ret = KMeans(&arg);
  if (arg.control_flag) {
    PrintCentroid(&arg, ret.centroid);
  } else {
    PrintLabel(&arg, ret.label);
  }
  free(ret.centroid);
  free(ret.label);
  FreeArg(&arg);
  return 0;
}