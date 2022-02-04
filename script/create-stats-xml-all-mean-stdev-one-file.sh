#!/bin/bash

input="grids-fields.txt"

output_mean_stdev="um-stats-all-mean-stdev-one-file.xml"
rm -rf $output_mean_stdev

cat >> $output_mean_stdev << EOF
<file_definition format="netcdf4" time_counter="instant" type="one_file">

	<file description="All Fields" id="all-fields-mean-stdev" name="file-all-fields-mean-stdev" output_freq="3h">

EOF

while IFS= read -r line
do
	grid=$(echo "$line" | cut -d' ' -f 1)
	field=$(echo "$line" | cut -d' ' -f 2)
	echo "grid = $grid"
	echo "field = $field"
	./xml-stats-all-mean-stdev-one-file.sh $grid $field $output_mean_stdev
done < "$input"

cat >> $output_mean_stdev << EOF
	</file>

</file_definition>
EOF

cp $output_mean_stdev ../test

