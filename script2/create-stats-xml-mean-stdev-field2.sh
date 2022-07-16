#!/bin/bash

input="grids-fields.txt"

output_mean="um-stats-all-mean2.xml"
rm -rf $output_mean

output_stdev="um-stats-all-stdev2.xml"
rm -rf $output_stdev

output_ms="um-stats-all-mean_stdev2.xml"
rm -rf $output_ms

output_field="um-stats-all-field2.xml"
rm -rf $output_field

cat >> $output_mean << EOF
<file_definition format="netcdf4" time_counter="instant" type="one_file">

EOF

cat >> $output_stdev << EOF
<file_definition format="netcdf4" time_counter="instant" type="one_file">

EOF

cat >> $output_ms << EOF
<file_definition format="netcdf4" time_counter="instant" type="one_file">

EOF

while IFS= read -r line
do
	grid=$(echo "$line" | cut -d' ' -f 1)
	field=$(echo "$line" | cut -d' ' -f 2)
	echo "grid = $grid"
	echo "field = $field"
	./xml-stats-all-mean2.sh $grid $field $output_mean
	./xml-stats-all-stdev2.sh $grid $field $output_stdev
	./xml-stats-all-mean-stdev2.sh $grid $field $output_ms
	./xml-stats-all-field2.sh $grid $field $output_field
done < "$input"

cat >> $output_mean << EOF
</file_definition>
EOF

cat >> $output_stdev << EOF
</file_definition>
EOF

cat >> $output_ms << EOF
</file_definition>
EOF

cat >> $output_field << EOF
</field_definition>
EOF

cat field-orig.txt $output_field > aux

mv aux $output_field

cp $output_field ../test
cp $output_mean ../test
cp $output_stdev ../test
cp $output_ms ../test

