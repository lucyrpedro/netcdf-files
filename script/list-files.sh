#!/bin/bash

find $CYLC_SUITE_RUN_DIR -type f > files.txt.${CYLC_TASK_CYCLE_POINT}
