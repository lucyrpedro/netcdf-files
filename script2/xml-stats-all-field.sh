#!/bin/bash

grid=$1
field=$2
file=$3

cat >> ${file} << EOF

		<field
			id="${field}_inst"
			name="${field}_inst"
			operation="instant"
			field_ref="${field}"
		/>

		<field
			id="${field}_ens"
			name="${field}_ens"
			operation="instant"
			field_ref="${field}"
			grid_ref="${grid}_ens_mean"
		/>

		<field
			id="${field}_sqav"
			name="${field}_sqav"
			operation="instant"
			field_ref="${field}_ens"
			> ${field}_ens*${field}_ens
		</field>

		<field
			id="${field}_avensq"
			name="${field}_avensq"
			operation="instant"
			field_ref="${field}"
			grid_ref="${grid}_ens_mean"
			> ${field}*${field}
		</field>

EOF

