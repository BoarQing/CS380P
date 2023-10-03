#include "util.hpp"
#include <cfloat>
#include <cuda_runtime.h>

#define DIFF_TIME 4
__global__ void ComputeCentroidDiff(int input_len, int dim, int centroid_count,
                                    double *input, int *label, double *centroid,
                                    double *distance) {
  int input_index = blockIdx.x * DIFF_TIME + threadIdx.x / centroid_count;
  int centroid_index = threadIdx.x % centroid_count;

  if (input_index < input_len) {
    double *my_input = input + input_index * dim;
    double *my_centroid = centroid + centroid_index * dim;
    double total_diff = 0.0;
    for (int i = 0; i < dim; ++i) {
      double diff = my_input[i] - my_centroid[i];
      total_diff += diff * diff;
    }
    *(distance + input_index * centroid_count + centroid_index) = total_diff;
  }
}

#define THREAD_COUNT 64
__global__ void FindNearestCentroid(int input_len, int centroid_count,
                                    double *distance, int *label) {
  int idx = blockIdx.x * THREAD_COUNT + threadIdx.x;
  if (idx < input_len) {
    double *my_distance = distance + idx * centroid_count;
    double min_dis = my_distance[0];
    double min_idx = 0;
    for (int i = 1; i < centroid_count; ++i) {
      if (my_distance[i] < min_dis) {
        min_dis = my_distance[i];
        min_idx = i;
      }
    }
    label[idx] = min_idx;
  }
}

#define REDUCE_COUNT 32
__global__ void ReducedPartialAvgLabel(int input_len, int dim,
                                       int centroid_count, double *input,
                                       int *label, double *centroid,
                                       int *count) {
  int each_work_load = input_len / REDUCE_COUNT;
  int beg = blockIdx.x * each_work_load;
  int end = beg + each_work_load;
  if (input_len - end < each_work_load) {
    end = input_len;
  }
  int *my_count = count + blockIdx.x * centroid_count;
  double *my_centroid =
      centroid + blockIdx.x * dim * centroid_count + threadIdx.x;
  double *my_input = input + beg * dim + threadIdx.x;

  for (int i = beg; i < end; ++i) {
    int my_label = label[i];
    double *currrent_centroid = my_centroid + my_label * dim;
    *currrent_centroid += *my_input;
    my_input += dim;
    if (threadIdx.x == 0) {
      ++my_count[my_label];
    }
  }
}

__global__ void ReducedAvgLabel(int dim, int centroid_count, int *reduce_count,
                                double *reduce_centroid, double *centroid) {
  double sum = 0.0;
  int count = 0;
  double *out_centroid = centroid + blockIdx.x * dim + threadIdx.x;
  double *my_centroid = reduce_centroid + blockIdx.x * dim + threadIdx.x;
  int *my_count = reduce_count + blockIdx.x;

  for (int i = 0; i < REDUCE_COUNT; i++) {
    sum += *my_centroid;
    count += *my_count;
    my_centroid += centroid_count * dim;
    my_count += centroid_count;
  }
  *out_centroid = sum / count;
}

__global__ void Converge(int dim, double threshold, bool *converge, double *c1,
                         double *c2) {
  double *my_c1 = c1 + blockIdx.x * dim;
  double *my_c2 = c2 + blockIdx.x * dim;
  double total_diff = 0.0;
  for (int i = 0; i < dim; i++) {
    double diff = my_c1[i] - my_c2[i];
    total_diff += diff * diff;
  }
  converge[blockIdx.x] = total_diff < threshold;
}

bool IsConverged(int centroid_count, bool *converge) {
  for (int i = 0; i < centroid_count; i++) {
    if (converge[i] == false) {
      return false;
    }
  }
  return true;
}

KMeans_Ret KMeans(Arg *arg) {
  double *centroid = GetRandomCentroid(arg);
  int block_count = int(ceil((double)arg->input_len / THREAD_COUNT));
  int diff_count = int(ceil((double)arg->input_len / DIFF_TIME));
  int iteration = 0;
  bool done = false;
  double *device_centroid;
  size_t input_size = arg->dims * arg->input_len * sizeof(double);
  double *device_input;
  cudaMalloc(&device_input, input_size);
  cudaMemcpyAsync(device_input, arg->input, input_size, cudaMemcpyHostToDevice);
  size_t centroid_size = sizeof(double) * arg->dims * arg->num_cluster;
  cudaMalloc(&device_centroid, centroid_size * 2);
  cudaMemcpyAsync(device_centroid, centroid, centroid_size,
                  cudaMemcpyHostToDevice);
  size_t label_size = sizeof(int) * arg->input_len;
  int *label = (int *)malloc(label_size);
  int *device_label;
  cudaMalloc(&device_label, label_size);
  size_t distance_size = sizeof(double) * arg->input_len * arg->num_cluster;
  double *device_distance;
  cudaMalloc(&device_distance, distance_size);
  size_t converge_size = sizeof(bool) * arg->num_cluster;
  bool *device_converge;
  bool *converge = (bool *)malloc(converge_size);
  cudaMalloc(&device_converge, converge_size);
  int *reduce_count;
  size_t reduce_count_size = sizeof(int) * arg->num_cluster * REDUCE_COUNT;
  cudaMalloc(&reduce_count, reduce_count_size);
  double *reduce_centroid;
  size_t reduce_centroid_size =
      sizeof(double) * arg->num_cluster * arg->dims * REDUCE_COUNT;
  cudaMalloc(&reduce_centroid, reduce_centroid_size);
  cudaDeviceSynchronize(); // for async
  double *new_centroid = nullptr;
  TICK();
  while (!done) {
    double *old_centroid =
        device_centroid + arg->dims * arg->num_cluster * (iteration % 2);
    new_centroid =
        device_centroid + arg->dims * arg->num_cluster * ((iteration + 1) % 2);

    ComputeCentroidDiff<<<diff_count, arg->num_cluster * DIFF_TIME>>>(
        arg->input_len, arg->dims, arg->num_cluster, device_input, device_label,
        old_centroid, device_distance);
    FindNearestCentroid<<<block_count, THREAD_COUNT>>>(
        arg->input_len, arg->num_cluster, device_distance, device_label);
    cudaMemset(reduce_count, 0, reduce_count_size);
    cudaMemset(reduce_centroid, 0, reduce_centroid_size);
    ReducedPartialAvgLabel<<<REDUCE_COUNT, arg->dims>>>(
        arg->input_len, arg->dims, arg->num_cluster, device_input, device_label,
        reduce_centroid, reduce_count);
    ReducedAvgLabel<<<arg->num_cluster, arg->dims>>>(
        arg->dims, arg->num_cluster, reduce_count, reduce_centroid,
        new_centroid);
    Converge<<<arg->num_cluster, 1>>>(
        arg->dims, arg->threshold, device_converge, old_centroid, new_centroid);
    cudaMemcpy(converge, device_converge, converge_size,
               cudaMemcpyDeviceToHost);
    bool converged = IsConverged(arg->num_cluster, converge);
    ++iteration;
    done = iteration >= arg->max_num_iter || converged;
  }
  TOCK(iteration);
  cudaMemcpyAsync(label, device_label, label_size, cudaMemcpyDeviceToHost);
  cudaMemcpyAsync(centroid, new_centroid, centroid_size,
                  cudaMemcpyDeviceToHost);
  cudaDeviceSynchronize(); // must finish before free!
  cudaFree(device_distance);
  cudaFree(device_input);
  cudaFree(device_centroid);
  cudaFree(device_label);
  cudaFree(device_converge);
  cudaFree(reduce_centroid);
  cudaFree(reduce_count);
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