#include "ncensemble.h"

/*----------------------------------------*/
/* functions to push entries onto linked lists of input and output files */

void add_output_file(char *fn, enum stats contents,
		     struct outfileinfo **list)
{
  struct outfileinfo *ptr,*p;

  ptr = xmalloc(sizeof(struct outfileinfo));
  ptr->name = fn;
  ptr->contents = contents;
  ptr->next = NULL;

  if (*list == NULL)
    *list = ptr;
  else {
    for (p = *list; p->next != NULL; p = p->next)
      ;
    p->next = ptr;
  }
}

void add_input_file(char *fn, int ensemble, int is_first_of_ensemble,
		    struct infileinfo **list)
{
  struct infileinfo *ptr,*p;

  ptr = xmalloc(sizeof(struct infileinfo));
  ptr->name = fn;
  ptr->ensemble = ensemble;
  ptr->is_first_of_ensemble = is_first_of_ensemble;
  ptr->next = NULL;

  if (*list == NULL)
    *list = ptr;
  else {
    for (p = *list; p->next != NULL; p = p->next)
      ;
    p->next = ptr;
  }
}


