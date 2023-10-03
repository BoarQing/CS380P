#include "util.hpp"
#include <cfloat>

bool Converge(Arg *arg, double *centroid_a, double *centroid_b) {
  for (int i = 0; i < arg->num_cluster; i++) {
    double *pa = centroid_a + i * arg->dims;
    double *pb = centroid_b + i * arg->dims;
    double total_diff = 0.0;
    for (int j = 0; j < arg->dims; j++) {
      double diff = pa[j] - pb[j];
      total_diff += diff * diff;
    }
    if (total_diff >= arg->threshold) {
      return false;
    }
  }
  return true;
}

void FindNearestCentroid(Arg *arg, int *label, double *centroid) {
  for (int i = 0; i < arg->input_len; ++i) {
    int min_idx = -1;
    double min_distance = FLT_MAX;
    double *cur_value = arg->input + arg->dims * i;
    for (int j = 0; j < arg->num_cluster; ++j) {
      double distance = 0.0;
      double *cur_centroid = centroid + arg->dims * j;
      for (int k = 0; k < arg->dims; ++k) {
        double diff = cur_value[k] - cur_centroid[k];
        distance += diff * diff;
      }
      if (distance < min_distance) {
        min_idx = j;
        min_distance = distance;
      }
    }
    label[i] = min_idx;
  }
}

void AverageLabeledCentroids(Arg *arg, int *label, double *centroid,
                             int *label_count) {
  memset(label_count, 0, arg->num_cluster * sizeof(int));
  memset(centroid, 0, (sizeof(double) * arg->dims * arg->num_cluster));
  for (int i = 0; i < arg->input_len; i++) {
    double *cur_value = arg->input + arg->dims * i;
    int cur_label = label[i];
    double *cur_centroid = centroid + arg->dims * cur_label;
    ++label_count[cur_label];
    for (int j = 0; j < arg->dims; ++j) {
      cur_centroid[j] += cur_value[j];
    }
  }
  for (int i = 0; i < arg->num_cluster; i++) {
    double *cur_centroid = centroid + arg->dims * i;
    if (label_count[i] == 0) {
      continue;
    }
    double count = label_count[i];
    for (int j = 0; j < arg->dims; ++j) {
      cur_centroid[j] /= count;
    }
  }
}

KMeans_Ret KMeans(Arg *arg) {
  double *rand_centroid = GetRandomCentroid(arg);
  int iteration = 0;
  bool done = false;
  double *tmp_centroid =
      (double *)malloc(sizeof(double) * arg->dims * arg->num_cluster);
  double *centroid_frame[2] = {rand_centroid, tmp_centroid};
  int *label = (int *)malloc(arg->input_len * sizeof(int));
  int *label_count = (int *)malloc(arg->num_cluster * sizeof(int));
  TICK();
  while (!done) {
    FindNearestCentroid(arg, label, centroid_frame[iteration % 2]);
    AverageLabeledCentroids(arg, label, centroid_frame[(iteration + 1) % 2],
                            label_count);
    bool converged = Converge(arg, centroid_frame[0], centroid_frame[1]);
    ++iteration;
    done = iteration >= arg->max_num_iter || converged;
  }
  TOCK(iteration);
  free(label_count);
  free(centroid_frame[(iteration + 1) % 2]);
  return KMeans_Ret{centroid_frame[iteration % 2], label};
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