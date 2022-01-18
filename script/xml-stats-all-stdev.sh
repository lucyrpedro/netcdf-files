#!/bin/bash

grid=$1
field=$2
file=$3

cat >> ${file} << EOF

	<file description="Field ${field}" id="test-${field}" name="test-${field}" output_freq="3h">

		<field
			id="${field}_stdev"
			name="${field}_stdev"
			operation="instant"
			field_ref="${field}_ens"
			> sqrt(${field}_avensq - ${field}_sqav)
		</field>

	</file>

EOF

