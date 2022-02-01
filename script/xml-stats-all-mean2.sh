#!/bin/bash

grid=$1
field=$2
file=$3

cat >> ${file} << EOF

	<file description="Field ${field} - MEAN" id="test-${field}-mean" name="test-${field}-mean" output_freq="3h">

		<field
			id="${field}_ens_file"
			name="${field}_ens_file"
			operation="instant"
			field_ref="${field}"
			grid_ref="${grid}_ens_mean"
		/>

	</file>

EOF

