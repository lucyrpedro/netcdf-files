#!/bin/bash

grid=$1
field=$2
output=$3

cat >> grids.txt << EOF
${grid}
EOF

cat >> fields.txt << EOF
${field}
EOF

cat >> grids-fields.txt << EOF
${grid} ${field}
EOF

cat >> $output << EOF

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

		<field
			id="${field}_stdev"
			name="${field}_stdev"
			operation="instant"
			field_ref="${field}_ens"
			> sqrt(${field}_avensq - ${field}_sqav)
		</field>

                <field
                        id="${field}_inst2"
                        name="${field}_inst2"
                        operation="instant"
                        field_ref="${field}"
                />

                <field
                        id="${field}_ens2"
                        name="${field}_ens2"
                        operation="instant"
                        field_ref="${field}"
                        grid_ref="${grid}_ens_mean"
                />

                <field
                        id="${field}_sqav2"
                        name="${field}_sqav2"
                        operation="instant"
                        field_ref="${field}_ens"
                        > ${field}_ens*${field}_ens
                </field>

                <field
                        id="${field}_avensq2"
                        name="${field}_avensq2"
                        operation="instant"
                        field_ref="${field}"
                        grid_ref="${grid}_ens_mean"
                        > ${field}*${field}
                </field>

                <field
                        id="${field}_stdev2"
                        name="${field}_stdev2"
                        operation="instant"
                        field_ref="${field}_ens"
                        > sqrt(${field}_avensq - ${field}_sqav)
                </field>

                <field
                        id="${field}_inst3"
                        name="${field}_inst3"
                        operation="instant"
                        field_ref="${field}"
                />

                <field
                        id="${field}_ens3"
                        name="${field}_ens3"
                        operation="instant"
                        field_ref="${field}"
                        grid_ref="${grid}_ens_mean"
                />

                <field
                        id="${field}_sqav3"
                        name="${field}_sqav3"
                        operation="instant"
                        field_ref="${field}_ens"
                        > ${field}_ens*${field}_ens
                </field>

                <field
                        id="${field}_avensq3"
                        name="${field}_avensq3"
                        operation="instant"
                        field_ref="${field}"
                        grid_ref="${grid}_ens_mean"
                        > ${field}*${field}
                </field>

                <field
                        id="${field}_stdev3"
                        name="${field}_stdev3"
                        operation="instant"
                        field_ref="${field}_ens"
                        > sqrt(${field}_avensq - ${field}_sqav)
                </field>

                <field
                        id="${field}_inst4"
                        name="${field}_inst4"
                        operation="instant"
                        field_ref="${field}"
                />

                <field
                        id="${field}_ens4"
                        name="${field}_ens4"
                        operation="instant"
                        field_ref="${field}"
                        grid_ref="${grid}_ens_mean"
                />

                <field
                        id="${field}_sqav4"
                        name="${field}_sqav4"
                        operation="instant"
                        field_ref="${field}_ens"
                        > ${field}_ens*${field}_ens
                </field>

                <field
                        id="${field}_avensq4"
                        name="${field}_avensq4"
                        operation="instant"
                        field_ref="${field}"
                        grid_ref="${grid}_ens_mean"
                        > ${field}*${field}
                </field>

                <field
                        id="${field}_stdev4"
                        name="${field}_stdev4"
                        operation="instant"
                        field_ref="${field}_ens"
                        > sqrt(${field}_avensq - ${field}_sqav)
                </field>

EOF

