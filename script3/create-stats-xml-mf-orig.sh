#!/bin/bash

# Files created inside ./xml-stats-field.sh

rm -rf grids.txt
rm -rf fields.txt
rm -rf grids-fields.txt

sed 's/\"//g' um-atmos-field_ens_def-orig.xml > aux.txt

input="aux.txt"

output="um-stats-all-mf-orig-1x.xml"
rm -rf $output

cat >> $output << EOF
<file_definition format="netcdf4" time_counter="instant" type="multiple_file">

        <file description="All Fields" id="all-fields" name="all-fields" output_freq="3h">

EOF

while IFS= read -r line
do
#	echo "Line:\n"
	line=$(echo "$line" | grep "grid_ref")
	sub=$(echo "$line" | cut -d'=' -f 3)
	grid=$(echo "$sub" | cut -d' ' -f 1)
#	echo $grid
        sub=$(echo "$line" | cut -d'=' -f 4)
	field=$(echo "$sub" | cut -d' ' -f 1)
#        echo $field
	if [ -n "$grid" ]; then
		echo "Grid=$grid "
		echo "Field=$field "
		./xml-stats-field.sh $grid $field $output
	fi
done < "$input"

cat >> $output << EOF
        </file>

</file_definition>
EOF

rm -rf aux.txt
