#include "ncensemble.h"

void usage(FILE *s)
{
  fprintf(s,
"\n  Usage"
"\n  %s <FLAGS> <INPUT FILES (ensemble 1)> [- <INPUT FILES (ensemble 2)>]"
"\n"
"\n  Calculate fields of statistics for ensembles of NetCDF files."
"\n  N.B. Requires input files to have identical structure."
"\n"
"\n  FLAGS include:"
"\n"
"\n   one or more of the following:"
"\n"
"\n     -m filename   output file for mean of ensemble 1"
"\n     -s filename   output file for s.d. of ensemble 1"
"\n     -M filename   output file for mean of ensemble 2"
"\n     -S filename   output file for s.d. of ensemble 2"
"\n     -a filename   output file for anomaly (ensemble 1 - ensemble 2)"
"\n     -t filename   output file for Student's t statistic on means"
"\n     -p filename   output file for one-tailed probability of t statistic"
"\n"
"\n     -h filename   output file for maximum of ensemble 1"
"\n     -H filename   output file for maximum of ensemble 2"
"\n     -l filename   output file for minimum of ensemble 1"
"\n     -L filename   output file for minimum of ensemble 2"
"\n"
"\n     (to remember the flags for max and min: h for highest, l for lowest)"
"\n"
"\n   and optionally:"
"\n"
"\n     -V  variables  comma-separated list of variables to process "
"\n                    (defaults to all variables)"
"\n"
"\n     -C  include also the coordinate variables related to the variables"
"\n         explicitly specified with -V (has no effect if -V is not used)"
"\n"
"\n     -v  verbose"
"\n     -c  permit clobbering (overwriting) of existing output files"
"\n"
"\n     -i  ignore mismatches in dims/vars between files [USE WITH CAUTION]"
"\n"
"\n  FOR EXAMPLE:"
"\n"
"\n    calculate mean and standard deviation for single ensemble:"
"\n"
"\n        %s -m mean.nc -s sd.nc \\"
"\n            member1.nc member2.nc member3.nc member4.nc"
"\n"
"\n    calculate anomaly and probability for two ensembles, writing only"
"\n     the variables \"temp\", \"ps\" and related coordinate variables to "
"\n     output file (and allowing output to overwrite existing files):"
"\n"
"\n        %s -c -a anom.nc -p prob.nc -V temp,ps -C \\"
"\n           pert1.nc pert2.nc pert3.nc pert4.nc - ctl1.nc ctl2.nc ctl3.nc"
"\n"
"\n        (NB mnemonic: think of the dash on the command line separating the"
"\n         two ensembles as ensemble1 'minus' ensemble2.  This will give the)"
"\n         correct sense for the anomaly.)"
"\n"
"\n",
  progname,progname,progname);
}

/*----------------------------------------*/
void error_exit(const char *msg)
{
  fprintf(stderr,"%s: *** ERROR *** : %s\n",progname,msg);
  exit(1);
}
