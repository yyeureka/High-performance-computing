#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <assert.h>

typedef double dtype;

#define MIN(x, y) (x) < (y) ? (x) : (y)

void mm_cb (dtype *C, dtype *A, dtype *B, int N, int K, int M)
{
  /* =======================================================+ */
  /* Implement your own cache-blocked matrix-matrix multiply  */
  /* =======================================================+ */
  int b = 16;
  for (int ii = 0; ii < N; ii += b) {
    for (int jj = 0; jj < M; jj += b) {
      for (int kk = 0; kk < K; kk += b) {
        int b_N = MIN(b + ii, N);
        int b_M = MIN(b + jj, M);
        int b_K = MIN(b + kk, K);

        for (int i = ii; i < b_N; i++) {
          for (int j = jj; j < b_M; j++) {
            for (int k = kk; k < b_K; k++) {
              C[i * M + j] += A[i * K + k] * B[k * M + j];
            }
          }
        }
      }
    }
  }
}


