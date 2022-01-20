PROGRAM test_tp2

  USE XIOS
  IMPLICIT NONE
  INCLUDE "mpif.h"
  INTEGER :: rank
  INTEGER :: size
  INTEGER :: ierr

  CHARACTER(len=*),PARAMETER :: id="client"
  INTEGER :: comm
  TYPE(xios_duration) :: dtime

  CALL MPI_INIT(ierr)

  CALL xios_initialize(id,return_comm=comm)

  CALL MPI_COMM_RANK(comm,rank,ierr)
  CALL MPI_COMM_SIZE(comm,size,ierr)
  
  print*, "Hello XIOS from proc", rank
  
  CALL xios_context_initialize("test",comm)

  CALL xios_define_calendar(type="Gregorian")
  dtime%second = 3600
  CALL xios_set_timestep(dtime)

  CALL xios_close_context_definition()

  CALL xios_context_finalize()

  CALL MPI_COMM_FREE(comm, ierr)

  CALL xios_finalize()

  CALL MPI_FINALIZE(ierr)

END PROGRAM test_tp2

