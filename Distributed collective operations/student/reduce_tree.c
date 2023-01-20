#include <assert.h>
#include <mpi.h>
#include <stdlib.h>

void MST_Reduce(int *sendbuf, int *recvbuf, int root, int left, int right, int count, MPI_Datatype datatype, MPI_Comm comm) 
{
    if (left == right) {
		return;
	}

	int mid = (left + right) / 2;
	int src;
	int rank;
	MPI_Status status;
	MPI_Request req;

	MPI_Comm_rank(comm, &rank);

    if (root <= mid) {
		src = right;
	}
	else {
		src = left;
	}

    if ((rank <= mid) && (root <= mid)) {
		MST_Reduce(sendbuf, recvbuf, root, left, mid, count, datatype, comm);
	}
	else if ((rank <= mid) && (root > mid)) {
		MST_Reduce(sendbuf, recvbuf, src, left, mid, count, datatype, comm);
	}
	else if ((rank > mid) && (root <= mid)) {
		MST_Reduce(sendbuf, recvbuf, src, mid + 1, right, count, datatype, comm);
	}
	else {
		MST_Reduce(sendbuf, recvbuf, root, mid + 1, right, count, datatype, comm);
	}

    if (src == rank) {
		MPI_Isend(sendbuf, count, datatype, root, 1, comm, &req);
		free(recvbuf);
		MPI_Wait(&req, &status);
	}
	if (root == rank) {
		if (NULL == recvbuf) {
			recvbuf = malloc(count * sizeof(int));
		}

		MPI_Irecv(recvbuf, count, datatype, src, 1, comm, &req);
		MPI_Wait(&req, &status);

		for (int i = 0; i < count; i++) {
			sendbuf[i] += recvbuf[i];
			recvbuf[i] = sendbuf[i];
        }
	}
}

int GT_Reduce(void *sendbuf, void *recvbuf, int count, MPI_Datatype datatype,
			MPI_Op op, int root, MPI_Comm comm)
{
    assert(datatype == MPI_INT);
    assert(op == MPI_SUM);
    assert(root == 0);
					
    /* Your code here (Do not just call MPI_Reduce) */
    int size;
    MPI_Comm_size(comm, &size);
	// Reference: https://www.cs.utexas.edu/users/flame/pubs/InterCol_TR.pdf
	MST_Reduce(sendbuf, recvbuf, root, 0, size - 1, count, datatype, comm);

    return MPI_SUCCESS;
}

