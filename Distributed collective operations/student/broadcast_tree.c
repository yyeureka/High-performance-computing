#include <assert.h>
#include <mpi.h>

void MST_Bcast(void *buffer, int root, int left, int right, int count, MPI_Datatype datatype, MPI_Comm comm)
{
	if (left == right) {
		return;
	}

	int mid = (left + right) / 2;
	int dst;
	int rank;
	MPI_Status status;
	MPI_Request req;

	MPI_Comm_rank(comm, &rank);

	if (root <= mid) {
		dst = right;
	}
	else {
		dst = left;
	}

	if (root == rank) {
		MPI_Isend(buffer, count, datatype, dst, 1, comm, &req);
		MPI_Wait(&req, &status);
	}
	else if (dst == rank) {
		MPI_Irecv(buffer, count, datatype, root, 1, comm, &req);
		MPI_Wait(&req, &status);
	}

	if ((rank <= mid) && (root <= mid)) {
		MST_Bcast(buffer, root, left, mid, count, datatype, comm);
	}
	else if ((rank <= mid) && (root > mid)) {
		MST_Bcast(buffer, dst, left, mid, count, datatype, comm);
	}
	else if ((rank > mid) && (root <= mid)) {
		MST_Bcast(buffer, dst, mid + 1, right, count, datatype, comm);
	}
	else {
		MST_Bcast(buffer, root, mid + 1, right, count, datatype, comm);
	}
}

int GT_Bcast(void *buffer, int count, MPI_Datatype datatype, int root, MPI_Comm comm)
{
	assert(datatype == MPI_INT);
	assert(root == 0);
	
	/* Your code here (Do not just call MPI_Bcast) */
	int size;
	MPI_Comm_size(comm, &size);
	// Reference: https://www.cs.utexas.edu/users/flame/pubs/InterCol_TR.pdf
	MST_Bcast(buffer, root, 0, size - 1, count, datatype, comm);
	
	return MPI_SUCCESS;
}


