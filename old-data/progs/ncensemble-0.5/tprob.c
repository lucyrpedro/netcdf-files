
/*
 * A C version of the code from Statlib that calculates one-tailed
 * probability values for Student's t distribution.
 *
 * Fortran original subject to the copyright statement:
 *
 *   "The Royal Statistical Society holds the copyright to these routines,
 *    but has given its permission for their distribution provided that
 *    no fee is charged."
 * 
 * See: http://lib.stat.cmu.edu/apstat/
 *      http://lib.stat.cmu.edu/apstat/3
 *
 * C translation by Alan Iwi <A.M.Iwi@rl.ac.uk>
 *
 */

#include <math.h>

/* math.h should define M_PI and M_1_PI, but in case not: */
#ifndef M_1_PI
#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif
#define M_1_PI 1/M_PI
#endif

double tprob(double t, int idf) {

  double a, b, c, f, fk, s;
  int im2, ioe, ks, k;

  if (idf < 1) return -1; /* error condition */

  f = idf; /* cast to double */
  a = t / sqrt(f);
  b = f / (f + t*t);
  im2 = idf - 2;
  ioe = idf % 2;
  s = c = f = 1.;
  ks = 2 + ioe;
  fk = ks;
  if (im2 >= 2) {
    for (k = ks; k <= im2; k+=2) {
      c *= b * (1. - 1. / fk);
      s += c;
      if (s == f) break;
      f = s;
      fk += 2.;
    }
  }
  if (ioe != 1)
    return 0.5 + 0.5 * a * sqrt(b) * s;

  if (idf == 1) s = 0.;
 
  return 0.5 + (a * b * s + atan(a)) * M_1_PI;  
}
