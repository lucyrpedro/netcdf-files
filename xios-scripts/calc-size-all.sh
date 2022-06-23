#!/bin/bash

aux=~/test-git/netcdf-files/xios-scripts

cd ~/cylc-run
ls -1 > ${aux}/aux-files/dir.txt
files=$(ls -1 |wc -l)

input=${aux}/aux-files/dir.txt

cd ${aux}

while IFS= read -r line
do
	./size-all.sh ${line}
done < "$input"

cd ${aux}/total

rm -rf total-all-suites.csv
touch total-all-suites.csv

input=${aux}/aux-files/dir.txt

while IFS= read -r line
do
	if [[ -s "${aux}/aux/total-${line}.csv" ]]; then
		cat ${aux}/aux/total-${line}.csv >> total-all-suites.csv
	fi
done < "$input"

cp total-all-suites.csv ${aux}
