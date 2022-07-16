#!/bin/bash

input="grids-fields.txt"

output_mean="um-stats-all-mean-one-file.xml"
rm -rf $output_mean

cat >> $output_mean << EOF
<file_definition format="netcdf4" time_counter="instant" type="one_file">

	<file description="All Fields" id="all-fields-mean" name="file-all-fields-mean" output_freq="3h">

EOF

while IFS= read -r line
do
	grid=$(echo "$line" | cut -d' ' -f 1)
	field=$(echo "$line" | cut -d' ' -f 2)
	echo "grid = $grid"
	echo "field = $field"
	./xml-stats-all-mean-one-file-test.sh $grid $field $output_mean
done < "$input"

cat >> $output_mean << EOF
	</file>

</file_definition>
EOF

cp $output_mean ../test

