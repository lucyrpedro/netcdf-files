#include "ncensemble.h"

/* generic exit status tester for netcdf routines */
void _(int status, int n, ...)
{
  va_list ap;
  char *msg;

  if (status != NC_NOERR) {
    va_start(ap, n);
    fprintf(stderr, "%s: ", progname);      
    while (n--) {
      msg=va_arg(ap, char *);
      fprintf(stderr, "%s: ", msg);      
    }
    fprintf(stderr, "%s\n", nc_strerror(status));
    va_end(ap);
    exit(1);
  }
}

int size_of_nc_type(nc_type xtype)
{
  switch(xtype){
  case NC_FLOAT: return 4;
  case NC_DOUBLE:return 8;
  case NC_INT:   return 4;
  case NC_SHORT: return 2;
  case NC_CHAR:  return 1;
  case NC_BYTE:  return 1;
  default: return 0;
  }
}
