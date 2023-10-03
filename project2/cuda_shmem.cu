#include "util.hpp"
#include <cfloat>
#include <cuda_runtime.h>

typedef struct {
  double diff;
  int idx;
} Diff_Info;

#define REDUCE_COUNT 32
__global__ void ReducedFindNearestCentroid(int input_len, int dim,
                                           int centroid_count, double *input,
                                           double *centroid, int *label) {
  extern __shared__ Diff_Info share_diff[];
  double *my_centroid = centroid + dim * threadIdx.x;
  double *my_input = input + blockIdx.x * dim;
  double total_diff = 0.0;
  if (threadIdx.x < centroid_count) {
    for (int i = 0; i < dim; ++i) {
      double diff = my_input[i] - my_centroid[i];
      total_diff += diff * diff;
    }
  } else {
    total_diff = FLT_MAX;
  }
  share_diff[threadIdx.x].diff = total_diff;
  share_diff[threadIdx.x].idx = threadIdx.x;
  __syncthreads();
  for (int s = blockDim.x / 2; s > 0; s >>= 1) {
    int next = threadIdx.x + s;
    if (threadIdx.x < s) {
      if (share_diff[threadIdx.x].diff > share_diff[next].diff) {
        share_diff[threadIdx.x].diff = share_diff[next].diff;
        share_diff[threadIdx.x].idx = share_diff[next].idx;
      }
    }
    __syncthreads();
  }
  if (threadIdx.x == 0) {
    label[blockIdx.x] = share_diff[0].idx;
  }
}

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

int GetRoundUpValue(int x) {
  int base = 1;
  while (base < x) {
    base *= 2;
  }
  return base;
}

KMeans_Ret KMeans(Arg *arg) {
  double *centroid = GetRandomCentroid(arg);
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
  int round_up_centroid_count = GetRoundUpValue(arg->num_cluster);
  double *new_centroid = nullptr;
  TICK();
  while (!done) {
    double *old_centroid =
        device_centroid + arg->dims * arg->num_cluster * (iteration % 2);
    new_centroid =
        device_centroid + arg->dims * arg->num_cluster * ((iteration + 1) % 2);
    ReducedFindNearestCentroid<<<arg->input_len, round_up_centroid_count,
                                 round_up_centroid_count * sizeof(Diff_Info)>>>(
        arg->input_len, arg->dims, arg->num_cluster, device_input, old_centroid,
        device_label);
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