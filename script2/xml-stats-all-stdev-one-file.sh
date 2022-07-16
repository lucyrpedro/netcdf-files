#!/bin/bash

grid=$1
field=$2
file=$3

cat >> ${file} << EOF
		<field
			id="${field}_stdev_file"
			name="${field}_stdev_file"
			operation="instant"
			field_ref="${field}_stdev"
		/>

EOF

