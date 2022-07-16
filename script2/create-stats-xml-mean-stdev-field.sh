#!/bin/bash

input="grids-fields.txt"

output_mean="um-stats-all-mean.xml"
rm -rf $output_mean

output_stdev="um-stats-all-stdev.xml"
rm -rf $output_stdev

output_field="um-stats-all-field.xml"
rm -rf $output_field

cat >> $output_mean << EOF
<file_definition format="netcdf4" time_counter="instant" type="one_file">

EOF

cat >> $output_stdev << EOF
<file_definition format="netcdf4" time_counter="instant" type="one_file">

EOF

while IFS= read -r line
do
	grid=$(echo "$line" | cut -d' ' -f 1)
	field=$(echo "$line" | cut -d' ' -f 2)
	echo "grid = $grid"
	echo "field = $field"
	./xml-stats-all-mean.sh $grid $field $output_mean
	./xml-stats-all-stdev.sh $grid $field $output_stdev
	./xml-stats-all-field.sh $grid $field $output_field
done < "$input"

cat >> $output_mean << EOF
</file_definition>
EOF

cat >> $output_stdev << EOF
</file_definition>
EOF
