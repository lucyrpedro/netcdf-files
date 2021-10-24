#!/bin/bash

aux=~/test-git/netcdf-files/xios-scripts

cd ~/cylc-run
ls -1 > ${aux}/aux-files/dir.txt

input=${aux}/aux-files/dir.txt
	
rm -rf ${aux}/results
mkdir -p ${aux}/results
cd ${aux}/results

while IFS= read -r line
do
	mkdir -p $line
	cp ~/cylc-run/${line}/work/19880901T0000Z/atmos_ens0/pe_output/*pe.stdout ${line} 2>/dev/null
	cp ~/cylc-run/${line}/work/19880901T0000Z/atmos_ens0/xios_client_000.out ${line} 2>/dev/null
	cp ~/cylc-run/${line}/log/job/19880901T0000Z/atmos_main/NN/job.status ${line} 2>/dev/null
	filename=$(ls ${line} |grep pe)
	echo $line
	echo $filename
done < "$input"

aux2=~/test-git/netcdf-files/xios-scripts/results

while IFS= read -r line
do
	filename=$(ls ${aux2}/${line} |grep pe)
        echo "line=$line"
        echo "file=$filename"
	cd ${aux2}/${line}
	if [[ -s "${filename}" ]]; then
		echo "aux=${filename}"
		echo $(cat ${filename} |grep "Elapsed Wallclock Time") > time.txt		
		echo $(cat ${filename} |grep " INITIAL ") >> time.txt
		echo $(cat ${filename} |grep "DUMPCTL") >> time.txt
	fi
done < "$input"
