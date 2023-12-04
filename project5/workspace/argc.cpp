#include "argc.hpp"
#include <fstream>
#include <getopt.h>
#include <iostream>
#include <unistd.h>

static void ReadFile(Argu *argu, char *filename) {
  std::ifstream file;
  file.open(filename);
  file >> argu->inputSize;
  argu->body = static_cast<Body *>(malloc(sizeof(Body) * argu->inputSize));
  for (size_t i = 0; i < argu->inputSize; ++i) {
    file >> argu->body[i].index;
    file >> argu->body[i].xPos;
    file >> argu->body[i].yPos;
    file >> argu->body[i].mass;
    file >> argu->body[i].xVel;
    file >> argu->body[i].yVel;
  }
}

Argu GetArgu(int argc, char **argv) {
  Argu ret;

  int opt;
  while ((opt = getopt(argc, argv, "i:o:s:t:d:V")) != -1) {
    switch (opt) {
    case 'i':
      ReadFile(&ret, optarg);
      break;
    case 'o':
      ret.outputfilename = optarg;
      break;
    case 's':
      ret.steps = atoi(optarg);
      break;
    case 't':
      ret.theta = atof(optarg);
      break;
    case 'd':
      ret.timestep = atof(optarg);
      break;
    case 'V':
      ret.visualization = true;
      break;
    default:
      exit(0);
    }
  }
  return ret;
}