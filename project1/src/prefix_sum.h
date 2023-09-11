#pragma once

#include <stdlib.h>
#include <pthread.h>
#include <spin_barrier.h>
#include <iostream>

struct prefix_sum_args_t;
void* compute_prefix(void* a);
void init(prefix_sum_args_t* arg);
void clean_up(prefix_sum_args_t* arg);