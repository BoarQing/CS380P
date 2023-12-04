#pragma once
#include "argc.hpp"
#include "body.hpp"
#if defined(BARNEHUT) || defined(BARNEHUT_PARALLEL)
#include "quad_tree.hpp"
#endif
#include <string>
#include <vector>

#ifdef BARNEHUT_PARALLEL
typedef struct {
  double x;
  double y;
  double mass;
  int nodeIdx;
} ForceCalcSend;

typedef struct {
  double fx;
  double fy;
} ForceCalcReceive;

typedef struct {
  double fx;
  double fy;
  bool nextUpdated;
  int msgNeed;
} ForceResult;
#endif

class Universe {
public:
  Universe(const Argu *const argu);
  ~Universe();
  void DumpResult(const char *filename);

#ifdef NAIVE
  void SequentialNaiveSimulation();
  void SequentialNaiveSimulationOneParticle(size_t idx);
#endif
#ifdef BARNEHUT
  void SequentialBarneHutSimulation();
#endif
#ifdef BARNEHUT_PARALLEL
  void ParallelInit(int myID, int procCount);
  void BarneHutSimulation();
#endif

private:
#ifdef BARNEHUT
  void SequentialBarneHutTreeConstruction();
  void SequentialBarneHutSimulationOneParticle(size_t idx);
  void SequentialBarneHutForceApply();
#endif
#ifdef BARNEHUT_PARALLEL
  void RedistributeParticleSend();
  void RedistributeParticleRecv();
  void Redistribute();
  void PartialTreeConstruction();
  void SendMyPartialTree();
  void ReceivePartialForceRequest();
  void FullTreeConstruction();
  void ApplyPartialForce();
  void ApplyPartialForceOneParticle(size_t idx);
  void ApplyPartialForceOneParticleOnShared(size_t idx, const Node *node,
                                            int level);
  void QueueMsg(int idx, int nodeIdx);
  void SendPartialForce();
  void ApplyFullForce();
  void CombineForce(const ForceCalcReceive *receive, int idx);
  void CheckOutOfProcRange(int idx);
  void SyncBack();

  void InitWorkPartition();
  void GetBodyInRange();
  void AllocBuffer();
#endif
  void UpdateBodyState(const Body *in, Body *out, double totalFx,
                       double totalFy);
  void UpdateBody(const Argu *const argu);
  void UpdateConstant(const Argu *const argu);

  Body *body_;
  Body *nextBody_;
  size_t size_;
#ifdef BARNEHUT
  NodeMgr *mgr_;
  Node root_;
#endif
#ifdef BARNEHUT_PARALLEL

  int myID_;
  int procCount_;

  int totalSection_;
  int sectionPerProc_;
  int sectionPerDirection_;
  double lengthPerSection_;

  int sharedNodeCount_;
  int sharedLevel_;

  int syncIdx_;

  NodeMgr *mgr_;
  Node *root_;
  std::vector<std::vector<ForceCalcSend>> toBeSent_;
  std::vector<std::vector<int>> nodeCalcIdx_;
  std::vector<std::vector<Body>> bodyToBeSent_;
  ForceCalcSend *requestBuffer_;
  ForceCalcReceive *resultBuffer_;
  ForceResult *tmpResult_;

  int *removeIdx_;
  int removeSize_;
  std::vector<std::vector<Body>> redistributeBuffer_;
  Body *bodyBuffer_;
  int bodySize_;

#endif
  int steps_;
  double theta_;
  double dt_;
  double dt2_;
};