#!/bin/bash

rm -rf io.cylc

cat >> io.cylc.${CYLC_TASK_CYCLE_POINT} << EOF
[Task 1]
	[[inputs]]

		topography = "xxxxxxxxx"
		checkpoint = "xxxxxxxxx"
		init = "xxxxxxxxxxxxxxx"

	[[outputs]]

EOF

input="files.txt.${CYLC_TASK_CYCLE_POINT}"

while IFS= read -r line
do
  echo "$line"
  ./add-file.sh $line
done < "$input"
# done

sleep 1
