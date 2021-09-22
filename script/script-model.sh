#!/bin/sh

touch ${VAR_DIR}/${VAR_A}.txt
echo "DIR=$VAR_DIR"

NUMBER=$(($RANDOM%1000))
echo "RANDOM-NUMBER=$NUMBER"

for i in $(seq 1 $NUMBER)
do
   echo "Welcome $i times" >> ${VAR_DIR}/${VAR_A}.txt

done

cat > ${VAR_B}.txt << EOF
&input_data
  filename = '${FILE}',
  varname = 'u',
  varname_xios = 'u',
/
EOF

GREETING=${GREETING:-Goodbye}

echo "$GREETING World! from $0" > ${VAR_A}${VAR_B}-out.txt
