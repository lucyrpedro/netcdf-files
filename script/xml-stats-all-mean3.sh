#!/bin/bash

grid=$1
field=$2
file=$3

cat >> ${file} << EOF
	<file description="Field ${field} - MEAN" id="test-${field}-mean-file" name="test-${field}-mean" output_freq="3h">

		<field
			id="${field}_ens_mean_file"
			name="${field}_ens_mean_file"
			operation="instant"
			field_ref="${field}_ens"
		/>

	</file>

EOF

