#!/bin/bash

input="grids-fields.txt"

output_ms="um-stats-all-ms-two-file.xml"
rm -rf $output_ms

cat >> $output_ms << EOF
<file_definition format="netcdf4" time_counter="instant" type="one_file">

	<file description="All Fields" id="all-fields-mean" name="test-all-fields-mean" output_freq="3h">

EOF

while IFS= read -r line
do
	grid=$(echo "$line" | cut -d' ' -f 1)
	field=$(echo "$line" | cut -d' ' -f 2)
	echo "grid = $grid"
	echo "field = $field"
	./xml-stats-all-mean-one-file.sh $grid $field $output_ms
done < "$input"

cat >> $output_ms << EOF
        </file>

        <file description="All Fields" id="all-fields-stdev" name="test-all-fields-stdev" output_freq="3h">

EOF

while IFS= read -r line
do
        grid=$(echo "$line" | cut -d' ' -f 1)
        field=$(echo "$line" | cut -d' ' -f 2)
        echo "grid = $grid"
        echo "field = $field"
        ./xml-stats-all-stdev-one-file.sh $grid $field $output_ms
done < "$input"


cat >> $output_ms << EOF
	</file>

</file_definition>
EOF

cp $output_ms ../test

