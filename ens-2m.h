netcdf ce262a_pc_2012092721-2012092723 {
dimensions:
	axis_nbounds = 2 ;
	lon = 96 ;
	lat = 72 ;
	ensemble = 2 ;
	time_counter = UNLIMITED ; // (1 currently)
variables:
	float lat(lat) ;
	float lon(lon) ;
	double time_instant(time_counter) ;
	double time_instant_bounds(time_counter, axis_nbounds) ;
	double time_counter(time_counter) ;
	double time_counter_bounds(time_counter, axis_nbounds) ;
	double time_centered(time_counter) ;
	double time_centered_bounds(time_counter, axis_nbounds) ;
	double m01s00i024(time_counter, ensemble, lat, lon) ;
	double m01s00i024_ens(time_counter, lat, lon) ;
	double sqav(time_counter, lat, lon) ;
	double ensq(time_counter, ensemble, lat, lon) ;
	double avensq(time_counter, lat, lon) ;
	float stdev(time_counter, lat, lon) ;
}
