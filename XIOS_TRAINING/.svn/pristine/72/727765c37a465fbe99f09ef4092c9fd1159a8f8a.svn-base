PROGRAM test_tp1

  IMPLICIT NONE
  INCLUDE "mpif.h"
  INTEGER :: rank
  INTEGER :: size
  INTEGER :: ierr

  CALL MPI_INIT(ierr)

  CALL MPI_COMM_RANK(MPI_COMM_WORLD,rank,ierr)
  CALL MPI_COMM_SIZE(MPI_COMM_WORLD,size,ierr)

  print*, "Hello XIOS from proc", rank

  CALL MPI_FINALIZE(ierr)

END PROGRAM test_tp1





