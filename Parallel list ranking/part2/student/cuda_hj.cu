#include <unistd.h>
#include "listutils.h"

#define TRUE  1
#define FALSE 0

__device__ int isSubHead(long node, long head, long s) {
	if (NIL == node) {
		return FALSE;
	}
	if ((head == node) || ((head >= s) && (node < (s - 1))) 
	|| ((head < s) && (node < s))) {
		return TRUE;
	}
	return FALSE;
}

__global__ void link(long head, long* next, long* sub_head, long* next_head, long* head_rank, size_t s) {
	long r;
	long node;

	size_t i = (blockIdx.x * blockDim.x) + threadIdx.x;
	if (i < s) {
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
				head_rank[node] = r;
				break;
			}
		}
	}
}

__global__ void rank_sublist(long head, long* next, long* rank, long* sub_head, size_t s) {
	long r;
	long node;

	size_t i = (blockIdx.x * blockDim.x) + threadIdx.x;
	if (i < s) {
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

extern "C" void parallelListRanks(const long head, const long* next, long* rank, const size_t n)
{
	/* Your Code Goes Here */
	size_t s = n / 50;
	long sub_head[s], next_head[s], head_rank[s];
	long r;
	long node;

	dim3 block_config(32);
	dim3 grid_config(s - 1 / block_config.x);
	long* d_next;
	long* d_rank;
	long* d_sh;
	long* d_nh;
	long* d_hr;
	cudaMalloc((void**)&d_next, sizeof(long) * n);
	cudaMalloc((void**)&d_rank, sizeof(long) * n);
	cudaMalloc((void**)&d_sh, sizeof(long) * s);
	cudaMalloc((void**)&d_nh, sizeof(long) * s);
	cudaMalloc((void**)&d_hr, sizeof(long) * s);

	// Initialize
	for (size_t i = 0; i < s; i++) {
		sub_head[i] = i;
		next_head[i] = NIL;
	}
	if (head >= s) {
		sub_head[s - 1] = head;
	}
	rank[head] = 0;

	// Link sub-lists
	cudaMemcpy(d_next, next, sizeof(long) * n, cudaMemcpyHostToDevice);
	cudaMemcpy(d_sh, sub_head, sizeof(long) * s, cudaMemcpyHostToDevice);
	cudaMemcpy(d_nh, next_head, sizeof(long) * s, cudaMemcpyHostToDevice);
	cudaMemcpy(d_hr, head_rank, sizeof(long) * s, cudaMemcpyHostToDevice);
	link<<<grid_config, block_config>>>(head, d_next, d_sh, d_nh, d_hr, s);
	cudaMemcpy(next_head, d_nh, sizeof(long) * s, cudaMemcpyDeviceToHost);
	cudaMemcpy(head_rank, d_hr, sizeof(long) * s, cudaMemcpyDeviceToHost);

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
			rank[node] = head_rank[node] + r;
			r = rank[node];
			node = next_head[node];
		}
	}

	// Rank sub-lists
	cudaMemcpy(d_rank, rank, sizeof(long) * n, cudaMemcpyHostToDevice);
	cudaMemcpy(d_next, next, sizeof(long) * n, cudaMemcpyHostToDevice);
	cudaMemcpy(d_sh, sub_head, sizeof(long) * s, cudaMemcpyHostToDevice);
	rank_sublist<<<grid_config, block_config>>>(head, d_next, d_rank, d_sh, s);
	cudaMemcpy(rank, d_rank, sizeof(long) * n, cudaMemcpyDeviceToHost);

	cudaFree(d_next);
	cudaFree(d_rank);
	cudaFree(d_sh);
	cudaFree(d_nh);
	cudaFree(d_hr);
}
