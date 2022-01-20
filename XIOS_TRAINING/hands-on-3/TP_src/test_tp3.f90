PROGRAM test_tp3

  USE XIOS
  IMPLICIT NONE
  INCLUDE "mpif.h"
  INTEGER :: rank
  INTEGER :: size
  INTEGER :: ierr

  INTEGER :: comm
  TYPE(xios_duration) :: dtime

  TYPE(xios_date) :: dorigin
  CHARACTER(len=20) :: dorigin_str

  TYPE(xios_date) :: dstart
  CHARACTER(len=20) :: dstart_str

  INTEGER :: axis_size
  DOUBLE PRECISION, ALLOCATABLE :: axis_value(:)

  CHARACTER(len=20) :: domain_type
  INTEGER :: ni_glo, nj_glo
  DOUBLE PRECISION, ALLOCATABLE :: lonvalue(:), latvalue(:)
  
  INTEGER :: i, j
  
  DOUBLE PRECISION, ALLOCATABLE :: field_A(:,:,:)
 
  INTEGER :: ts
 
  CALL MPI_INIT(ierr)

  CALL xios_initialize("client",return_comm=comm)

  CALL MPI_COMM_RANK(comm,rank,ierr)
  CALL MPI_COMM_SIZE(comm,size,ierr)
  
  print*, "Hello XIOS from proc", rank
  
  CALL xios_context_initialize("test",comm)

  !CALL xios_define_calendar(type="Gregorian") 
  !We define the calendar type in xml

  CALL xios_get_time_origin(dorigin)
  CALL xios_date_convert_to_string(dorigin, dorigin_str)
  if (rank .EQ. 0) print*, "calendar time_origin = ", dorigin_str

  CALL xios_get_start_date(dstart)
  CALL xios_date_convert_to_string(dstart, dstart_str)
  if (rank .EQ. 0) print*, "calendar start_date = ", dstart_str

  dtime%second = 3600
  CALL xios_set_timestep(dtime)

  CALL xios_get_axis_attr("axis_A", n_glo = axis_size)
  ALLOCATE(axis_value(axis_size))
  CALL xios_get_axis_attr("axis_A", value = axis_value)
  if (rank .EQ. 0) print*, "axis value = ", axis_value(:)

  CALL xios_get_domain_attr("domain_A", type = domain_type)
  CALL xios_get_domain_attr("domain_A", ni_glo = ni_glo, nj_glo=nj_glo)
  if(rank.EQ.0) print*, "domain type = ", domain_type
  if(rank.EQ.0) print*, "domain size = ", ni_glo, "*", nj_glo

  ALLOCATE(lonvalue(ni_glo))
  ALLOCATE(latvalue(nj_glo))

  DO i=1,ni_glo
    lonvalue(i) = -180 + i * 360/ni_glo
  ENDDO

  DO j=1,nj_glo
    latvalue(j) = -90 + j * 180/nj_glo
  ENDDO

  CALL xios_set_domain_attr("domain_A", lonvalue_1d=lonvalue,latvalue_1d=latvalue)

  CALL xios_close_context_definition()

  ALLOCATE(field_A(ni_glo, nj_glo, axis_size))
  field_A(:,:,:)=rank

  DO ts=1,4
    CALL xios_update_calendar(ts)
    CALL xios_send_field("field_A", field_A)
  ENDDO

  CALL xios_context_finalize()

  DEALLOCATE(axis_value)
  DEALLOCATE(lonvalue, latvalue)
  DEALLOCATE(field_A)

  CALL MPI_COMM_FREE(comm, ierr)

  CALL xios_finalize()

  CALL MPI_FINALIZE(ierr)

END PROGRAM test_tp3

