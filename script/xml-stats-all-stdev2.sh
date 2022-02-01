#!/bin/bash

grid=$1
field=$2
file=$3

cat >> ${file} << EOF

	<file description="Field ${field} - STDEV" id="test-${field}-stdev-file" name="test-${field}-stdev-file" output_freq="3h">

		<field
			id="${field}_stdev_file"
			name="${field}_stdev_file"
			operation="instant"
			field_ref="${field}_stdev"
		/>

	</file>

EOF

