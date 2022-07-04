#!/bin/bash

iter=9
curr="/home/n02/n02/lrpedro/test-git/netcdf-files/xios-scripts"

suite=$1

for (( c=0; c<=$iter; c++ ))
do
	ens="${suite}-x$c"
	echo "$ens"
        
	dir="/home/n02/n02/lrpedro/cylc-run/${ens}/work/19790301T0000Z/atmos_main/"	
	echo $dir
	cd $dir
	echo -e "Suite, Netcdf File, Size, Size (bytes)" > aux-$c
	echo $ens > aux1
	ls -lh |grep test | cut -c 43-61 > aux2
	ls -lh |grep test | cut -c 25-30 > aux3
	ls -s1 |grep test | awk '{print $1}' > aux4
	paste -d ',' aux1 aux2 aux3 aux4 >> aux-$c

	total=0
	while IFS= read -r line
	do
		total=$(echo $total $line |awk '{print $1 + $2}')
	done < aux4

	echo -e "$ens,,Total Size,$total\n" >> aux-$c
        echo -e "Total Size,$ens,$c,$total" > total-$c

	rm aux1 aux2 aux3 aux4
	mv aux-$c $curr
	mv total-$c $curr
done

cd $curr
rm -rf size-$suite.csv
rm -rf total-$suite.csv
touch size-$suite.csv
touch total-$suite.csv

for (( c=0; c<=$iter; c++ ))
do
	cat aux-$c >> size-$suite.csv
	cat total-$c >> total-$suite.csv
	rm aux-$c
	rm total-$c
done

