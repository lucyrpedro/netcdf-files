#!/bin/bash

grid=$1
field=$2
file=$3

cat >> ${file} << EOF
		<field
			id="${field}_ens_mean_file"
			name="${field}_ens_mean_file"
			operation="instant"
			field_ref="${field}_ens"
		/>

EOF

