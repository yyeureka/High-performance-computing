#include <unistd.h>
#include "listutils.h"

#define TRUE  1
#define FALSE 0

int isSubHead (long node, long head, long s) {
	if (NIL == node) {
		return FALSE;
	}
	if ((head == node) || ((head >= s) && (node < (s - 1))) 
	|| ((head < s) && (node < s))) {
		return TRUE;
	}
	return FALSE;
}

void parallelListRanks (long head, const long* next, long* rank, size_t n)
{
	/* Your Code Goes Here */
	size_t s = n / 10;
	long sub_head[s], next_head[s];
	long r;
	long node;
	size_t i;

	// Initialize
	#pragma omp parallel for shared(s, rank, sub_head, next_head) private (i)
	for (i = 0; i < s; i++) {
		sub_head[i] = i;
		next_head[i] = NIL;
	}
	if (head >= s) {
		sub_head[s - 1] = head;
	}
	rank[head] = 0;

	// Link sub-lists
	#pragma omp parallel for shared(s, head, next, rank, sub_head, next_head) private (i, r, node)
	for (i = 0; i < s; i++) {
		node = sub_head[i];
		r = 0;

		while (NIL != node) {
			r++;
			node = next[node];

			if (TRUE == isSubHead(node, head, s)) {
				if ((head >= s) && ((s - 1) == i)) {
					next_head[s - 1] = node;
				}
				else {
					next_head[sub_head[i]] = node;
				}
				rank[node] = r;
				break;
			}
		}
	}

	// Rank sub-heads
	node = head;
	r = 0;
	while (NIL != node) {
		if (head == node) {
			if (head >= s) {
				node = next_head[s - 1];
			}
			else {
				node = next_head[node];
			}
		}
		else {
			rank[node] += r;
			r = rank[node];
			node = next_head[node];
		}
	}

	// Rank sub-lists
	#pragma omp parallel for shared(s, head, next, rank, sub_head) private (i, r, node)
	for (i = 0; i < s; i++) {
		node = sub_head[i];
		r = rank[node];

		while (NIL != node) {
			rank[node] = r++;
			node = next[node];

			if (TRUE == isSubHead(node, head, s)) {
				break;
			}
		}
	}
}
