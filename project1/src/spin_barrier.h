#ifndef _SPIN_BARRIER_H
#define _SPIN_BARRIER_H

#include <pthread.h>
#include <iostream>
#include <atomic>
#include <vector>

class spin_barrier {
public:
    spin_barrier(int count);
    void enter(int id);
private:
    std::atomic<int> counter;
    std::vector<std::atomic<bool>> go;
    int thread_count;
};

#endif
