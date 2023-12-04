#include "universe.hpp"
#include "const.hpp"
#include <algorithm>
#include <cmath>
#include <cstdlib>
#include <fstream>
#include <iostream>
#include <string.h>
#ifdef BARNEHUT_PARALLEL
#include <mpi.h>
#endif

static bool IsOutOfRange(const Body *body) {
  return std::abs(maxRange.x - body->xPos) >= maxRange.length ||
         std::abs(maxRange.y - body->yPos) >= maxRange.length;
}

static void CalculateGForce(const Body *me, double xPos, double yPos,
                            double mass, double *totalFx, double *totalFy) {
  double dx = xPos - me->xPos;
  double dy = yPos - me->yPos;

  double d = std::sqrt((dx * dx + dy * dy));
  d = std::max(d, rlimit);

  double d3 = d * d * d;
  double fx = G * me->mass * mass * dx / d3;
  double fy = G * me->mass * mass * dy / d3;

  *totalFx += fx;
  *totalFy += fy;
}

void Universe::UpdateBodyState(const Body *in, Body *out, double totalFx,
                               double totalFy) {
  double ax = totalFx / in->mass;
  double ay = totalFy / in->mass;
  out->xPos = in->xPos + in->xVel * dt_ + 0.5 * ax * dt2_;
  out->yPos = in->yPos + in->yVel * dt_ + 0.5 * ay * dt2_;
  out->xVel = in->xVel + ax * dt_;
  out->yVel = in->yVel + ay * dt_;

  if (IsOutOfRange(out)) {
    out->mass = invalidWeight;
  }
}

Universe::Universe(const Argu *const argu) {
  UpdateBody(argu);
  UpdateConstant(argu);
#if defined(BARNEHUT) || defined(BARNEHUT_PARALLEL)
  mgr_ = new NodeMgr(size_);
#endif
#ifdef BARNEHUT_PARALLEL
  tmpResult_ = static_cast<ForceResult *>(malloc(sizeof(ForceResult) * size_));
  bodyBuffer_ = static_cast<Body *>(malloc(sizeof(Body) * size_));
  removeIdx_ = static_cast<int *>(malloc(sizeof(int) * size_));
#endif
}

Universe::~Universe() {
  free(body_);
  free(nextBody_);
#if defined(BARNEHUT) || defined(BARNEHUT_PARALLEL)
  delete (mgr_);
#endif
#if defined(BARNEHUT_PARALLEL)
  delete (root_);
  delete (resultBuffer_);
  delete (requestBuffer_);
  delete (tmpResult_);
  delete (bodyBuffer_);
  delete (removeIdx_);
#endif
}

void Universe::UpdateBody(const Argu *const argu) {
  size_ = argu->inputSize;
  body_ = argu->body;
  nextBody_ = static_cast<Body *>(malloc(sizeof(Body) * size_));
  for (size_t i = 0; i < size_; ++i) {
    nextBody_[i] = body_[i];
  }
}

void Universe::UpdateConstant(const Argu *const argu) {
  steps_ = argu->steps;
  theta_ = argu->theta;
  dt_ = argu->timestep;
  dt2_ = dt_ * dt_;
}

void Universe::DumpResult(const char *filename) {
  std::ofstream file(filename);
  file << size_ << std::endl;
  for (size_t i = 0; i < size_; ++i) {
    const Body &b = body_[i];
    file << b.index << " ";
    file << b.xPos << " ";
    file << b.yPos << " ";
    file << b.mass << " ";
    file << b.xVel << " ";
    file << b.yVel << std::endl;
  }
  file.close();
}

#ifdef NAIVE
void Universe::SequentialNaiveSimulationOneParticle(size_t idx) {
  if (body_[idx].mass == invalidWeight) {
    nextBody_[idx] = body_[idx];
    return;
  }
  double totalFx = 0.0;
  double totalFy = 0.0;
  for (size_t i = 0; i < size_; ++i) {
    if (body_[i].mass == invalidWeight) {
      continue;
    }
    CalculateGForce(&(body_[idx]), body_[i].xPos, body_[i].yPos, body_[i].mass,
                    &totalFx, &totalFy);
  }
  UpdateBodyState(&(body_[idx]), &(nextBody_[idx]), totalFx, totalFy);
}

void Universe::SequentialNaiveSimulation() {
  for (int i = 0; i < steps_; ++i) {
    for (size_t j = 0; j < size_; ++j) {
      SequentialNaiveSimulationOneParticle(j);
    }
    std::swap(body_, nextBody_);
  }
}
#endif

#if defined(BARNEHUT) || defined(BARNEHUT_PARALLEL)
static bool IsSingleBody(const Node *node, const Body *body, double theta) {
  const Body *combinedBody = &(node->body);
  double dx = combinedBody->xPos - body->xPos;
  double dy = combinedBody->yPos - body->yPos;
  double d = std::sqrt(dx * dx + dy * dy);
  double s = node->range.length * 2;
  return s / d <= theta;
}

static void BarneHutSumForceOneParticle(const Body *body, const Node *root,
                                        double theta, double *fx, double *fy) {
  if (!root->hasChild || IsSingleBody(root, body, theta)) {
    CalculateGForce(body, root->body.xPos, root->body.yPos, root->body.mass, fx,
                    fy);
  } else {
    for (int i = 0; i < SUBTREE_COUNT; ++i) {
      const Node *child = GetChild(root, i);
      if (!child) {
        continue;
      }
      BarneHutSumForceOneParticle(body, child, theta, fx, fy);
    }
  }
}
#endif

#ifdef BARNEHUT
void Universe::SequentialBarneHutTreeConstruction() {
  memset(&root_, 0, sizeof(root_));
  mgr_->Clean();
  bool rootInited = false;
  for (size_t i = 0; i < size_; ++i) {
    if (body_[i].mass == invalidWeight) {
      continue;
    }
    if (!rootInited) {
      SetAsRoot(&root_, &(body_[i]));
      rootInited = true;
    } else {
      AddNodeToTree(&root_, &(body_[i]), mgr_);
    }
  }
}

void Universe::SequentialBarneHutSimulationOneParticle(size_t idx) {
  if (body_[idx].mass == invalidWeight) {
    nextBody_[idx] = body_[idx];
    return;
  }
  double totalFx = 0.0;
  double totalFy = 0.0;
  BarneHutSumForceOneParticle(&(body_[idx]), &root_, theta_, &totalFx,
                              &totalFy);
  UpdateBodyState(&(body_[idx]), &(nextBody_[idx]), totalFx, totalFy);
}

void Universe::SequentialBarneHutForceApply() {
  for (size_t i = 0; i < size_; ++i) {
    SequentialBarneHutSimulationOneParticle(i);
  }
}
void Universe::SequentialBarneHutSimulation() {
  for (int i = 0; i < steps_; ++i) {
    SequentialBarneHutTreeConstruction();
    SequentialBarneHutForceApply();
    std::swap(body_, nextBody_);
  }
}
#endif

#ifdef BARNEHUT_PARALLEL

static inline int GetSection(const Body *body, double length,
                             int sectionPerDirection) {
  int x = body->xPos / length;
  int y = body->yPos / length;
  return y * sectionPerDirection + x;
}

static inline int GetProcID(int section, int sectionPerProc) {
  return section / sectionPerProc;
}

static int GetNodeIdx(const Node *node, const Node *root) {
  uint64_t rootAddr = reinterpret_cast<uint64_t>(root);
  uint64_t myAddr = reinterpret_cast<uint64_t>(node);
  return (myAddr - rootAddr) / sizeof(Node);
}
static inline bool IsMyPartialTree(int idx, int beg, int length) {
  return idx >= beg && idx < (beg + length);
}

static inline void CleanShareNode(Node *node, int count, int maxLevel) {
  memset(node, 0, count * sizeof(Node));
  Body body = {};
  SetAsRoot(node, &body);
  BFSPartition(node, node + 1, 0, 1, 0, maxLevel);
}

static inline void BottomUpRebuild(Node *node, int curLevel, int maxLevel) {
  if (curLevel == maxLevel) {
    return;
  }
  for (int i = 0; i < SUBTREE_COUNT; i++) {
    Node *child = GetChild(node, i);
    if (child) {
      BottomUpRebuild(child, curLevel + 1, maxLevel);
      node->body.xVel += child->body.xVel;
      node->body.yVel += child->body.yVel;
      node->body.mass += child->body.mass;
      node->hasChild = true;
    }
  }
  node->body.xPos = node->body.xVel / node->body.mass;
  node->body.yPos = node->body.yVel / node->body.mass;
}

void Universe::PartialTreeConstruction() {
  CleanShareNode(root_, sharedNodeCount_, sharedLevel_);
  mgr_->Clean();
  bool initializedTree[MaxSectionPerProc] = {};
  for (size_t i = 0; i < size_; ++i) {
    Body *body = body_ + i;
    if (body->mass == invalidWeight) {
      continue;
    }
    int section = GetSection(body, lengthPerSection_, sectionPerDirection_);
    int nodeIdx = sharedNodeCount_ - totalSection_ + section;
    int sharedIdx = nodeIdx - syncIdx_;
    if (initializedTree[sharedIdx] == false) {
      ReplaceEmptyRoot(root_ + nodeIdx, body);
      initializedTree[sharedIdx] = true;
    } else {
      AddNodeToTree(root_ + nodeIdx, body, mgr_);
    }
  }
}

void Universe::SendMyPartialTree() {
  for (int i = 0; i < procCount_; ++i) {
    if (i == myID_) {
      continue;
    }
    MPI_Request request;
    MPI_Isend(&(root_[syncIdx_]), sizeof(Node) * sectionPerProc_, MPI_CHAR, i,
              Tag, MPI_COMM_WORLD, &request);
  }
}
void Universe::FullTreeConstruction() {
  for (int i = 0; i < procCount_; ++i) {
    if (i == myID_) {
      continue;
    }
    int recvIdx = sharedNodeCount_ - totalSection_ + i * sectionPerProc_;
    MPI_Status status;
    MPI_Recv(root_ + recvIdx, sizeof(Node) * sectionPerProc_, MPI_CHAR, i, Tag,
             MPI_COMM_WORLD, &status);
  }
  BottomUpRebuild(root_, 0, sharedLevel_);
}

void Universe::SyncBack() {
  if (myID_ == Root) {
    MPI_Status status;
    for (int i = Root + 1; i < procCount_; ++i) {
      int recvCount = 0;
      MPI_Recv(&recvCount, 1, MPI_INT, i, Tag, MPI_COMM_WORLD, &status);
      if (recvCount == 0) {
        continue;
      }
      while (recvCount != 0) {
        int batch = std::min(recvCount, MaxRecvCount);
        MPI_Recv(body_ + size_, sizeof(Body) * batch, MPI_CHAR, i, Tag,
                 MPI_COMM_WORLD, &status);
        size_ += batch;
        recvCount -= batch;
      }
    }
  } else {
    MPI_Request request;
    MPI_Isend(&size_, 1, MPI_INT, Root, Tag, MPI_COMM_WORLD, &request);
    if (size_ == 0) {
      return;
    }
    int sendCount = size_;
    Body *beg = body_;
    while (sendCount != 0) {
      int batch = std::min(sendCount, MaxRecvCount);
      MPI_Isend(beg, sizeof(Body) * batch, MPI_CHAR, Root, Tag, MPI_COMM_WORLD,
                &request);
      beg += batch;
      sendCount -= batch;
    }
  }
}

void Universe::InitWorkPartition() {
  totalSection_ = 1;
  sectionPerDirection_ = 1;
  lengthPerSection_ = MaxRangeLength;

  sharedNodeCount_ = 1;
  sharedLevel_ = 0;

  while (totalSection_ < procCount_) {
    totalSection_ *= 4;
    lengthPerSection_ /= 2;
    sectionPerDirection_ *= 2;

    sharedNodeCount_ += totalSection_;
    ++sharedLevel_;
  }
  sectionPerProc_ = totalSection_ / procCount_;

  syncIdx_ = sharedNodeCount_ - totalSection_ + myID_ * sectionPerProc_;
}

void Universe::GetBodyInRange() {
  size_t newSize = 0;
  for (size_t i = 0; i < size_; ++i) {
    int section =
        GetSection(&body_[i], lengthPerSection_, sectionPerDirection_);
    int procID = GetProcID(section, sectionPerProc_);
    if (procID == myID_) {
      nextBody_[newSize] = body_[i];
      ++newSize;
    }
  }
  size_ = newSize;
  memcpy(body_, nextBody_, sizeof(Body) * size_);
}

void Universe::ParallelInit(int myID, int procCount) {
  myID_ = myID;
  procCount_ = procCount;

  InitWorkPartition();
  AllocBuffer();
  GetBodyInRange();
}

void Universe::AllocBuffer() {
  size_t size = sizeof(Node) * sharedNodeCount_;
  root_ = static_cast<Node *>(malloc(size));
  for (int i = 0; i < procCount_; ++i) {
    toBeSent_.push_back({});
    nodeCalcIdx_.push_back({});
    redistributeBuffer_.push_back({});
    bodyToBeSent_.push_back({});
  }
  resultBuffer_ = static_cast<ForceCalcReceive *>(
      malloc(sizeof(ForceCalcReceive) * size_ * sectionPerProc_));
  requestBuffer_ = static_cast<ForceCalcSend *>(
      malloc(sizeof(ForceCalcSend) * size_ * sectionPerProc_));
}

void Universe::ApplyPartialForce() {
  memset(tmpResult_, 0, size_ * sizeof(ForceResult));
  for (int i = 0; i < procCount_; i++) {
    toBeSent_[i].clear();
    nodeCalcIdx_[i].clear();
    bodyToBeSent_[i].clear();
    redistributeBuffer_[i].clear();
  }
  removeSize_ = 0;
  bodySize_ = 0;
  for (size_t i = 0; i < size_; ++i) {
    ApplyPartialForceOneParticle(i);
  }
}

void Universe::QueueMsg(int idx, int nodeIdx) {
  Body *body = &body_[idx];
  ForceCalcSend msg{body->xPos, body->yPos, body->mass, nodeIdx};
  int queueIdx =
      (nodeIdx - (sharedNodeCount_ - totalSection_)) / sectionPerProc_;
  toBeSent_[queueIdx].push_back(msg);
  tmpResult_[idx].msgNeed++;
  nodeCalcIdx_[queueIdx].push_back(idx);
}
void Universe::ApplyPartialForceOneParticleOnShared(size_t idx,
                                                    const Node *node,
                                                    int level) {
  Body *body = &body_[idx];
  ForceResult *result = &tmpResult_[idx];
  if (!node->hasChild || IsSingleBody(node, body, theta_)) {
    CalculateGForce(body, node->body.xPos, node->body.yPos, node->body.mass,
                    &result->fx, &result->fy);
  } else {
    bool isLastSharedLevel = level == sharedLevel_;
    bool notMyPartialTree =
        isLastSharedLevel &&
        (!IsMyPartialTree(GetNodeIdx(node, root_), syncIdx_, sectionPerProc_));
    if (notMyPartialTree) {
      QueueMsg(idx, GetNodeIdx(node, root_));
    } else {
      for (int i = 0; i < SUBTREE_COUNT; ++i) {
        const Node *child = GetChild(node, i);
        if (child && child->body.mass != 0) { // may be unitialized
          ApplyPartialForceOneParticleOnShared(idx, child, level + 1);
        }
      }
    }
  }
}

void Universe::ApplyPartialForceOneParticle(size_t idx) {
  if (body_[idx].mass == invalidWeight) {
    nextBody_[idx] = body_[idx];
    tmpResult_[idx].nextUpdated = true;
    return;
  }
  ApplyPartialForceOneParticleOnShared(idx, root_, 0);

  if (tmpResult_[idx].nextUpdated == 0 &&
      tmpResult_[idx].msgNeed == 0) { // can be computed internally
    UpdateBodyState(&(body_[idx]), &(nextBody_[idx]), tmpResult_[idx].fx,
                    tmpResult_[idx].fy);
    CheckOutOfProcRange(idx);
  }
}

void Universe::SendPartialForce() {
  for (size_t i = 0; i < procCount_; ++i) {
    if (i == myID_) {
      continue;
    }
    const auto &queueMsg = toBeSent_[i];
    int sendCount = queueMsg.size();
    MPI_Request request;
    MPI_Isend(&sendCount, 1, MPI_INT, i, Tag, MPI_COMM_WORLD, &request);
    if (sendCount == 0) {
      continue;
    }
    const ForceCalcSend *beg = queueMsg.data();
    while (sendCount != 0) {
      int batch = std::min(sendCount, MaxRecvCount);
      MPI_Isend(beg, sizeof(ForceCalcSend) * batch, MPI_CHAR, i, Tag,
                MPI_COMM_WORLD, &request);
      beg += batch;
      sendCount -= batch;
    }
  }
}

static void ComputePartialForceForRemote(const ForceCalcSend *send,
                                         ForceCalcReceive *result, Node *root,
                                         double theta) {
  root = root += send->nodeIdx;
  Body body = {};
  body.xPos = send->x;
  body.yPos = send->y;
  body.mass = send->mass;
  for (int i = 0; i < SUBTREE_COUNT; ++i) {
    const Node *child = GetChild(root, i);
    if (child) {
      BarneHutSumForceOneParticle(&body, child, theta, &result->fx,
                                  &result->fy);
    }
  }
}
void Universe::ReceivePartialForceRequest() {
  for (size_t i = 0; i < procCount_; ++i) {
    if (i == myID_) {
      continue;
    }
    int recvCount;
    MPI_Status status;
    MPI_Recv(&recvCount, 1, MPI_INT, i, Tag, MPI_COMM_WORLD, &status);
    if (recvCount == 0) {
      continue;
    }
    int recvCountIter = recvCount;
    ForceCalcSend *beg = requestBuffer_;
    while (recvCountIter != 0) {
      int batch = std::min(recvCountIter, MaxRecvCount);
      MPI_Recv(beg, sizeof(ForceCalcSend) * batch, MPI_CHAR, i, Tag,
               MPI_COMM_WORLD, &status);
      beg += batch;
      recvCountIter -= batch;
    }
    size_t recvSize = sizeof(ForceCalcReceive) * recvCount;
    memset(resultBuffer_, 0, recvSize);
    for (int j = 0; j < recvCount; ++j) {
      ComputePartialForceForRemote(&requestBuffer_[j], &resultBuffer_[j], root_,
                                   theta_);
    }
    MPI_Request request;
    MPI_Isend(resultBuffer_, recvSize, MPI_CHAR, i, Tag, MPI_COMM_WORLD,
              &request);
  }
}

void Universe::CombineForce(const ForceCalcReceive *receive, int idx) {
  tmpResult_[idx].fx += receive->fx;
  tmpResult_[idx].fy += receive->fy;
  tmpResult_[idx].msgNeed--;
  if (tmpResult_[idx].msgNeed == 0) {
    UpdateBodyState(&body_[idx], &nextBody_[idx], tmpResult_[idx].fx,
                    tmpResult_[idx].fy);
    CheckOutOfProcRange(idx);
  }
}

void Universe::ApplyFullForce() {
  for (size_t i = 0; i < procCount_; ++i) {
    if (i == myID_) {
      continue;
    }
    const auto &queueMsg = toBeSent_[i];
    size_t size = queueMsg.size();
    if (size == 0) {
      continue;
    }
    MPI_Status status;
    MPI_Recv(resultBuffer_, sizeof(ForceCalcReceive) * size, MPI_CHAR, i, Tag,
             MPI_COMM_WORLD, &status);
    for (int j = 0; j < size; ++j) {
      CombineForce(&resultBuffer_[j], nodeCalcIdx_[i][j]);
    }
  }
}

void Universe::CheckOutOfProcRange(int idx) {
  Body *body = &(nextBody_[idx]);
  if (body->mass == invalidWeight) {
    return;
  }
  int section = GetSection(body, lengthPerSection_, sectionPerDirection_);
  int procID = GetProcID(section, sectionPerProc_);
  if (procID != myID_) {
    bodyToBeSent_[procID].push_back(*body);
    removeIdx_[removeSize_] = idx;
    ++removeSize_;
  }
}

void Universe::RedistributeParticleSend() {
  for (size_t i = 0; i < procCount_; ++i) {
    if (i == myID_) {
      continue;
    }
    const auto &queueMsg = bodyToBeSent_[i];
    int sendCount = queueMsg.size();
    MPI_Request request;
    MPI_Isend(&sendCount, 1, MPI_INT, i, Tag, MPI_COMM_WORLD, &request);
    if (sendCount == 0) {
      continue;
    }
    const Body *beg = queueMsg.data();
    while (sendCount != 0) {
      int batch = std::min(sendCount, MaxRecvCount);
      MPI_Isend(beg, sizeof(Body) * batch, MPI_CHAR, i, Tag, MPI_COMM_WORLD,
                &request);
      beg += batch;
      sendCount -= batch;
    }
  }
}

void Universe::RedistributeParticleRecv() {
  int totalSize = 0;
  for (size_t i = 0; i < procCount_; ++i) {
    if (i == myID_) {
      continue;
    }
    int recvCount;
    MPI_Status status;
    MPI_Recv(&recvCount, 1, MPI_INT, i, Tag, MPI_COMM_WORLD, &status);
    if (recvCount == 0) {
      continue;
    }
    Body *beg = bodyBuffer_ + totalSize;
    totalSize += recvCount;
    while (recvCount != 0) {
      int batch = std::min(recvCount, MaxRecvCount);
      MPI_Recv(beg, sizeof(Body) * batch, MPI_CHAR, i, Tag, MPI_COMM_WORLD,
               &status);
      beg += batch;
      recvCount -= batch;
    }
  }
  bodySize_ += totalSize;
}

void Universe::Redistribute() {
  if (removeSize_ != 0) {
    std::sort(removeIdx_, removeIdx_ + removeSize_, std::greater<int>());
    for (int i = 0; i < removeSize_; i++) {
      int rmvIdx = removeIdx_[i];
      nextBody_[rmvIdx] = nextBody_[size_ - 1];
      body_[rmvIdx] = body_[size_ - 1];
      --size_;
    }
  }
  if (bodySize_ != 0) {
    memcpy(nextBody_ + size_, bodyBuffer_, sizeof(Body) * bodySize_);
    memcpy(body_ + size_, bodyBuffer_, sizeof(Body) * bodySize_);
    size_ += bodySize_;
  }
}

void Universe::BarneHutSimulation() {
  for (int i = 0; i < steps_; ++i) {
    PartialTreeConstruction();
    SendMyPartialTree();
    FullTreeConstruction();
    ApplyPartialForce();
    SendPartialForce();
    ReceivePartialForceRequest();
    ApplyFullForce();
    RedistributeParticleSend();
    RedistributeParticleRecv();
    Redistribute();
    std::swap(body_, nextBody_);
  }
  SyncBack();
}

#endif