#!/bin/bash

input="grids-fields-paper.txt"

output_ms="um-stats-all-ms-paper.xml"
rm -rf $output_ms

cat >> $output_ms << EOF
<file_definition format="netcdf4" time_counter="instant" type="multiple_file">

	<file description="UM output - MEAN" id="mean" name="mean" output_freq="2h">

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

        <file description="UM output - STDEV" id="stdev" name="stdev" output_freq="2h">

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

