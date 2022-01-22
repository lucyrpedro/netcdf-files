#include "ncensemble.h"

/*----------------------------------------*/
/* versions of memory allocation functions which 
 * abort on failure so no need to test for success */

static void nomem()
{
  error_exit("Out of memory");
}

void *xmalloc(size_t size)
{
  void *ptr = malloc(size);
  if (ptr == NULL) nomem();
  return ptr;
}
void *xstrdup(const char *s)
{
  char *ptr = strdup(s);
  if (ptr == NULL) nomem();
  return ptr;
}
void *xcalloc(size_t nmemb, size_t size)
{
  void *ptr = calloc(nmemb,size);
  if (ptr == NULL) nomem();
  return ptr;
}
