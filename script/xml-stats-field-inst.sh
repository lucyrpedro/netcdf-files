#!/bin/bash

grid=$1
field=$2

cat >> grids.txt << EOF
${grid}
EOF

cat >> fields.txt << EOF
${field}
EOF

cat >> grids-fields.txt << EOF
${grid} ${field}
EOF

cat >> um-stats-inst.xml << EOF

	<file description="Field ${field}" id="test-${field}" name="test-${field}" output_freq="8ts">

		<field
			id="${field}_inst"
			name="${field}_inst"
			operation="instant"
			field_ref="${field}"
		/>

	</file>

EOF

