#include "quad_tree.hpp"
#include <cstdlib>
#include <string.h>

static inline double MapBoolToSign(bool b) {
  return static_cast<double>((static_cast<int>(b) << 1) - 1);
}

static inline int CalculateQuadrant(const Node *node, double x, double y) {
  bool xGreater = x >= node->range.x;
  bool yGreater = y >= node->range.y;
  int ret = (static_cast<int>(yGreater) << 1) + static_cast<int>(xGreater);
  return ret;
}

static void UpdateMass(Node *root, const Body *body) {
  // use xVel, yVel for temp sum
  root->body.mass += body->mass;
  root->body.xVel += body->xPos * body->mass;
  root->body.yVel += body->yPos * body->mass;

  root->body.xPos = root->body.xVel / root->body.mass;
  root->body.yPos = root->body.yVel / root->body.mass;
}

static inline void ConvertMass(Node *root) {
  // use xVel, yVel for temp sum
  root->body.xVel = root->body.xPos * root->body.mass;
  root->body.yVel = root->body.yPos * root->body.mass;
}

static void UpdateRange(const Node *root, Node *node, int quadrant) {
  node->range.length = root->range.length / 2.0;
  node->range.x =
      root->range.x + node->range.length * MapBoolToSign((quadrant & 1) == 1);
  node->range.y =
      root->range.y + node->range.length * MapBoolToSign((quadrant & 2) == 2);
}

void ReplaceEmptyRoot(Node *root, const Body *body) {
  root->hasChild = false;
  root->body = *body;
  ConvertMass(root);
}

void SetAsRoot(Node *root, const Body *body) {
  root->range = maxRange;
  ReplaceEmptyRoot(root, body);
}

void AddNodeToTree(Node *root, const Body *body, NodeMgr *mgr) {
  if (!root->hasChild) {
    // split
    int parentQuadrant =
        CalculateQuadrant(root, root->body.xPos, root->body.yPos);
    Node *newNode = mgr->GetNewNode();
    newNode->body = root->body; // already converted
    UpdateRange(root, newNode, parentQuadrant);
    root->hasChild = true;
    root->subtree[parentQuadrant] = newNode;
    AddNodeToTree(root, body, mgr);
  } else {
    int quadrant = CalculateQuadrant(root, body->xPos, body->yPos);
    if (root->subtree[quadrant] == nullptr) {
      Node *newNode = mgr->GetNewNode();
      newNode->body = *body;
      ConvertMass(newNode);
      UpdateRange(root, newNode, quadrant);
      UpdateMass(root, body);
      root->subtree[quadrant] = newNode;
    } else {
      UpdateMass(root, body);
      AddNodeToTree(GetChild(root, quadrant), body, mgr);
    }
  }
}

void NodeMgr::AddABatch() {
  Node *memPool = static_cast<Node *>(malloc(totalAllocSize));
  node_.push_back(memPool);
}

Node *NodeMgr::GetNewNode() {
  Node *ret = &(node_[vectorIdx_][nodeIdx_]);
  ++nodeIdx_;
  if (nodeIdx_ == batchSize) {
    nodeIdx_ = 0;
    ++vectorIdx_;
    if (vectorIdx_ == node_.size()) {
      AddABatch();
    }
  }

  return ret;
}

void NodeMgr::Clean() {
  for (size_t i = 0; i <= vectorIdx_; ++i) {
    memset(node_[i], 0, totalAllocSize);
  }
  vectorIdx_ = 0;
  nodeIdx_ = 0;
}

NodeMgr::NodeMgr(size_t size) {
  vectorIdx_ = 0;
  nodeIdx_ = 0;
  for (size_t i = 0; i < batchSize; i += batchSize) {
    AddABatch();
  }
}
#include <iostream>

#ifdef BARNEHUT_PARALLEL

static int GetCylicParent(const Range &range, Node *parent, int len) {
  for (int i = 0; i < len; i++) {
    Node *n = parent + i;
    double xDiff = range.x - n->range.x;
    double yDiff = range.y - n->range.y;
    if ((std::abs(xDiff) < n->range.length) &&
        (std::abs(yDiff) < n->range.length)) {
      return i;
    }
  }
  return -1;
}
void BFSPartition(Node *root, Node *mem, int beg, int end, int level,
                  int maxLevel) {
  if (level == maxLevel) {
    return;
  }
  int len = end - beg;
  int total = len * SUBTREE_COUNT;

  double length = maxRange.length / (2 << level);
  double offset = length;
  int wrap = 2 << level;

  Node *parent = root + beg;

  for (int i = 0; i < total; i++) {
    double x = offset + 2 * length * (i % wrap);
    double y = offset + 2 * length * (i / wrap);
    Range range = {x = x, y = y, length = length};

    int parentIdx = GetCylicParent(range, parent, len);
    Node *rangeParent = parent + parentIdx;
    int quadrant = CalculateQuadrant(rangeParent, x, y);
    mem->range = range;
    rangeParent->subtree[quadrant] = mem;
    ++mem;
  }
  int newBeg = end;
  int newEnd = newBeg + len * SUBTREE_COUNT;
  BFSPartition(root, mem, newBeg, newEnd, level + 1, maxLevel);
}
#endif
