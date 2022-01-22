#!/bin/bash

dir=$1

sed -i 's/ARCHER2_QUEUE='\''standard'\''/ARCHER2_QUEUE='\''short'\''/g' ${dir}/rose-suite.
conf
sed -i 's/BUILD_DRIVERS=false/BUILD_DRIVERS=true/g' ${dir}/rose-suite.conf
sed -i 's/CREATE_XIOS_XML=false/CREATE_XIOS_XML=true/g' ${dir}/rose-suite.conf
sed -i 's/MAIN_CLOCK='\''PT40M'\''/MAIN_CLOCK='\''PT5M'\''/g' ${dir}/rose-suite.conf
sed -i 's/TASK_BUILD_UM=false/TASK_BUILD_UM=true/g' ${dir}/rose-suite.conf
sed -i 's/TASK_RECON=true/TASK_RECON=false/g' ${dir}/rose-suite.conf
sed -i 's/TASK_RUN=true/TASK_RUN=false/g' ${dir}/rose-suite.conf

You have new mail in /var/spool/mail/luciana
