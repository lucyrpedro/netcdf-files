#!/bin/bash

iter=18
curr="/home/n02/n02/lrpedro/test-git/netcdf-files/xios-scripts"

ls -l |grep test | cut -d' ' -f 5,9 > t1

dir1="u-ch427-n96-max18-ens"
dir2="u-ch427-n96-max18-mf-ens"
dir3="u-ch427-n96-max18-single-ens"

for (( c=1; c<=$iter; c++ ))
do
	if [[ $c -lt 10 ]]
	then
		dir4="${dir1}0$c"
		echo "$dir4"
		cd /home/n02/n02/lrpedro/cylc-run/$dir4/work/19880901T0000Z/atmos_main
		ls -l |grep test | cut -d' ' -f 5,9 > t1
	else
		dir4="$dir1$c"
		echo "$dir1"
	fi
        
	dir="/home/n02/n02/lrpedro/cylc-run/${dir4}/work/19880901T0000Z/atmos_main/"	
	echo $dir
	cd $dir
	echo $dir4 > aux0
	ls -lh |grep test | cut -c 43-61 > aux1
	ls -lh |grep test | cut -c 25-30 > aux2
	ls -l |grep test | cut -c 25-35 > aux3
	paste -d ',' aux0 aux1 aux2 aux3 > aux-${dir4}
	rm aux0 aux1 aux2 aux3
	cp aux-$dir4 aux-$c
	mv aux-$dir4 $curr
	mv aux-$c $curr
done

cd $curr
touch file

for (( c=1; c<=$iter; c++ ))
do
	cat aux-$c >> file
done
