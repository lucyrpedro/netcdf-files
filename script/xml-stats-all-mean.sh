#!/bin/bash

grid=$1
field=$2
file=$3

cat >> ${file} << EOF

	<file description="Field ${field}" id="test-${field}" name="test-${field}" output_freq="3h">

		<field
			id="${field}_ens"
			name="${field}_ens"
			operation="instant"
			field_ref="${field}"
			grid_ref="${grid}_ens_mean"
		/>

	</file>

EOF

