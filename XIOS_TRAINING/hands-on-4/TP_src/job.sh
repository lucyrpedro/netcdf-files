#!/bin/bash
#MSUB -o output.out
#MSUB -e error.err
#MSUB -eo
#MSUB -c 1
#MSUB -n 4
#MSUB -X
#MSUB -x
#MSUB -T 1800
#MSUB -q skylake
#MSUB -A gen0826
#MSUB -Q test
#MSUB -m work,scratch
cd $BRIDGE_MSUB_PWD
source ../xios_build/arch.env


ccc_mprun ./test_tp4.exe
