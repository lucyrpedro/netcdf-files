#!/bin/bash

input="grids-fields.txt"

output_stdev="um-stats-stdev.xml"
rm -rf $output_stdev

cat >> $output_stdev << EOF
<file_definition format="netcdf4" time_counter="instant" type="one_file">

EOF

while IFS= read -r line
do
	grid=$(echo "$line" | cut -d' ' -f 1)
	field=$(echo "$line" | cut -d' ' -f 2)
	echo "grid = $grid"
	echo "field = $field"
	./xml-stats-stdev.sh $grid $field $output_stdev
done < "$input"

cat >> $output_stdev << EOF
</file_definition>
EOF
