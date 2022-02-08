#!/bin/bash

input="grids-fields.txt"

output_mean="um-stats-all-mean3.xml"
rm -rf $output_mean

output_stdev="um-stats-all-stdev3.xml"
rm -rf $output_stdev

output_mean_stdev="um-stats-all-mean-stdev3.xml"
rm -rf $output_mean_stdev

output_ms="um-stats-all-ms3.xml"
rm -rf $output_ms

output_field="um-stats-all-field3.xml"
rm -rf $output_field

mean=aux1
stdev=aux2

cat >> $output_mean << EOF
<file_definition format="netcdf4" time_counter="instant" type="one_file">

EOF

cat >> $output_stdev << EOF
<file_definition format="netcdf4" time_counter="instant" type="one_file">

EOF

cat >> $output_ms << EOF
<file_definition format="netcdf4" time_counter="instant" type="one_file">

EOF

cat >> $output_mean_stdev << EOF
<file_definition format="netcdf4" time_counter="instant" type="one_file">

EOF

while IFS= read -r line
do
	grid=$(echo "$line" | cut -d' ' -f 1)
	field=$(echo "$line" | cut -d' ' -f 2)
	echo "grid = $grid"
	echo "field = $field"
	./xml-stats-all-mean3.sh $grid $field $mean
	./xml-stats-all-stdev3.sh $grid $field $stdev
	./xml-stats-all-mean-stdev3.sh $grid $field $output_ms
	./xml-stats-all-field3.sh $grid $field $output_field
done < "$input"

cat $output_mean $mean > aux3
cat $output_stdev $stdev > aux4
cat $mean $output_mean_stdev > aux5
cat $stdev $aux5 > aux6

mv aux3 $output_mean
mv aux4 $output_stdev
mv aux6 $output_mean_stdev

cat >> $output_mean << EOF
</file_definition>
EOF

cat >> $output_stdev << EOF
</file_definition>
EOF

cat >> $output_ms << EOF
</file_definition>
EOF

cat >> $output_mean_stdev << EOF
</file_definition>
EOF

cat >> $output_field << EOF
</field_definition>
EOF

cat field-orig.txt $output_field > aux7

mv aux7 $output_field

cp $output_field ../test
cp $output_mean ../test
cp $output_stdev ../test
cp $output_mean_stdev ../test
cp $output_ms ../test

rm aux*
