#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <netcdf.h>
#include <stdarg.h>
#include <math.h>

/* --------------------*/
/* these are related */
#define NSTATS 11
enum stats {
  S_XMEAN = 0,
  S_XSTDDEV = 1,
  S_YMEAN = 2,
  S_YSTDDEV = 3,
  S_ANOM = 4,
  S_T = 5,
  S_PROB = 6,
  S_XMIN = 7,
  S_XMAX = 8,
  S_YMIN = 9,
  S_YMAX = 10
};
/* descriptions - list here for easy maintenance, but only include in main.c */
#ifdef _MAIN_C
static const char* descrips[] = {"mean of 1st ensemble",
				 "s.d. of 1st ensemble",
				 "mean of 2nd ensemble",
				 "s.d. of 2nd ensemble",
				 "anomaly (1st - 2nd ensemble)",
				 "Student t value (1st - 2nd ensemble)",
				 "one-tailed probability of t value",
				 "minimum of 1st ensemble",
				 "maximum of 1st ensemble",
				 "minimum of 2nd ensemble",
				 "maximum of 2nd ensemble"};
#endif
/* --------------------*/

/*---------------------------------------*/
/* these choices are related */
typedef float outtype;
static const nc_type nc_outtype = NC_FLOAT;
static const outtype missing_default = 1e30;
#define NC_PUT_ATT_OUT nc_put_att_float
/*---------------------------------------*/

/* ----- for use in calc_stats ------- */
/* value of Student's t, when there is no in-sample variance */
#define BIGT 1e10
/*----------------------------------- */


/* -------- for use in tprob -------- 
 * The following defines were used with a version of tprob.c based on
 * Numerical Recipes.  That source code could not be distributed for copyright
 * reasons, so has been replaced with other code.  These defines are left in
 * for personal convenience if I want to use the NR routine again.
 * They can be removed if wanted.
 */
#define FPMIN   1.0E-60
#define ITMAX       300
#define EPSILON  3.E-12
/*----------------------------------- */

typedef double calctype; /* type for internal calculations */

struct infileinfo
{
  int ncid;
  char *name;
  int ensemble;
  int is_first_of_ensemble;
  struct infileinfo *next;
};

struct outfileinfo
{
  int ncid;
  char *name;
  enum stats contents;
  struct outfileinfo *next;
};

struct diminfo
{
  int len;
  char *name;
  int id_out;
  int iswanted;
};

struct varinfo
{
  int *dimids;
  int *dimids_out;
  char *name;
  nc_type type;
  int natts;
  int ndims;
  int ndata;
  void *miss;
  nc_type otype;
  outtype omiss;
  int iscoord;
  int id_out;
  int iswanted;
};

/* struct for sums which are function of position */
struct sums
{
  calctype sx;
  calctype sxx;
  calctype sy;
  calctype syy;
  short xmissing;
  short ymissing;
  calctype xmin;
  calctype xmax;
  calctype ymin;
  calctype ymax;
};

/* scalars */
struct nums
{
  int nx;
  int ny;
};

char *progname;
int verbose;

/* prototypes */
void *xmalloc(size_t);
void *xstrdup(const char *);
void *xcalloc(size_t, size_t);
void usage(FILE *);
void error_exit(const char *);
void add_output_file(char *, enum stats, struct outfileinfo **);
void add_input_file(char *, int, int, struct infileinfo **);

void update_nums(int, struct nums *);
void update_sums(void *, int, int, struct sums *, int, void *, int);

int size_of_nc_type(nc_type);
void _(int, int,...);

void calc_stats(struct sums *, struct nums *, int, outtype,
		outtype *, outtype *, 
		outtype *, outtype *,
		outtype *, outtype *,  outtype *,
		outtype *, outtype *,
		outtype *, outtype *);

double tprob(double, int);
