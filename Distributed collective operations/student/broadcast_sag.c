#include <assert.h>
#include <mpi.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

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

void BKT_Allgather(int *sendbuf, int *recvbuf, int count, int size, MPI_Datatype datatype, MPI_Comm comm)
{
  int rank;
  MPI_Status status[2];
  MPI_Request reqs[2];
  int prev;
  int next;

  MPI_Comm_rank(comm, &rank);
  memcpy(recvbuf + rank * count, sendbuf, count * sizeof(int));

  prev = rank - 1;
  if (prev < 0) {
    prev = size - 1;
  }

  next = rank + 1;
  if (next >= size) {
    next = 0;
  }

  for (int i = 0; i <= size - 1; i++) {
    MPI_Isend(recvbuf + rank * count, count, datatype, next, 1, comm, &reqs[0]);

    rank -= 1;
    if (rank < 0) {
      rank = size - 1;
    }

    MPI_Irecv(recvbuf + rank * count, count, datatype, prev, 1, comm, &reqs[1]);

    MPI_Waitall(2, reqs, status);
  }
}

int GT_Bcast(void *buffer, int count, MPI_Datatype datatype, int root, MPI_Comm comm)
{
  assert(datatype == MPI_INT);
  assert(root == 0);
  
  /* Your code here (Do not just call MPI_Bcast) */
  int size;
  int rank;
	MPI_Comm_size(comm, &size);
	MPI_Comm_rank(comm, &rank);

  count /= size;
  int *sendbuf = NULL;
  int *recvbuf = malloc(count * sizeof(int));

  if (root == rank) {
    sendbuf = buffer;
  }

  // Reference: https://www.cs.utexas.edu/users/flame/pubs/InterCol_TR.pdf
  MST_Scatter(sendbuf, recvbuf, root, 0, size - 1, count, datatype, comm);

  MPI_Barrier(comm);

  BKT_Allgather(recvbuf, buffer, count, size, datatype, comm);
  
  free(recvbuf);

  return MPI_SUCCESS;
}
