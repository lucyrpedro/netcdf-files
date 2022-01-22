#include "ncensemble.h"

/*----------------------------------------*/

/* routines which do the stats */


#define CONVERT_CODE(TYPE)                            \
  {                                                   \
    TYPE z1;                                          \
    z1 = *((TYPE*) data + i);                         \
    missing = (miss != NULL && z1 == *(TYPE*)miss) ;  \
    if (! missing) z = (calctype) z1;                 \
  }                                                   \
 break;

void update_nums(int ensemble, struct nums *n)
{
  switch (ensemble) {
  case 1: n->nx++; break;
  case 2: n->ny++; break;
  default:
    error_exit("unrecognised ensemble (code bug?)");
  }
}

void update_sums(void *data, int ensemble, int is_first_of_ensemble,
		 struct sums *s, int ndata, void *miss, int xtype)
{
  int i, missing;
  calctype z = 0;
  struct sums *here;
  for (i = 0; i < ndata; i++) {
    here = &s[i];
    switch(xtype) {
      case NC_FLOAT:  CONVERT_CODE(float)
      case NC_DOUBLE: CONVERT_CODE(double)
      case NC_INT:    CONVERT_CODE(int)
      case NC_SHORT:  CONVERT_CODE(short)
      case NC_CHAR:   CONVERT_CODE(char)
      case NC_BYTE:   CONVERT_CODE(unsigned char)
      default: continue;
    }
    switch (ensemble) {
    case 1:
      if (missing)
	here->xmissing = 1;
      if (! here->xmissing) {
	here->sx += z;
	here->sxx += z * z;
	
	if (is_first_of_ensemble)
	  here->xmax = here->xmin = z;
	else {
	  if (z > here->xmax)
	    here->xmax = z;
	  if (z < here->xmin)
	    here->xmin = z;
	}
      }
      break;
    case 2:
      if (missing)
	here->ymissing = 1;
      if (! here->ymissing) {
	here->sy += z;
	here->syy += z * z;

	if (is_first_of_ensemble)
	  here->ymax = here->ymin = z;
	else {
	  if (z > here->ymax)
	    here->ymax = z;
	  if (z < here->ymin)
	    here->ymin = z;
	}
      }
      break;
    default:
      error_exit("unrecognised ensemble (code bug?)");
    }

  }
}

inline double safesqrt(double x)
{
  return (x<0) ? 0. : sqrt(x);
}

/* calc_stats calculates various statistics, as required
 * The supplied pointers are either arrays to be populated, or NULL
 * for things which are not requested.
 */
void calc_stats(struct sums *s, struct nums *n, int ndata, outtype omiss,
		outtype *xmean, outtype *xsd, 
		outtype *ymean, outtype *ysd,
		outtype *anom,  outtype *tm,  outtype *prob,
		outtype *xmin,  outtype *xmax,
		outtype *ymin,  outtype *ymax)
{
  int i;
  struct sums *here;

  /* Note: the initialisers (=0) are merely to silence warnings from
   * "gcc -O -Wall" that variables might be used uninitialised.  In fact 
   * the logic should ensure that variables are not used without first
   * being assigned in the executable code.
   */

  int dof=0;
  calctype
    xmean1 = 0, 
    ymean1 = 0,
    xsd1 = 0,
    ysd1 = 0,
    anom1 = 0,
    tm1 = 0,
    prob1 = 0,
    xmin1 = 0,
    xmax1 = 0,
    ymin1 = 0,
    ymax1 = 0,
    tmdenom;

  /* flags re which of above we need to calculate */
  int need_anom, need_xmean, need_xsd, need_ysd, need_ymean, need_tm,
    need_prob, need_xmin, need_xmax, need_ymin, need_ymax; 
  
  /* flags re whether statistics will be valid data, else use missing value */
  int
    valid_x = 0,
    valid_xsd = 0,
    valid_y = 0,
    valid_ysd = 0,
    valid_tm = 0;

  need_prob = (prob != NULL);
  need_tm = (tm != NULL || need_prob);
  need_anom = (anom != NULL || need_tm);
  need_xmean = (xmean != NULL || need_anom);
  need_ymean = (ymean != NULL || need_anom);
  need_xsd = (xsd != NULL);
  need_ysd = (ysd != NULL);

  need_xmin = (xmin != NULL);
  need_xmax = (xmax != NULL);
  need_ymin = (ymin != NULL);
  need_ymax = (ymax != NULL);

  if (need_tm)
    dof = (n->nx + n->ny - 2);

  for (i=0; i<ndata; i++) {
    here=&s[i];

    /*--------------------------------------------*/

    if (need_xmax || need_xmin || need_xmean || need_anom)
      valid_x = (! here->xmissing && n->nx >= 1);

    if (need_ymax || need_ymin || need_ymean || need_anom)
      valid_y = (! here->ymissing && n->ny >= 1);

    if (need_xsd || need_tm)
      valid_xsd = (! here->xmissing && n->nx >= 2);
      
    if (need_ysd || need_tm)
      valid_ysd = (! here->ymissing && n->ny >= 2);

    if (need_tm)
      valid_tm = (valid_xsd && valid_ysd);

    /*--------------------------------------------*/

    if (need_xmean)
      xmean1 = valid_x ? here->sx / n->nx : omiss;

    if (need_ymean)
      ymean1 = valid_y ? here->sy / n->ny : omiss;

    if (need_anom)
      anom1 = (valid_x && valid_y) ? xmean1 - ymean1 : omiss;

    if (need_xsd)
      xsd1 = 
	valid_xsd
	? safesqrt((here->sxx - here->sx * here->sx / n->nx) / (n->nx - 1))
	: omiss;      

    if (need_ysd)
      ysd1 = 
	valid_ysd
	? safesqrt((here->syy - here->sy * here->sy / n->ny) / (n->ny - 1))
	: omiss;      
    
    if (need_tm)  

      /* student's t statistic on means */
      tm1 = 
	
	/* if missing data, missing flag */
	(! valid_tm) ? omiss

	/* else if zero anomaly, zero */
	: (anom1==0) ? 0

	/* else, evaluate denominator */
	: ((tmdenom = safesqrt( (here->sxx - here->sx * here->sx / n->nx 
				 + here->syy - here->sy * here->sy / n->ny) 
				* (1. / n->nx + 1. / n->ny) / dof)) != 0) 

	/* if denominator non-zero, do division (THE USUAL CASE) */
	? anom1 / tmdenom

	/* otherwise, divide-by-zero cases (no intra-ensemble variability) */
	/* pos case */
	: (anom1 > 0) ? BIGT

	/* neg case */
	: -BIGT;

    if (need_prob)
      prob1 =
	(!valid_tm) ? omiss
	: (tm1 == BIGT) ? 1.0
	: (tm1 == -BIGT) ? 0.0
	: (tm1 == 0) ? 0.5
	: tprob(tm1, dof);

    /*--------------------------------------------*/

    /* max and min: nothing to calculate - just copy after checking that the data is valid
     */

    if (need_xmax) xmax1 = valid_x ? here->xmax : omiss;
    if (need_xmin) xmin1 = valid_x ? here->xmin : omiss;
    if (need_ymax) ymax1 = valid_y ? here->ymax : omiss;
    if (need_ymin) ymin1 = valid_y ? here->ymin : omiss;
    
    /*----------------------------------------*/
    
    if (xmean != NULL) xmean[i] = xmean1;
    if (ymean != NULL) ymean[i] = ymean1;
    if (xsd   != NULL) xsd  [i] = xsd1;
    if (ysd   != NULL) ysd  [i] = ysd1;
    if (anom  != NULL) anom [i] = anom1;
    if (tm    != NULL) tm   [i] = tm1;
    if (prob  != NULL) prob [i] = prob1;
    
    if (xmin != NULL) xmin[i] = xmin1;
    if (xmax != NULL) xmax[i] = xmax1;
    if (ymin != NULL) ymin[i] = ymin1;
    if (ymax != NULL) ymax[i] = ymax1;
  }
}
