#!/bin/bash

rm um-stats.xml

input="grids-fields-3D.txt"

while IFS= read -r line
do
	grid=$(echo "$line" | cut -d' ' -f 1)
	field=$(echo "$line" | cut -d' ' -f 2)
	echo "grid = $grid"
	echo "field = $field"
	./xml-stats-field.sh $grid $field
done < "$input"

