#!/bin/bash

# Bash Script for Running IOR - One file

# mpiexec -n 14 ./ior -t 1048576 -b 1048576 -w -r -s 2142 -o mnt/dev/shm/testfile
# mpiexec -n $1 ./ior -t $2 -b $2 -w -r -s 2142 -o mnt/dev/shm/testfile

# Options: Parameter $1

# Number of processors

# Options: Parameter $2

# File Size

# Options: Parameter $3

# tmpfs (/dev/shm/)
# fuse (mnt-fuse/dev/shm/)

# Options: Parameter $4

# passthrough
# passthrough_ll
# passthrough_fh
# passthrough_hp

###############################################################################

spack load -r openmpi
spack load gcc

dir=$3
filter=$4

if [ $dir == 'tmpfs' ]
then test_dir=/dev/shm/testfile
fi

if [ $dir == 'fuse' ]; then
  if [ $filter == 'passthrough_hp' ]; then
    test_dir=mnt-fuse/testfile
  else test_dir=mnt-fuse/dev/shm/testfile
  fi
fi

rm -rf /dev/shm/testfile
rm -rf out
mkdir -p out-dd
mkdir -p mnt-fuse

mount="mnt-fuse"

if grep -qs "$mount" /proc/mounts; then
  echo "The system was not supposed to be mounted! Unmounting and mounting again!"
  fusermount -u mnt-fuse
  if [ $filter == 'passthrough_hp' ]; then
    ./example/$filter /dev/shm mnt-fuse/ &
  else ./example/$filter mnt-fuse/
  fi
else
  if [ $filter == 'passthrough_hp' ]; then
    ./example/$filter /dev/shm mnt-fuse/ &
  else ./example/$filter mnt-fuse/
  fi
fi

function run_file(){
  run=$1
  size=$2
  nproc=$3
  filesize=$4
  conv_aux=$5

  segments=$(( ${filesize}/((${size}/${conv_aux}/${conv_aux})*${nproc}) ))

  file=out-ior-s-mpi/${filter}-${dir}-${run}-${size}-${nproc}.txt
  if [[ ! -e $file ]]  # this option is not good as it sounds; when a parameter is changed, the file is not replaced
   then
     echo mpiexec -n ${nproc} ./ior -t ${size} -b ${size} -w -r -s ${segments} -o ${test_dir} > out-ior-s-mpi/${filter}-${dir}-${run}-${size}-${nproc}.txt 2>&1
     mpiexec -n ${nproc} ./ior -t ${size} -b ${size} -w -r -s ${segments} -o ${test_dir} >> out-ior-s-mpi/${filter}-${dir}-${run}-${size}-${nproc}.txt 2>&1
  fi

}

run_file 1 $1 $2 30000 1024

if grep -qs "$mount" /proc/mounts
then
  fusermount -u mnt-fuse
else
  echo "The system was supposed to be mounted!"
fi
