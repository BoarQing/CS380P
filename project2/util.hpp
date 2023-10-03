#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <ctime>
#include <unistd.h>

typedef struct {
  int num_cluster;
  int dims;
  char *inputfilename;
  double *input;
  int input_len;
  int max_num_iter;
  double threshold;
  int seed;
  bool control_flag;
} Arg;

#define UNUSED(x) [&x] {}()

static void ReadInputFile(Arg *arg) {
  FILE *file = fopen(arg->inputfilename, "r");
  int ret = fscanf(file, "%d", &arg->input_len);
  arg->input = (double *)malloc(arg->input_len * arg->dims * sizeof(double));
  int index = 0;
  for (int i = 0; i < arg->input_len; i++) {
    int row;
    ret = fscanf(file, "%d", &row);
    for (int j = 0; j < arg->dims; j++) {
      ret = fscanf(file, "%lf", &arg->input[index]);
      ++index;
    }
  }
  UNUSED(ret);
  fclose(file);
}

Arg GetArg(int argc, char *argv[]) {
  Arg ret = {};
  int option;
  while ((option = getopt(argc, argv, "k:d:i:m:t:cs:")) != -1) {
    switch (option) {
    case 'k':
      ret.num_cluster = atoi(optarg);
      break;
    case 'd':
      ret.dims = atoi(optarg);
      break;
    case 'i':
      ret.inputfilename = optarg;
      break;
    case 'm':
      ret.max_num_iter = atoi(optarg);
      break;
    case 't':
      ret.threshold = atof(optarg);
      break;
    case 'c':
      ret.control_flag = true;
      break;
    case 's':
      ret.seed = atoi(optarg);
      break;
    default:
      printf("invalid option: %c", option);
      exit(1);
    }
  }
  ReadInputFile(&ret);
  return ret;
}

inline void FreeArg(Arg *arg) { free(arg->input); }

static unsigned long int next = 1;
static unsigned long kmeans_rmax = 32767;

inline int kmeans_rand() {
  next = next * 1103515245 + 12345;
  return (unsigned int)(next / 65536) % (kmeans_rmax + 1);
}

inline void kmeans_srand(unsigned int seed) { next = seed; }

double *GetRandomCentroid(Arg *arg) {
  size_t single_element_size = sizeof(double) * arg->dims;
  double *centroid = (double *)malloc(arg->num_cluster * single_element_size);
  kmeans_srand(arg->seed);
  for (int i = 0; i < arg->num_cluster; i++) {
    int idx = kmeans_rand() % arg->input_len;
    memcpy(centroid + i * arg->dims, &(arg->input[idx * arg->dims]),
           single_element_size);
  }
  return centroid;
}

void PrintCentroid(Arg *arg, double *centroid) {
  for (int c = 0; c < arg->num_cluster; c++) {
    printf("%d ", c);
    for (int d = 0; d < arg->dims; d++) {
      printf("%lf ", *centroid);
      ++centroid;
    }
    printf("\n");
  }
}

void PrintLabel(Arg *arg, int *label) {
  printf("clusters:");
  for (int p = 0; p < arg->input_len; p++) {
    printf(" %d", label[p]);
  }
}

clock_t g_start_time;

inline void TICK() { g_start_time = clock(); };

inline void TOCK(int iteration) {
  clock_t end_time = clock();
  double time_elapse =
      (double)(end_time - g_start_time) / CLOCKS_PER_SEC * 1000.0;
  printf("%d,%lf\n", iteration, time_elapse / iteration);
}

typedef struct {
  double *centroid;
  int *label;
} KMeans_Ret;
