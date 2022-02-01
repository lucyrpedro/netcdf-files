#!/bin/bash

input="grids-fields.txt"

output_mean="um-stats-all-mean2.xml"
rm -rf $output_mean

output_stdev="um-stats-all-stdev2.xml"
rm -rf $output_stdev

output_field="um-stats-all-field2.xml"
rm -rf $output_field

cat >> $output_mean << EOF
<file_definition format="netcdf4" time_counter="instant" type="one_file">

EOF

cat >> $output_stdev << EOF
<file_definition format="netcdf4" time_counter="instant" type="one_file">

EOF

cat >> $output_field << EOF
<field_definition default_value="-1073741824.0" prec="8">
EOF

while IFS= read -r line
do
	grid=$(echo "$line" | cut -d' ' -f 1)
	field=$(echo "$line" | cut -d' ' -f 2)
	echo "grid = $grid"
	echo "field = $field"
	./xml-stats-all-mean2.sh $grid $field $output_mean
	./xml-stats-all-stdev2.sh $grid $field $output_stdev
	./xml-stats-all-field2.sh $grid $field $output_field
done < "$input"

cat >> $output_mean << EOF
</file_definition>
EOF

cat >> $output_stdev << EOF
</file_definition>
EOF

cat >> $output_field << EOF
</field_definition>
EOF
