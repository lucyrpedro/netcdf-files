/*
 *  FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME 
 *
 *  ~600 lines of code in main() -- needs splitting up.
 * 
 *  FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME 
 *
 */ 

#define _MAIN_C
#include "ncensemble.h"

int main(int argc, char **argv)
{
  /* ncdf dims */
  struct diminfo *diminfo, *d;
  int idim, ndims, unlim_dimid, *vdimids_check, unlimno, dimid;

  /* ncdf vars */
  struct varinfo *varinfo, *v;
  int ivar, nvars, nvatts, nvdims;

  /* ncdf atts */
  int iatt, natts;
  const char *missname = "missing_value";

  /* misc for ncdf access */
  int ref_ncid;
  int clobber;
  size_t *start, *count;
  nc_type xtype;
  char name[NC_MAX_NAME+1], *ref_name;
  size_t len;

  /* misc for calculation */
  int mismatch;
  int used_missing_default;
  int niter, narray, iter;

  /* for stats */
  int num;
  int requested[NSTATS], istat;
  int ensemble;
  void *data, *odata;
  outtype *xmean, *xsd, *ymean, *ysd, *anom, *tm, *prob, *xmin, *xmax, *ymin, *ymax;
  struct sums *sums;
  struct nums nums;

  /* for files */
  struct infileinfo *fin, *in;
  struct outfileinfo *fout, *out;
  int is_first_of_ensemble;

  /* for option parsing */
  const char *optstr = "m:M:s:S:a:t:p:l:h:L:H:V:Cvci";
  extern char *optarg;
  extern int optind, opterr, optopt;
  int iopt, opt;

  /* for variable subsetting */
  char *var_list;
  char *varname, *seppos;
  int namelength, length;
  int add_coords;

  /* misc other */
  int ignore_errors;

  /*=================================================*/

  /* parse input ... */

  progname = argv[0];
  
  if (argc == 1) {
    usage(stdout);
    exit(0);
  }

  clobber = 0;
  verbose = 0;
  ignore_errors = 0;
  add_coords = 0;
  var_list = NULL;
  fin = NULL;
  fout = NULL;
  while ((opt = getopt(argc, argv, optstr)) != -1) {
    switch (opt) {
    case 'm': add_output_file(optarg, S_XMEAN, &fout); break;     
    case 's': add_output_file(optarg, S_XSTDDEV, &fout); break;
    case 'M': add_output_file(optarg, S_YMEAN, &fout); break;     
    case 'S': add_output_file(optarg, S_YSTDDEV, &fout); break;
    case 'a': add_output_file(optarg, S_ANOM, &fout); break;     
    case 't': add_output_file(optarg, S_T, &fout); break;
    case 'p': add_output_file(optarg, S_PROB, &fout); break;
    case 'l': add_output_file(optarg, S_XMIN, &fout); break;
    case 'h': add_output_file(optarg, S_XMAX, &fout); break;
    case 'L': add_output_file(optarg, S_YMIN, &fout); break;
    case 'H': add_output_file(optarg, S_YMAX, &fout); break;
    case 'V': var_list = optarg; break;
    case 'C': add_coords = 1; break;
    case 'v': verbose = 1; break;
    case 'c': clobber = 1; break;
    case 'i': ignore_errors = 1; break;
    case '?': usage(stderr); error_exit("unrecognised flag specified");
    }
  }
  ensemble = 1;
  is_first_of_ensemble = 1;
  for (iopt = optind; iopt < argc; iopt++) {
    if (!strcmp(argv[iopt], "-") && ensemble == 1) {
      ensemble = 2;
      is_first_of_ensemble = 1;
    }
    else {
      add_input_file(argv[iopt], ensemble, is_first_of_ensemble, &fin);    
      is_first_of_ensemble = 0;
    }
  }

  if (verbose) {
    printf("Input files:\n");
    for (in = fin; in; in = in->next)
      printf(" name: %s, ensemble %d\n", in->name, in->ensemble);
    printf("Output files:\n");
    for (out = fout; out; out = out->next)
      printf(" name: %s, contents %s\n", out->name, descrips[out->contents]);
  }

  if (fin == NULL) {
    usage(stderr);
    error_exit("No input files specified!");
  }
  if (fout == NULL) {
    usage(stderr);
    error_exit("No output files specified!");
  }

  /* calculate totals in each ensemble */
  nums.nx = nums.ny = 0;
  for (in = fin; in; in = in->next)
    update_nums(in->ensemble, &nums);

  /* make list of which statistics are wanted */
  for (istat = 0; istat < NSTATS; istat++)
    requested[istat] = 0;
  for (out = fout; out; out = out->next)
    requested[out->contents] = 1;

  /* open files */
  for (in = fin; in ; in = in->next)
    _(nc_open(in->name, 0, &in->ncid), 1, in->name);
  for (out = fout; out; out = out->next)
    _(nc_create(out->name, 
		clobber ? 0 : NC_NOCLOBBER,
		&out->ncid), 2, "nc_create", out->name);

  ref_ncid = fin->ncid;
  ref_name = xstrdup(fin->name);

  /* inquire from first input file */

  _(nc_inq(ref_ncid, &ndims, &nvars, &natts, &unlim_dimid), 1, "nc_inq");
  
  /* copy global attributes */

  for (iatt = 0; iatt < natts; iatt++) {
    _(nc_inq_attname(ref_ncid, NC_GLOBAL, iatt, name), 1, "nc_inq_attname");

    for (out = fout; out; out = out->next)
      _(nc_copy_att(ref_ncid, NC_GLOBAL, name, out->ncid, NC_GLOBAL),
	1, "nc_copy_att");
  }

  /* add global attributes re ensemble sizes */
  for (out = fout; out; out = out->next) {
    switch (out->contents){
    case S_XMIN:
    case S_XMAX:
    case S_XMEAN:
    case S_XSTDDEV:
      num = nums.nx;
      nc_put_att_int(out->ncid, NC_GLOBAL, "ensemble_size", NC_INT, 1, &num);
      break;
    case S_YMIN:
    case S_YMAX:
    case S_YMEAN:
    case S_YSTDDEV:
      num = nums.ny;
      nc_put_att_int(out->ncid, NC_GLOBAL, "ensemble_size", NC_INT, 1, &num);
      break;
    case S_T:
    case S_PROB:
      num = nums.nx + nums.ny - 2;
      nc_put_att_int(out->ncid, NC_GLOBAL, "degrees_of_freedom", 
		     NC_INT, 1, &num);     
      /* FALLTHROUGH */
    case S_ANOM:
      num = nums.nx;
      nc_put_att_int(out->ncid, NC_GLOBAL, "ensemble_size_1", NC_INT, 1, &num);
      num = nums.ny;
      nc_put_att_int(out->ncid, NC_GLOBAL, "ensemble_size_2", NC_INT, 1, &num);
      break;
    }
  }

  /* setup dimensions */
  diminfo = xmalloc(ndims * sizeof(struct diminfo));

  for (idim = 0; idim < ndims; idim++){

    d = &diminfo[idim];

    /* dim info */
    _(nc_inq_dim(ref_ncid, idim, name, &len), 1, "nc_inq_dim");

    /* store dimension name, size */
    d->len = len;
    d->name = xstrdup(name);

    /* check dimension agrees across other input files */
    for (in = fin; in; in = in->next) {
      _(nc_inq_dim(in->ncid, idim, name, &len),
	1, "nc_inq_dim");
      if (len != d->len || strcmp(name, d->name)) {
	fprintf(stderr,
		"Discrepancy in dimension \"%s\" between %s and %s\n",
		name, ref_name, in->name);
	if (!ignore_errors)
	  error_exit("Input files must have identical dimensions");
      }
    }

    /* initialise dim wanted to 0 - will be set if vars are wanted */
    d->iswanted = 0;
  }

  /* now start to setup variables, up to the point of knowing what variables are wanted... */

  varinfo = xmalloc(nvars * sizeof(struct varinfo));

  for (ivar = 0; ivar < nvars; ivar++){

    /* var info */
    v = &varinfo[ivar];

    _(nc_inq_varndims(ref_ncid, ivar, &nvdims), 1, "nc_inq_varndims");
    
    v->dimids = xmalloc(ndims * sizeof(int));
    v->dimids_out = xmalloc(ndims * sizeof(int));

    _(nc_inq_var(ref_ncid, ivar, name, &xtype, &nvdims, v->dimids, &nvatts),
      1, "nc_inq_var");

    v->type = xtype;
    v->otype = xtype;
    v->natts = nvatts;
    v->ndims = nvdims;
    v->name = xstrdup(name);
    
    v->ndata = 1;
    for (idim = 0; idim < v->ndims; idim++)
      v->ndata *= diminfo[v->dimids[idim]].len;

    /* A coordinate is a 1-d variable whose dimension name matches the 
     * variable name */
    v->iscoord = (v->ndims == 1 && 
		     !strcmp(v->name, diminfo[v->dimids[0]].name));

    /* Decide whether the variable is actually wanted */

    if (var_list == NULL)
      v->iswanted = 1;
    else {

      namelength = strlen(v->name);

      v->iswanted = 0;

      /* scan through the wanted list */
      for (varname = var_list-1; varname != NULL; varname = seppos) {

	varname++;
	seppos = index(varname, ',');
	length = (seppos == NULL) ? strlen(varname) : seppos - varname;	

	/* See if var is on the "wanted" list. 
	 * string is not null-terminated, so don't use strncmp;
	 * compare lengths and, if equal, first n characters
	 */
	if (length == namelength && !strncmp(v->name, varname, length)) {
	  v->iswanted = 1;
	  break; /* from this little for loop (wanted list) */
	}
      }
    }
    /* if it is not wanted, then go onto the next var */
    if (!v->iswanted)
      continue; 

    /* ensure that corresponding dims are marked as wanted */
    for (idim = 0; idim < v->ndims; idim++)
      diminfo[v->dimids[idim]].iswanted = 1;

  }

  /* now, if requested, add to the wanted variables list any coordinate 
   * variables for dimensions which are wanted
   */
  if (var_list != NULL && add_coords)
    for (ivar = 0; ivar < nvars; ivar++){
      v = &varinfo[ivar];
      if (v->iscoord && diminfo[v->dimids[0]].iswanted)
	v->iswanted = 1;
    }
  
  /* now define the dimensions which are wanted */
  for (idim = 0; idim < ndims; idim++){
    d = &diminfo[idim];
    if (d->iswanted) {
      /* define dim in output file */
      len = (idim == unlim_dimid) ? NC_UNLIMITED : d->len;
      for (out = fout; out; out = out->next)
	_(nc_def_dim(out->ncid, d->name, len, &d->id_out),
	  1, "nc_def_dim");
    }
  }


  /* now continue with setting up the variables */

  for (ivar = 0; ivar < nvars; ivar++){
    v = &varinfo[ivar];

    /* if it is not wanted, then go onto the next var */
    if (!v->iswanted)
      continue; 
    
    /* set up output dim IDs */
    for (idim = 0; idim < v->ndims; idim++)
      v->dimids_out[idim] = diminfo[v->dimids[idim]].id_out;    

    /* store input missing_data value */
    if (nc_inq_att(ref_ncid, ivar, missname, &xtype, &len) == NC_NOERR
	&& len == 1 
	&& xtype == v->type) {      
      v->miss = xmalloc(size_of_nc_type(xtype));
      switch(xtype){
      case NC_FLOAT:
	_(nc_get_att_float (ref_ncid, ivar, missname, v->miss), 0);
	break;
      case NC_DOUBLE:
	_(nc_get_att_double(ref_ncid, ivar, missname, v->miss), 0);
	break;
      case NC_INT:   
	_(nc_get_att_long  (ref_ncid, ivar, missname, v->miss), 0);
	break;
      case NC_SHORT: 
	_(nc_get_att_short (ref_ncid, ivar, missname, v->miss), 0);
	break;
      case NC_CHAR:  
	_(nc_get_att_text  (ref_ncid, ivar, missname, v->miss), 0);
	break;
      case NC_BYTE:  
	_(nc_get_att_schar (ref_ncid, ivar, missname, v->miss), 0);
	break;
      default: v->miss = NULL;
      }
    } 
    else {
      v->miss = NULL;
    }
    /* sort out output type and missing data value for output files */    
    used_missing_default = 0;
    if (v->iscoord) {
      /* Coordinate: output will just be copy of input */
      v->otype = v->type;
    } else {
      /* Output will be FLOAT */
      v->otype = nc_outtype;
      
      /* If we have a missing-data value of correct type, use it.
       * Else use default. */
      if (v->type == v->otype && v->miss != NULL)
	v->omiss = *(outtype*) (v->miss);
      else {
	v->omiss = missing_default;
	used_missing_default = 1;
      }
    }
    
    /* check agreement across input files */
    vdimids_check = xmalloc(ndims * sizeof(int));
    mismatch = 0;
    for (in = fin; in ; in = in->next) {
      _(nc_inq_varndims(in->ncid, ivar, &nvdims), 1, "nc_inq_varndims");
      if (nvdims == v->ndims) {
	_(nc_inq_var(in->ncid, ivar, name, &xtype, &nvdims, vdimids_check, &nvatts)
	  ,0);
	for (idim = 0; idim < nvdims; idim++)
	  if (vdimids_check[idim] != v->dimids[idim])
	    mismatch = 1;
	if (strcmp(name, v->name) || xtype != v->type)
	  mismatch = 1;
      }
      else {
	mismatch = 1;
      }
      if (mismatch) {
	fprintf(stderr,
		"Discrepancy in variable \"%s\" between %s and %s\n",
		name, ref_name, in->name);	
	if (!ignore_errors)
	  error_exit("Files must have identical variables\n");
      }
    }
    free(vdimids_check);

    /* define variable in output files */
    /* NB varid is same in all output files - just end up with val from last loop iter */
    for (out = fout; out; out = out->next)
      _(nc_def_var(out->ncid, v->name, v->otype, v->ndims,
		   v->dimids_out, &v->id_out),
	1, "nc_def_var");

    /* copy variable attributes, except certain cases */
    for (iatt = 0; iatt < v->natts; iatt++) {
      _(nc_inq_attname(ref_ncid, ivar, iatt, name), 1, "nc_inq_attname");
      
      if (!strcmp(name, "units"))
	/* units - write unless contents is T value or probability 
	 * but for coordinate variables, there is no processing, so do not suppress units
	 */	
	for (out = fout; out; out = out->next) {
	  if (v->iscoord || (out->contents != S_T && out->contents != S_PROB))
	    _(nc_copy_att(ref_ncid, ivar, name, out->ncid, v->id_out),
	      1, "nc_copy_att");
	}
      else if (!(
		 !strcmp(name, "valid_min") ||
		 !strcmp(name, "valid_max") ||
		 (v->type != v->otype && (!strcmp(name, "missing_value") 
					  || !strcmp(name, "_FillValue"))))
	       )
	for (out = fout; out; out = out->next)
	  _(nc_copy_att(ref_ncid, ivar, name, out->ncid, v->id_out),
	    1, "nc_copy_att");
    }

    /* supply missing value attribute if default was used */
    if (used_missing_default)
      for (out = fout; out; out = out->next)
	_(NC_PUT_ATT_OUT(out->ncid, v->id_out, "missing_value", v->otype, 1, &v->omiss),
	  1, "nc_put_att_");
  }
  /* finish define mode in output files */
  for (out = fout; out; out = out->next)
    _(nc_enddef(out->ncid), 1, "nc_enddef");

  /* now loop over variables, doing calculations
   * if a variable has the record dimension as one of its dims, then loop over
   * this (to reduce memory size), otherwise read it all in at once.
   */

  for (ivar = 0; ivar < nvars; ivar++){
    v = &varinfo[ivar];

    if (!v->iswanted)
      continue;

    if (verbose) {
      if (v->iscoord)
	printf("Copying coordinate variable %s\n", v->name);
      else
	printf("Calculating stats for variable %s\n", v->name);
    }

    start = xcalloc(v->ndims, sizeof(size_t));
    count = xcalloc(v->ndims, sizeof(size_t));
	
    unlimno = -1;
    for (idim = 0; idim < v->ndims; idim++) {
      dimid = v->dimids[idim];
      start[idim] = 0;
      count[idim] = diminfo[dimid].len;
      if (dimid == unlim_dimid)
	unlimno = idim;
    }

    if (unlimno == -1) {
      niter = 1;
      narray = v->ndata;
    }
    else {
      niter = count[unlimno];
      narray = v->ndata / niter;
      count[unlimno] = 1;
    }

    data = xcalloc(narray, size_of_nc_type(v->type));
    sums = xcalloc(narray, sizeof(struct sums));

    xmean = requested[S_XMEAN]   ? xcalloc(narray, sizeof(outtype)) : NULL;
    xsd   = requested[S_XSTDDEV] ? xcalloc(narray, sizeof(outtype)) : NULL;
    ymean = requested[S_YMEAN]   ? xcalloc(narray, sizeof(outtype)) : NULL;
    ysd   = requested[S_YSTDDEV] ? xcalloc(narray, sizeof(outtype)) : NULL;
    anom  = requested[S_ANOM]    ? xcalloc(narray, sizeof(outtype)) : NULL;
    tm    = requested[S_T]       ? xcalloc(narray, sizeof(outtype)) : NULL;
    prob  = requested[S_PROB]    ? xcalloc(narray, sizeof(outtype)) : NULL;
    xmin  = requested[S_XMIN]    ? xcalloc(narray, sizeof(outtype)) : NULL;
    xmax  = requested[S_XMAX]    ? xcalloc(narray, sizeof(outtype)) : NULL;
    ymin  = requested[S_YMIN]    ? xcalloc(narray, sizeof(outtype)) : NULL;
    ymax  = requested[S_YMAX]    ? xcalloc(narray, sizeof(outtype)) : NULL;

    for (iter = 0; iter < niter; iter++) {

      memset(sums, 0, narray * sizeof(struct sums));

      if (unlimno != -1)
	start[unlimno] = iter;

      /* read variable */

      for (in = fin; in ; in = in->next) {
	switch(v->type){
	case NC_FLOAT: 
	  _(nc_get_vara_float (in->ncid, ivar, start, count, data), 0);
	  break;
	case NC_DOUBLE:
	  _(nc_get_vara_double(in->ncid, ivar, start, count, data), 0);
	  break;
	case NC_INT:   
	  _(nc_get_vara_long  (in->ncid, ivar, start, count, data), 0);
	  break;
	case NC_SHORT: 
	  _(nc_get_vara_short (in->ncid, ivar, start, count, data), 0);
	  break;
	case NC_CHAR:  
	  _(nc_get_vara_text  (in->ncid, ivar, start, count, data), 0);
	  break;
	case NC_BYTE:  
	  _(nc_get_vara_schar (in->ncid, ivar, start, count, data), 0);
	  break;
	default: error_exit("unrecognised data type found");
	}

	/* coord vars only need to be read in for the first file */
	if (v->iscoord)
	  break;

	update_sums(data, in->ensemble, in->is_first_of_ensemble,
		    sums, narray, v->miss, v->type);
      }

      /* do stats except for coordinate variables */

      if (!v->iscoord)
	calc_stats(sums, &nums, narray, v->omiss,
		   xmean, xsd, ymean, ysd, anom, tm, prob, xmin, xmax, ymin, ymax);
      
      /* write calc result to output files */
      for (out = fout; out; out = out->next) {

	if (v->iscoord)
	  odata = data;
	else {
	  switch(out->contents){
	  case S_XMEAN: odata = xmean; break;
	  case S_XSTDDEV: odata = xsd; break;
	  case S_YMEAN: odata = ymean; break;
	  case S_YSTDDEV: odata = ysd; break;
	  case S_ANOM: odata = anom; break;
	  case S_T: odata = tm; break;
	  case S_PROB: odata = prob; break;
	  case S_XMIN: odata = xmin; break;
	  case S_XMAX: odata = xmax; break;
	  case S_YMIN: odata = ymin; break;
	  case S_YMAX: odata = ymax; break;
	  default: continue;
	  }
	}
	switch(v->otype){
	case NC_FLOAT: 
	  _(nc_put_vara_float (out->ncid, v->id_out, start, count, odata), 0);
	  break;
	case NC_DOUBLE:
	  _(nc_put_vara_double(out->ncid, v->id_out, start, count, odata), 0);
	  break;
	case NC_INT:   
	  _(nc_put_vara_long  (out->ncid, v->id_out, start, count, odata), 0);
	  break;
	case NC_SHORT: 
	  _(nc_put_vara_short (out->ncid, v->id_out, start, count, odata), 0);
	  break;
	case NC_CHAR:  
	  _(nc_put_vara_text  (out->ncid, v->id_out, start, count, odata), 0);
	  break;
	case NC_BYTE:  
	  _(nc_put_vara_schar (out->ncid, v->id_out, start, count, odata), 0);
	  break;
	default: error_exit("unrecognised data type to write");
	}      
      }
    }
    free(data);
    free(sums);
    if (requested[S_XMEAN]  ) free(xmean);
    if (requested[S_XSTDDEV]) free(xsd);
    if (requested[S_YMEAN]  ) free(ymean);
    if (requested[S_YSTDDEV]) free(ysd);
    if (requested[S_ANOM]   ) free(anom);
    if (requested[S_T]      ) free(tm);
    if (requested[S_PROB]   ) free(prob);
    
    free(start);
    free(count);
  }  

  /* close files */

  for (in = fin; in ; in = in->next)
    _(nc_close(in->ncid), 0);

  for (out = fout; out; out = out->next)
    _(nc_close(out->ncid), 0);

  return 0;
}
