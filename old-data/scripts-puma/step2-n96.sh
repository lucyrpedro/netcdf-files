#!/bin/bash

dir=$1

# sed -i 's/ARCHER2_QUEUE='\''short'\''/ARCHER2_QUEUE='\''standard'\''/g' ${dir}/rose-suit
e.conf
sed -i 's/BUILD_DRIVERS=true/BUILD_DRIVERS=false/g' ${dir}/rose-suite.conf
sed -i 's/CREATE_XIOS_XML=true/CREATE_XIOS_XML=false/g' ${dir}/rose-suite.conf
sed -i 's/TASK_BUILD_UM=true/TASK_BUILD_UM=false/g' ${dir}/rose-suite.conf
sed -i 's/TASK_RECON=false/TASK_RECON=true/g' ${dir}/rose-suite.conf
sed -i 's/TASK_RUN=false/TASK_RUN=true/g' ${dir}/rose-suite.conf

ens=10#${dir: -2}

if [[ $ens -le 20 ]]
then
  sed -i 's/MAIN_CLOCK='\''PT5M'\''/MAIN_CLOCK='\''PT3M'\''/g' ${dir}/rose-suite.conf
elif [[ $ens -gt 20 ]] && [[ $ens -le 50 ]]
then
  sed -i 's/MAIN_CLOCK='\''PT5M'\''/MAIN_CLOCK='\''PT4M'\''/g' ${dir}/rose-suite.conf
elif [[ $ens -gt 50 ]] && [[ $ens -le 80 ]]
then
  sed -i 's/MAIN_CLOCK='\''PT5M'\''/MAIN_CLOCK='\''PT6M'\''/g' ${dir}/rose-suite.conf
elif [[ $ens -gt 80 ]] && [[ $ens -le 99 ]]
then
  sed -i 's/MAIN_CLOCK='\''PT5M'\''/MAIN_CLOCK='\''PT10M'\''/g' ${dir}/rose-suite.conf
fi
