#!/bin/bash

dir=$1

sed -i 's/ARCHER2_QUEUE='\''short'\''/ARCHER2_QUEUE='\''standard'\''/g' ${dir}/rose-suite.
conf
sed -i 's/BUILD_DRIVERS=true/BUILD_DRIVERS=false/g' ${dir}/rose-suite.conf
sed -i 's/CREATE_XIOS_XML=true/CREATE_XIOS_XML=false/g' ${dir}/rose-suite.conf
sed -i 's/TASK_BUILD_UM=true/TASK_BUILD_UM=false/g' ${dir}/rose-suite.conf
sed -i 's/TASK_RECON=false/TASK_RECON=true/g' ${dir}/rose-suite.conf
sed -i 's/TASK_RUN=false/TASK_RUN=true/g' ${dir}/rose-suite.conf

ens=10#${dir: -2}

if [[ $ens -le 8 ]]
then
  sed -i 's/MAIN_CLOCK='\''PT5M'\''/MAIN_CLOCK='\''PT90M'\''/g' ${dir}/rose-suite.conf
elif [[ $ens -gt 8 ]] && [[ $ens -le 12 ]]
then
  sed -i 's/MAIN_CLOCK='\''PT5M'\''/MAIN_CLOCK='\''PT120M'\''/g' ${dir}/rose-suite.conf
elif [[ $ens -gt 12 ]] && [[ $ens -le 18 ]]
then
  sed -i 's/MAIN_CLOCK='\''PT5M'\''/MAIN_CLOCK='\''PT150M'\''/g' ${dir}/rose-suite.conf
elif [[ $ens -gt 18 ]] && [[ $ens -le 24 ]]
then
  sed -i 's/MAIN_CLOCK='\''PT5M'\''/MAIN_CLOCK='\''PT180M'\''/g' ${dir}/rose-suite.conf
elif [[ $ens -gt 24 ]] && [[ $ens -le 30 ]]
then
  sed -i 's/MAIN_CLOCK='\''PT5M'\''/MAIN_CLOCK='\''PT210M'\''/g' ${dir}/rose-suite.conf
elif [[ $ens -gt 30 ]] && [[ $ens -le 40 ]]
then
  sed -i 's/MAIN_CLOCK='\''PT5M'\''/MAIN_CLOCK='\''PT240M'\''/g' ${dir}/rose-suite.conf
fi
