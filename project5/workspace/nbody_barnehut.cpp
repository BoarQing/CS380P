#include "argc.hpp"
#include "timing.hpp"
#include "universe.hpp"
#include <mpi.h>
int main(int argc, char **argv) {
  MPI_Init(&argc, &argv);
  Argu argu = GetArgu(argc, argv);
  Tick();
  Universe universe = Universe(&argu);
  universe.SequentialBarneHutSimulation();
  Tock();
  universe.DumpResult(argu.outputfilename);
  MPI_Finalize();
  return 0;
}
