#include <assert.h>
#include <mpi.h>
#include <string.h>

void BKT_Allgather(int *sendbuf, int *recvbuf, int sendcount, int recvcount, int size, MPI_Datatype sendtype, MPI_Datatype recvtype, MPI_Comm comm)
{
    int rank;
    MPI_Status status[2];
	MPI_Request reqs[2];
    int prev;
    int next;

    MPI_Comm_rank(comm, &rank);
    memcpy(recvbuf + rank * recvcount, sendbuf, recvcount * sizeof(int));

    prev = rank - 1;
    if (prev < 0) {
        prev = size - 1;
    }

    next = rank + 1;
    if (next >= size) {
        next = 0;
    }

    for (int i = 0; i <= size - 1; i++) {
        MPI_Isend(recvbuf + rank * sendcount, sendcount, sendtype, next, 1, comm, &reqs[0]);

        rank -= 1;
        if (rank < 0) {
            rank = size - 1;
        }

        MPI_Irecv(recvbuf + rank * recvcount, recvcount, recvtype, prev, 1, comm, &reqs[1]);

        MPI_Waitall(2, reqs, status);
    }
}

int GT_Allgather( void *sendbuf, 
                  int  sendcount,
                  MPI_Datatype sendtype, 
                  void *recvbuf, 
                  int recvcount,
                  MPI_Datatype recvtype, 
                  MPI_Comm comm)
{
	assert(sendtype == MPI_INT && recvtype == MPI_INT);
	
	/* Your code here (Do not just call MPI_Allgather) */
    int size;
	MPI_Comm_size(comm, &size);
	// Reference: https://www.cs.utexas.edu/users/flame/pubs/InterCol_TR.pdf
    BKT_Allgather(sendbuf, recvbuf, sendcount, recvcount, size, sendtype, recvtype, comm);
	
	return MPI_SUCCESS;
}
