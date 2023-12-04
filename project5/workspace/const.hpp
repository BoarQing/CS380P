#pragma once
#include <algorithm>

typedef struct {
  double x;
  double y;
  double length;
} Range;

constexpr double MaxRangeLength = 4.0;
constexpr Range maxRange = {MaxRangeLength / 2, MaxRangeLength / 2,
                            MaxRangeLength / 2};
constexpr double G = 0.0001;
constexpr double rlimit = 0.03;
constexpr double invalidWeight = -1.0;

#ifdef BARNEHUT_PARALLEL
constexpr int Root = 0;
constexpr int Tag = 0;
constexpr int MaxSectionPerProc = 2;
constexpr int MaxRecvCount = 1024;
#endif
