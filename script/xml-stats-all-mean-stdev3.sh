#!/bin/bash

grid=$1
field=$2
file=$3

cat >> ${file} << EOF
	<file description="Field ${field} - MEAN STDEV" id="test-${field}-mean-stdev-file" name="test-${field}-mean-stdev" output_freq="3h">

		<field
			id="${field}_ens_mean_file"
			name="${field}_ens_mean_file"
			operation="instant"
			field_ref="${field}_ens"
		/>

		<field
			id="${field}_stdev_file"
			name="${field}_stdev_file"
			operation="instant"
			field_ref="${field}_stdev"
		/>

	</file>

EOF

