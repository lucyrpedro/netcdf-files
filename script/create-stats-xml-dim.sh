#!/bin/bash

input="grids-fields-2D.txt"
output="um-stats-2D.xml"
rm -rf $output

while IFS= read -r line
do
	grid=$(echo "$line" | cut -d' ' -f 1)
	field=$(echo "$line" | cut -d' ' -f 2)
	echo "grid = $grid"
	echo "field = $field"
	./xml-stats-field-dim.sh $grid $field $output
done < "$input"

input="grids-fields-3D.txt"
output="um-stats-3D.xml"
rm -rf $output

while IFS= read -r line
do
        grid=$(echo "$line" | cut -d' ' -f 1)
        field=$(echo "$line" | cut -d' ' -f 2)
        echo "grid = $grid"
        echo "field = $field"
        ./xml-stats-field-dim.sh $grid $field $output
done < "$input"

