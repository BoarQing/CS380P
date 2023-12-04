#include "argc.hpp"
#include "const.hpp"
#include "timing.hpp"
#include "universe.hpp"
#include <mpi.h>

static Argu GetChildArguCopy(const Argu *argu) {
  Argu ret = *argu;
  ret.body = nullptr;
  return ret;
}

static int GetMaxParallelCount(int procCount) {
  int ret = 1;
  while (ret * MaxSectionPerProc <= procCount) {
    ret *= MaxSectionPerProc;
  }
  return ret;
}

int main(int argc, char **argv) {
  MPI_Init(&argc, &argv);
  int myID, procCount;
  Universe *u = nullptr;
  Argu argu;
  MPI_Comm_size(MPI_COMM_WORLD, &procCount);
  MPI_Comm_rank(MPI_COMM_WORLD, &myID);

  procCount = GetMaxParallelCount(procCount);
  if (myID >= procCount) {
    goto terminate;
  }
  // set up
  argu = GetArgu(argc, argv);
  u = new Universe(&argu);
  u->ParallelInit(myID, procCount);
  // begin
  if (myID == Root) {
    Tick();
  }
  u->BarneHutSimulation();
  if (myID == Root) {
    Tock();
    u->DumpResult(argu.outputfilename);
  }
  // end
  delete (u);
terminate:
  MPI_Finalize();
  return 0;
}
