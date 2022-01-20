PROGRAM test_tp8

  USE xios
  IMPLICIT NONE
  INCLUDE "mpif.h"
  INTEGER :: rank
  INTEGER :: size
  INTEGER :: ierr

  CHARACTER(len=*),PARAMETER :: id="client"
  INTEGER :: comm
  TYPE(xios_duration) :: dtime
  TYPE(xios_date) :: date
  CHARACTER(len=20) :: date_str
  INTEGER :: ni_glo
  INTEGER :: nj_glo

  INTEGER :: i,j,l

  CHARACTER(len=20) :: domain_type
  DOUBLE PRECISION, ALLOCATABLE :: lonvalue(:)
  DOUBLE PRECISION, ALLOCATABLE :: latvalue(:)

  DOUBLE PRECISION, ALLOCATABLE :: temp(:,:)
  INTEGER :: ts

  INTEGER :: ni, ibegin, nj, jbegin
  INTEGER,PARAMETER :: seed = 86456
  real :: ri,rj

  CALL MPI_INIT(ierr)

  CALL xios_initialize(id,return_comm=comm)

  CALL MPI_COMM_RANK(comm,rank,ierr)
  CALL MPI_COMM_SIZE(comm,size,ierr)

  
  CALL xios_context_initialize("test",comm)
  
  
  dtime%hour = 1
  CALL xios_set_timestep(dtime)


  
  CALL xios_get_domain_attr("domain", type = domain_type)
  CALL xios_get_domain_attr("domain", ni_glo = ni_glo, nj_glo=nj_glo)
  
  ni = ni_glo/size
  ibegin = rank*ni
  nj = nj_glo
  jbegin=0

  CALL xios_set_domain_attr("domain", ni=ni, ibegin=ibegin, nj=nj, jbegin=jbegin) 
  ALLOCATE(lonvalue(ni))
  ALLOCATE(latvalue(nj))

  DO i=1,ni 
    lonvalue(i) = -180 + (rank*ni+i) * 360/ni_glo
  ENDDO
  
  DO j=1, nj
    latvalue(j) = -90 + j * 180/nj_glo
  ENDDO

  CALL xios_set_domain_attr("domain", lonvalue_1d=lonvalue,latvalue_1d=latvalue)


  ALLOCATE(temp(ni, nj))


  CALL xios_close_context_definition()
  
  call random_seed()

  DO ts=1,480
    CALL xios_update_calendar(ts)

    call random_number(ri)
    call random_number(rj)

    if ((MOD(ts,24) .LE. 12) .AND. (MOD(ts,24) .GE. 1)) then
      temp(:,:) = MOD(ts,24)+ri
    else if (MOD(ts,24) .EQ. 0) then
      temp(:,:) = 0+rj
    else
      temp(:,:) = 24-MOD(ts,24)
    endif

    CALL xios_send_field("temp", temp)
  ENDDO
  CALL xios_context_finalize()

  DEALLOCATE(lonvalue)
  DEALLOCATE(latvalue)
  DEALLOCATE(temp)

  CALL MPI_COMM_FREE(comm, ierr)

  CALL xios_finalize()

  CALL MPI_FINALIZE(ierr)

END PROGRAM test_tp8

