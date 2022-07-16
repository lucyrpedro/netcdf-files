#!/bin/bash

input="grids-fields.txt"
output="um-stats-all.xml"
rm -rf $output

while IFS= read -r line
do
	grid=$(echo "$line" | cut -d' ' -f 1)
	field=$(echo "$line" | cut -d' ' -f 2)
	echo "grid = $grid"
	echo "field = $field"
	./xml-stats-field-all.sh $grid $field $output
done < "$input"

