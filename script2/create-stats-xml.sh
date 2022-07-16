#!/bin/bash

# Files created inside ./xml-stats-field.sh

rm -rf um-stats.xml
rm -rf grids.txt
rm -rf fields.txt
rm -rf grids-fields.txt

sed 's/\"//g' um-atmos-field_ens_def.xml > aux.txt

input="aux.txt"

while IFS= read -r line
do
#	echo "Line:\n"
	line=$(echo "$line" | grep "grid_ref")
	sub=$(echo "$line" | cut -d'=' -f 3)
	grid=$(echo "$sub" | cut -d' ' -f 1)
#	echo $grid
        sub=$(echo "$line" | cut -d'=' -f 4)
	field=$(echo "$sub" | cut -d' ' -f 1)
#        echo $field
	if [ -n "$grid" ]; then
		echo "Grid=$grid "
		echo "Field=$field "
		./xml-stats-field.sh $grid $field
	fi
done < "$input"

rm -rf aux.txt
