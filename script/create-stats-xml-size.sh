#!/bin/bash

size=$1
input=input-size${size}.txt
echo $input

rm -rf stats-${size}.xml

while IFS=$'\t' read field grid
do
	echo "Grid=${grid}"
	echo "Field=${field}"
	./xml-stats-field-size.sh ${grid} ${field} ${size} 
done < "$input"

