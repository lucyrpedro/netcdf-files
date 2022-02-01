#!/bin/bash

grid=$1
field=$2
file=$3

cat >> ${file} << EOF

	<file description="Field ${field} - STDEV" id="test-${field}-stdev" name="test-${field}-stdev" output_freq="3h">

		<field
			id="${field}_stdev"
			name="${field}_stdev"
			operation="instant"
			field_ref="${field}_field_stdev"
		</field>

	</file>

EOF

