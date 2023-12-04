#pragma once
#include "body.hpp"
#include <cstddef>

typedef struct {
  Body *body;
  size_t inputSize;
  char *outputfilename;
  int steps;
  double theta;
  double timestep;
  bool visualization;
} Argu;

Argu GetArgu(int argc, char **argv);