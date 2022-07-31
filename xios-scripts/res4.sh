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
        cp ~/cylc-run/${line}/work/19880901T0000Z/atmos_main/pe_output/*pe.stdout ${line} 2>/dev/null
	cp ~/cylc-run/${line}/work/19880901T0000Z/atmos_ens0/pe_output/*pe.stdout ${line} 2>/dev/null
	cp ~/cylc-run/${line}/work/19880901T0000Z/atmos_ens0/xios_client_000.out ${line} 2>/dev/null
	cp ~/cylc-run/${line}/log/job/19880901T0000Z/atmos_main/NN/job.status ${line} 2>/dev/null
        cp ~/cylc-run/${line}/log/job/19880901T0000Z/atmos_main/NN/job ${line} 2>/dev/null
	filename=$(ls ${line} |grep pe)
#	echo $line
	echo $filename
done < "$input"

aux2=~/test-git/netcdf-files/xios-scripts/results

# Reading general information from pe file

while IFS= read -r line
do
	filename=$(ls ${aux2}/${line} |grep pe)
#        echo "line=$line"
#        echo "file=$filename"
	cd ${aux2}/${line}
	if [[ -s "${filename}" ]]; then
#		echo "aux=${filename}"
		echo $(cat ${filename} |grep "Elapsed Wallclock Time") > time.txt		
		echo $(cat ${filename} |grep " INITIAL ") >> time.txt
		echo $(cat ${filename} |grep "DUMPCTL") >> time.txt
	fi
done < "$input"

# Reading information from xios-client file

while IFS= read -r line
do
        filename="xios_client_000.out"
#        echo "file=$filename"
        cd ${aux2}/${line}
        if [[ -s "${filename}" ]]; then
#                echo "aux=${filename}"
                echo $(cat ${filename} |grep "CSpatialTransformFilterEngine") >> time.txt
        fi
done < "$input"

# Reading took information from pe file

rm -rf ${aux2}/${line}/took.txt
touch ${aux2}/${line}/took.txt

while IFS= read -r line
do
        filename=$(ls ${aux2}/${line} |grep pe)
#        echo "file=$filename"
        cd ${aux2}/${line}
        if [[ -s "${filename}" ]]; then
#                echo "took=${filename}"
                echo $(cat ${filename} |grep "took") >> took.txt
        fi
done < "$input"

# Reading general information from job.status

while IFS= read -r line
do
        filename=$(ls ${aux2}/${line} |grep job.status)
#        echo "line=$line"
        echo "file=$filename"
        cd ${aux2}/${line}
        if [[ -s "${filename}" ]]; then
#                echo "aux=${filename}"
                echo $(cat ${filename} |grep "CYLC_JOB_PID") >> time.txt
		echo $(cat ${filename} |grep "CYLC_BATCH_SYS_JOB_ID") >> time.txt
		echo $(cat ${filename} |grep "CYLC_BATCH_SYS_JOB_SUBMIT_TIME") >> time.txt
                echo $(cat ${filename} |grep "CYLC_JOB_INIT_TIME") >> time.txt
                echo $(cat ${filename} |grep "CYLC_JOB_EXIT") >> time.txt # Collects CYLC_JOB_EXIT and CYLC_JOB_EXIT_TIME
        fi
done < "$input"

# Reading number of nodes from log/job

while IFS= read -r line
do
        filename=job
        echo "line=$line"
#        echo "file=$filename"
        cd ${aux2}/${line}
        if [[ -s "${filename}" ]]; then
                echo "aux=${filename}"
                echo $(cat ${filename} |grep "SBATCH --nodes") >> time.txt
		echo $(cat ${filename} |grep "UM_ATM_NENS=") >> time.txt
	fi
done < "$input"

