#!/bin/bash

curr="/home/n02/n02/lrpedro/test-git/netcdf-files/xios-scripts/aux"

ens=$1

dir="/home/n02/n02/lrpedro/cylc-run/${ens}/work/19880901T0000Z/atmos_main/"	
echo $dir
if [[ -s "${dir}" ]]; then
	cd $dir
	echo -e "Suite, Netcdf File, Size, Size (bytes)" > aux-$ens
	echo $ens > aux1
	ls -lh |grep nc | cut -c 43-61 > aux2
	ls -lh |grep nc | cut -c 25-30 > aux3
	ls -s1 |grep nc | awk '{print $1}' > aux4
	paste -d ',' aux1 aux2 aux3 aux4 >> aux-$ens

	total=0
	while IFS= read -r line
	do
		total=$(echo $total $line |awk '{print $1 + $2}')
	done < aux4

	echo -e "$ens,,Total Size,$total\n" >> aux-$ens
	echo -e "Total Size,$ens,$((total/(1024*1024)))GB,$total" > total-$ens

	rm aux1 aux2 aux3 aux4
	mv aux-$ens $curr
	mv total-$ens $curr

	cd $curr
	rm -rf size-${ens}.csv
	rm -rf total-${ens}.csv
	touch size-${ens}.csv
	touch total-${ens}.csv

	cat aux-${ens} >> size-${ens}.csv
	cat total-${ens} >> total-${ens}.csv
	rm aux-$ens
	rm total-$ens

fi
