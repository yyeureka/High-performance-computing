#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <assert.h>
#include <math.h>

#include "timer_cse6220.c"

#define N_ 512
#define K_ 512
#define M_ 512

typedef double dtype;

extern void mm_cb (dtype *C, dtype *A, dtype *B, int N, int K, int M);

int verify(dtype *C, dtype *C_ans, int N, int M, long double time_ref, long double time_stu)
{
  int i, cnt;
  cnt = 0;
  for(i = 0; i < N * M; i++) {
    if(fabs (C[i] - C_ans[i]) > 1e-6) cnt++;
  }

  free(C_ans);
  free(C);

  if (cnt != 0)
  {
	printf("ERROR\n");
	printf("Speedup: INVALID\n");

	return 1;
  }
  else
  {
	printf("SUCCESS\n");
	printf("Speedup: %#.1Lf\n", (long double)(time_ref / time_stu));

	return 0;
  }
}

void mm_serial (dtype *C, dtype *A, dtype *B, int N, int K, int M)
{
  int i, j, k;
  for(int i = 0; i < N; i++) {
    for(int j = 0; j < M; j++) {
      for(int k = 0; k < K; k++) {
        C[i * M + j] += A[i * K + k] * B[k * M + j];
      }
    }
  }
}

int main(int argc, char** argv)
{
  int i, j, k;
  int N, K, M;

  if(argc == 4) {
    N = atoi (argv[1]);
    K = atoi (argv[2]);
    M = atoi (argv[3]);
    printf("N: %d K: %d M: %d\n", N, K, M);
  } else {
    N = N_;
    K = K_;
    M = M_;
    printf("N: %d K: %d M: %d\n", N, K, M);
  }

  dtype *A = (dtype*) malloc (N * K * sizeof (dtype));
  dtype *B = (dtype*) malloc (K * M * sizeof (dtype));
  dtype *C = (dtype*) malloc (N * M * sizeof (dtype));
  dtype *C_cb = (dtype*) malloc (N * M * sizeof (dtype));
  assert (A && B && C);

  /* initialize A, B, C */
  srand48 (time (NULL));
  for(i = 0; i < N; i++) {
    for(j = 0; j < K; j++) {
      A[i * K + j] = drand48 ();
    }
  }
  for(i = 0; i < K; i++) {
    for(j = 0; j < M; j++) {
      B[i * M + j] = drand48 ();
    }
  }
  bzero(C, N * M * sizeof (dtype));
  bzero(C_cb, N * M * sizeof (dtype));

  stopwatch_init ();
  struct stopwatch_t* timer = stopwatch_create ();
  assert (timer);
  long double t_reference, t_student;

  printf("Naive matrix multiply\n");
  stopwatch_start (timer);
  /* do C += A * B */
  mm_serial (C, A, B, N, K, M);
  t_reference = stopwatch_stop (timer);
  printf("Done\n");
  printf("time for naive implementation: %Lg seconds\n\n", t_reference);


  printf("Cache-blocked matrix multiply\n");
  stopwatch_start (timer);
  /* do C += A * B */
  mm_cb (C_cb, A, B, N, K, M);
  t_student = stopwatch_stop (timer);
  printf("Done\n");
  printf("time for cache-blocked implementation: %Lg seconds\n", t_student);

  stopwatch_destroy(timer);
  free(A);
  free(B); /* note that C, C_cb are freed by verify() */

  /* verify answer */
  return verify (C_cb, C, N, M, t_reference, t_student);
}
