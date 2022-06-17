#!/bin/bash

# Files created inside ./xml-stats-field.sh

rm -rf um-stats-paper.xml
rm -rf grids-paper.txt
rm -rf fields-paper.txt
rm -rf grids-fields-paper.txt
rm -rf um-stats-all-paper.xml

sed 's/\"//g' um-atmos-field_ens_def-paper.xml > aux.txt

input="aux.txt"

while IFS= read -r line
do
#	echo "Line:\n"
	line=$(echo "$line" | grep "grid_ref")
	sub=$(echo "$line" | cut -d'=' -f 4)
	grid=$(echo "$sub" | cut -d' ' -f 1)
#	echo $grid
        sub=$(echo "$line" | cut -d'=' -f 5)
	field=$(echo "$sub" | cut -d' ' -f 1)
#        echo $field
	if [ -n "$grid" ]; then
		echo "Grid=$grid "
		echo "Field=$field "
		./xml-stats-field-all-paper.sh $grid $field
	fi
done < "$input"

rm -rf aux.txt
