#!/bin/bash

aux=~/test-git/netcdf-files/xios-scripts

cd ~/cylc-run
ls -1 > ${aux}/aux-files/dir.txt

input=${aux}/aux-files/dir.txt
	
cd ${aux}/results

while IFS= read -r line
do
	mkdir -p $line
        cp ~/cylc-run/${line}/work/19790301T0000Z/atmos_main/pe_output/*pe.stdout ${line} 2>/dev/null
	cp ~/cylc-run/${line}/work/19790301T0000Z/atmos_ens0/pe_output/*pe.stdout ${line} 2>/dev/null
	cp ~/cylc-run/${line}/work/19790301T0000Z/atmos_ens0/xios_client_000.out ${line} 2>/dev/null
	cp ~/cylc-run/${line}/log/job/19790301T0000Z/atmos_main/NN/job.status ${line} 2>/dev/null
        cp ~/cylc-run/${line}/log/job/19790301T0000Z/atmos_main/NN/job ${line} 2>/dev/null
	filename=$(ls ${line} |grep pe)
#	echo $line
	echo $filename
done < "$input"

