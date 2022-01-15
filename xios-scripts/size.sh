#!/bin/bash

iter=18
curr="/home/n02/n02/lrpedro/test-git/netcdf-files/xios-scripts"

suite=$1

for (( c=0; c<=$iter; c++ ))
do
	if [[ $c -lt 10 ]]
	then
		ens="${suite}-ens0$c"
		echo "$ens"
		cd /home/n02/n02/lrpedro/cylc-run/$ens/work/19880901T0000Z/atmos_main
		ls -l |grep test | cut -d' ' -f 5,9 > t1
	else
		ens="$suite-ens$c"
		echo "$ens"
	fi
        
	dir="/home/n02/n02/lrpedro/cylc-run/${ens}/work/19880901T0000Z/atmos_main/"	
	echo $dir
	cd $dir
	echo -e "Suite, Netcdf File, Size, Size (bytes)" > aux-${ens}
	echo $ens > aux1
	ls -lh |grep test | cut -c 43-61 > aux2
	ls -lh |grep test | cut -c 25-30 > aux3
	ls -l |grep test | cut -c 25-35 > aux4
	paste -d ',' aux1 aux2 aux3 aux4 >> aux-${ens}

	total=0
	while IFS= read -r line
	do
#		total=$(echo "$total + $line" |bc)
		total=$(echo $total $line |awk '{print $1 + $2}')
#		echo $line
	done < aux4
	echo -e "$ens,,Total Size,$total\n" >> aux-${ens}

	rm aux1 aux2 aux3 aux4
	cp aux-$ens aux-$c
#	mv aux-$ens $curr
	mv aux-$c $curr
done

cd $curr
rm -rf size-$suite.csv
touch size-$suite.csv

for (( c=0; c<=$iter; c++ ))
do
	cat aux-$c >> size-$suite.csv
	rm aux-$c
done

