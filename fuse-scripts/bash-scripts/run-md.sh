#!/bin/bash

# Bash Script for Running MD-WORKBENCH

# Options: Parameter $1

# tmpfs (/dev/shm/)
# fuse (mnt-fuse/dev/shm/)

# Options: Parameter $2

# passthrough
# passthrough_ll
# passthrough_fh
# passthrough_hp

###############################################################################

spack load -r openmpi
spack load gcc

dir=$1
filter=$2
nrun=$4

if [ $dir == 'tmpfs' ]
then test_dir=/dev/shm/testfile
fi

if [ $dir == 'fuse' ]; then
  if [ $filter == 'passthrough_hp' ]; then
    test_dir=mnt-fuse/testfile
  else test_dir=mnt-fuse/dev/shm/testfile
  fi
fi

rm -rf out
mkdir -p out-md

if [ $3 == 'test' ]
then
  nproc_vec="1 2"
  isize_vec="200 500"
  psize_vec="1000"
  conv=(1)
else
  nproc_vec="1 16"
  nproc_vec="1 16"
  isize_vec="200000 100000" # working for passthrough and passthrough_hp
  psize_vec="100000 1000000"
  # isize_vec="20000 50000 100000" # working for passthrough_fh
  # psize_vec="100000 300000 500000 1000000"
  # isize_vec="2000 5000 10000" # attempt to passthrough_ll => too many files
  # psize_vec="10000 30000 50000 100000"
fi

function run_file(){
  run=$1
  isize=$2
  psize=$3
  nproc=$4

  isizeproc=$(($2/$4))
  psizeproc=$(($3/$4))

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

  file=out-md/${filter}-${dir}-${run}-${isize}-${psize}-${nproc}.txt
  if [[ ! -e $file ]]  # this option is not good as it sounds; when a parameter is changed, the file is not replaced
  then
    rm -rf /dev/shm/*
    echo mpiexec -n ${nproc} ./md-workbench -R=1 -D=1 -I=${isizeproc} -P=${psizeproc} -- -D ${test_dir} > out-md/${filter}-${dir}-${run}-${isize}-${psize}-${nproc}.txt 2>&1
    mpiexec -n ${nproc} ./md-workbench -R=1 -D=1 -I=${isizeproc} -P=${psizeproc} -- -D ${test_dir} >> out-md/${filter}-${dir}-${run}-${isize}-${psize}-${nproc}.txt 2>&1
  fi

  if grep -qs "$mount" /proc/mounts
  then
    fusermount -u mnt-fuse
  else
    echo "The system was supposed to be mounted!"
  fi

}

for i in $(seq 1 $nrun) ; do
  for j in $isize_vec; do
    for k in $psize_vec; do
      for l in $nproc_vec; do
        run_file $i $j $k $l
        rm -rf /dev/shm/testfile
      done
    done
  done
done
