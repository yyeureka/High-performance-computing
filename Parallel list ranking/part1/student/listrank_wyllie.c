#include <unistd.h>
#include <math.h>
#include <string.h>
#include "listutils.h"

void parallelListRanks (long head, const long* next, long* rank, size_t n)
{
	/* Your Code Goes Here */
	long r2[n], n1[n], n2[n];
	long round = ceil(log2(n));
	size_t i, j; 

	// Initialize
	#pragma omp parallel for shared(n, rank, r2, n1, n2, next) private (i)
	for (i = 0; i < n; i++) {
		rank[i] = 1;
		r2[i] = 1;
		n1[i] = next[i];
		n2[i] = next[i];
	}
	rank[head] = 0;
	r2[head] = 0;

	for (i = 0; i < round; i++) {
		// Update
		#pragma omp parallel for shared(n, rank, r2, n1) private (j)			
		for (j = 0; j < n; j++) {
			if (NIL == n1[j]) {
				continue;
			}

			r2[n1[j]] = rank[j] + rank[n1[j]];
		}

		// Jump
		#pragma omp parallel for shared(n, n1, n2) private (j)			
		for (j = 0; j < n; j++) {
			if (NIL == n1[j]) {
				continue;
			}

			n2[j] = n1[n1[j]];
		}

		// Swap
		#pragma omp parallel for shared(n, rank, r2, n1, n2) private (j)
		for (j = 0; j < n; j++) {
			rank[j] = r2[j];
			n1[j] = n2[j];
		}
	}
}
