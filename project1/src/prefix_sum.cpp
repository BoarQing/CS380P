#include "helpers.h"
#include "prefix_sum.h"
#include <cmath>
#include <cstring>
#include <mutex>

pthread_barrier_t g_barrier;
spin_barrier* g_spin_barrier;
int* g_node_val;

static int first_pass(int begin, int length, prefix_sum_args_t *arg) {
  int total = 0;
  int* input = arg->input_vals + begin;
  for (int i = 0; i < length; ++i) {
    total = arg->op(total, input[i], arg->n_loops);
  }
  return total;
}

static void enter_barrier(prefix_sum_args_t *arg) {
  if (arg->spin) {
    g_spin_barrier->enter(arg->t_id);
  } else {
    pthread_barrier_wait(&g_barrier);
  }
}

static int sync(prefix_sum_args_t *arg, int total) {
  g_node_val[arg->t_id] = total;
  enter_barrier(arg);
  // sync
  int cur_sum = 0;
  for (int i = 0; i < arg->t_id; i++) {
    cur_sum = op(cur_sum, g_node_val[i], arg->n_loops);
  }
  return cur_sum;
}

static void second_pass(int val, int begin, int length, prefix_sum_args_t *arg) {
  int *input = arg->input_vals + begin;
  int *output = arg->output_vals + begin;
  for (int i = 0; i < length; i++) {
    val = op(val, input[i], arg->n_loops);
    output[i] = val;
  }
}

void *compute_prefix(void *a) {
  prefix_sum_args_t *arg = (prefix_sum_args_t *)a;

  int length_per_thread = arg->n_vals / arg->n_threads;
  int remain = arg->n_vals % arg->n_threads;
  int length = length_per_thread + (arg->t_id < remain);
  if (length == 0) {
    enter_barrier(arg);
    return 0;
  }
  int begin = length_per_thread * arg->t_id + std::min(remain, arg->t_id);

  int sub_tree_total = first_pass(begin, length, arg);
  int val = sync(arg, sub_tree_total);
  second_pass(val, begin, length, arg);
  return 0;
}

void init(prefix_sum_args_t *arg)
{
  if (arg->spin) {
    g_spin_barrier = new spin_barrier(arg->n_threads);
  } else {
    pthread_barrier_init(&g_barrier, NULL, arg->n_threads);
  }
  g_node_val = (int*)malloc(sizeof(int) * arg->n_threads);
}

void clean_up(prefix_sum_args_t *arg)
{
  free(g_node_val);
  if (arg->spin) {
    delete(g_spin_barrier);
    g_spin_barrier = nullptr;
  } else {
    pthread_barrier_destroy(&g_barrier);
  }
}