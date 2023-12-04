#pragma once
#include <iostream>
#include <mpi.h>

decltype(MPI_Wtime()) g_start;
void Tick() { g_start = MPI_Wtime(); }
void Tock() {
  auto end = MPI_Wtime();
  auto duration = end - g_start;
  std::cout << duration << std::endl;
}