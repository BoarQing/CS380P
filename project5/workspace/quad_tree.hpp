#include "body.hpp"
#include "const.hpp"
#include <vector>
#pragma once
constexpr int SUBTREE_COUNT = 4;

typedef struct {
  void *subtree[SUBTREE_COUNT];
  Body body;
  Range range;
  bool hasChild;
} Node;

class NodeMgr {
public:
  NodeMgr(size_t size);
  Node *GetNewNode();
  void Clean();

private:
  void AddABatch();
  static constexpr size_t batchSize = 2048;
  static constexpr size_t totalAllocSize = batchSize * sizeof(Node);
  size_t vectorIdx_;
  size_t nodeIdx_;
  std::vector<Node *> node_;
};

inline Node *GetChild(Node *root, int quadrant) {
  return reinterpret_cast<Node *>(root->subtree[quadrant]);
}

inline const Node *GetChild(const Node *root, int quadrant) {
  return reinterpret_cast<const Node *>(root->subtree[quadrant]);
}

void SetAsRoot(Node *root, const Body *body);
void ReplaceEmptyRoot(Node *root, const Body *body);
void AddNodeToTree(Node *root, const Body *body, NodeMgr *mgr);
#ifdef BARNEHUT_PARALLEL
void BFSPartition(Node *root, Node *mem, int beg, int end, int level,
                  int maxLevel);
#endif