#include <assert.h>
#include <mpi.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

void MST_Gather(int *sendbuf, int *recvbuf, int root, int left, int right, int sendcount, int recvcount, MPI_Datatype sendtype, MPI_Datatype recvtype, MPI_Comm comm)
{
	if (left == right) {
		return;
	}

	int mid = (left + right) / 2;
	int src;
	int size;
	int rank;
	MPI_Status status;
	MPI_Request req;
	int len_l;
	int len_r;

	MPI_Comm_rank(comm, &rank);
	MPI_Comm_size(comm, &size);

	if (root <= mid) {
		src = right;
	}
	else {
		src = left;
	}

	if ((rank <= mid) && (root <= mid)) {
		MST_Gather(sendbuf, recvbuf, root, left, mid, sendcount, recvcount, sendtype, recvtype, comm);
	}
	else if ((rank <= mid) && (root > mid)) {
		MST_Gather(sendbuf, recvbuf, src, left, mid, sendcount, recvcount, sendtype, recvtype, comm);
	}
	else if ((rank > mid) && (root <= mid)) {
		MST_Gather(sendbuf, recvbuf, src, mid + 1, right, sendcount, recvcount, sendtype, recvtype, comm);
	}
	else {
		MST_Gather(sendbuf, recvbuf, root, mid + 1, right, sendcount, recvcount, sendtype, recvtype, comm);
	}

	len_l = mid + 1 - left;
	len_r = right - mid;

	if (root <= mid) {  // mid+1:right
		if (src == rank) {
			if (NULL == recvbuf) {
				MPI_Isend(sendbuf, sendcount, sendtype, root, 1, comm, &req);	
			}
			else {
				MPI_Isend(recvbuf + (mid + 1) * sendcount, len_r * sendcount, sendtype, root, 1, comm, &req);
			}
			MPI_Wait(&req, &status);

			if (recvbuf) {
				free(recvbuf);
			}
		}
		else if (root == rank) {
			if (NULL == recvbuf) {
				recvbuf = malloc(recvcount * size * sizeof(int));
			}

			memcpy(recvbuf + rank * recvcount, sendbuf, recvcount * sizeof(int));

			MPI_Irecv(recvbuf + (mid + 1) * recvcount, len_r * recvcount, recvtype, src, 1, comm, &req);
			MPI_Wait(&req, &status);
		}
	}
	else {  // left:mid
		if (src == rank) {
			// printf("%d send to %d %d\n", rank, root, len_l * sendcount);
			if (NULL == recvbuf) {
				MPI_Isend(sendbuf, sendcount, sendtype, root, 1, comm, &req);	
			}
			else {
				MPI_Isend(recvbuf + left * sendcount, len_l * sendcount, sendtype, root, 1, comm, &req);
			}
			MPI_Wait(&req, &status);

			if (recvbuf) {
				free(recvbuf);
			}
		}
		else if (root == rank) { 
			if (NULL == recvbuf) {
				recvbuf = malloc(recvcount * size * sizeof(int));
			}

			memcpy(recvbuf + rank * recvcount, sendbuf, recvcount * sizeof(int));

			MPI_Irecv(recvbuf + left * recvcount, len_l * recvcount, recvtype, src, 1, comm, &req);
			MPI_Wait(&req, &status);
		}
	}
}

int GT_Gather(void *sendbuf, int sendcount, MPI_Datatype sendtype,
		void *recvbuf, int recvcount, MPI_Datatype recvtype, int root,
		MPI_Comm comm)
{
	assert(sendtype == MPI_INT && recvtype == MPI_INT);
	assert(root == 0);
	
	/* Your code here (Do not just call MPI_Gather) */
	int size;
	MPI_Comm_size(comm, &size);
	// Reference: https://www.cs.utexas.edu/users/flame/pubs/InterCol_TR.pdf
	MST_Gather(sendbuf, recvbuf, root, 0, size - 1, sendcount, recvcount, sendtype, recvtype, comm);
	
	return MPI_SUCCESS;
}
