#include <assert.h>
#include <mpi.h>
#include <stdlib.h>
#include <string.h>

void MST_Scatter(int *sendbuf, int *recvbuf, int root, int left, int right, int count, MPI_Datatype datatype, MPI_Comm comm)
{
	if (left == right) {
		return;
	}

	int mid = (left + right) / 2;
	int dst;
	int rank;
	MPI_Status status;
	MPI_Request req;
	int len_l;
	int len_r;

	MPI_Comm_rank(comm, &rank);

	if (root <= mid) {
		dst = right;
	}
	else {
		dst = left;
	}

	len_l = mid + 1 - left;
	len_r = right - mid;

	if (root <= mid) {  // mid+1:right
		if (root == rank) {
			MPI_Isend(sendbuf + len_l * count, len_r * count, datatype, dst, 1, comm, &req);		

			if (1 == len_l) {
				memcpy(recvbuf, sendbuf, count * sizeof(int));
			}

			MPI_Wait(&req, &status);
		}
		else if (dst == rank) {
			if (len_r > 1) {
				if (NULL == sendbuf) {
					sendbuf = malloc(len_r * count * sizeof(int));
				}

				MPI_Irecv(sendbuf, len_r * count, datatype, root, 1, comm, &req);
			}
			else {
				MPI_Irecv(recvbuf, len_r * count, datatype, root, 1, comm, &req);
			}
			MPI_Wait(&req, &status);
		}
	}
	else {  // left:mid
		if (root == rank) {
			MPI_Isend(sendbuf, len_l * count, datatype, dst, 1, comm, &req);		
			
			if (1 == len_r) {
				memcpy(recvbuf, sendbuf + len_l * count, count * sizeof(int));
			}

			MPI_Wait(&req, &status);
		}
		else if (dst == rank) { 
			if (len_l > 1) {
				if (NULL == sendbuf) {
					sendbuf = malloc(len_l * count * sizeof(int));
				}

				MPI_Irecv(sendbuf, len_l * count, datatype, root, 1, comm, &req);
			}
			else {
				MPI_Irecv(recvbuf, len_l * count, datatype, root, 1, comm, &req);
			}
			MPI_Wait(&req, &status);
		}
	}

	if ((rank <= mid) && (root <= mid)) {
		MST_Scatter(sendbuf, recvbuf, root, left, mid, count, datatype, comm);
	}
	else if ((rank <= mid) && (root > mid)) {
		MST_Scatter(sendbuf, recvbuf, dst, left, mid, count, datatype, comm);
	}
	else if ((rank > mid) && (root <= mid)) {
		MST_Scatter(sendbuf, recvbuf, dst, mid + 1, right, count, datatype, comm);
	}
	else {
		MST_Scatter(sendbuf, recvbuf, root, mid + 1, right, count, datatype, comm);
	}
}

int GT_Scatter(void *sendbuf, int sendcount, MPI_Datatype sendtype,
    void *recvbuf, int recvcount, MPI_Datatype recvtype, int root,
    MPI_Comm comm)
{
	assert(sendtype == MPI_INT && recvtype == MPI_INT);
	assert(root == 0);
	
	/* Your code here (Do not just call MPI_Scatter) */
	int size;
	MPI_Comm_size(comm, &size);
	// Reference: https://www.cs.utexas.edu/users/flame/pubs/InterCol_TR.pdf
	MST_Scatter(sendbuf, recvbuf, root, 0, size - 1, sendcount, sendtype, comm);

	int rank;
	MPI_Comm_rank(comm, &rank);
	if (root != rank) {
		free(sendbuf);
	}
	
	return MPI_SUCCESS;
}
