// ---
// author: "Nam T. Nguyen"
// ---
#include <stdlib.h>

#include "listutils.h"

__global__
void update(long* rank, size_t n) {
  #error template
}

__global__
void jump(long* this_rank, long* this_next, long* next_rank, long* next_next, size_t n) {
  #error template
}

__global__
void swap(long* rank, size_t n) {
  #error template
}

extern "C" void parallelListRanks(
    const long head,
    const long* next,
    long* rank,
    const size_t n) {
  #error template
}
