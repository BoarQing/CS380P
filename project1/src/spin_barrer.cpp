#include <spin_barrier.h>


/************************
 * Your code here...    *
 * or wherever you like *
 ************************/
void spin_barrier::enter(int id)
{
    bool my_go = go[id];
    int my_counter = counter.fetch_add(1);
    if (my_counter + 1 == thread_count) {
        counter = 0;
        for (int i = 0; i < thread_count; ++i) {
            go[i] = 1 - go[i];
        }
    } else {
        // got optimized if non-atomic
        while (my_go == go[id]) {}
    }
}

spin_barrier::spin_barrier(int thread_count)
{
    counter = 0;
    this->thread_count = thread_count;
    go = std::vector<std::atomic<bool>>(thread_count);
}