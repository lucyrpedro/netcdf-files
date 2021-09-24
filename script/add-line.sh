#!/bin/bash

# $1 file

FILENAME=$1

if [[ $FILENAME == *".sh"* || $FILENAME == *"files"* || $FILENAME == *"io.cylc"* || $FILENAME == *"service"* || $FILENAME == *"log"* || $FILENAME == *"suite"* || $FILENAME == *"post"* ]]
then
	echo "FILENAME = $FILENAME"
	exit 1
fi

size=$(ls -l $FILENAME | cut -f5 -d " ")
	
cat >> io.cylc.${CYLC_TASK_CYCLE_POINT} << EOF
		[[[$FILENAME]]]
			pattern = xxxxxxxx
			lifetime = xxxxxxx
			type = xxxxxxxxxxx
			datatype = xxxxxxx
			size = $size
			precision.absolute_tolerance = xxx
EOF
