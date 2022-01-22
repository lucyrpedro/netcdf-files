#!/bin/bash

# Bash Script for Running IOR

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

rm -rf /dev/shm/testfile
rm -rf out
mkdir -p out-ior-s-mpi
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

if [ $3 == 'test' ]
then
  nproc_vec="1 2"
  size_vec="200 600"
  file_size="5000"
  conv="1"
else
  # nproc_vec="1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16"
  # size_vec="1048576 2097152 5242880 10485760"
  nproc_vec="1 2 16"
  size_vec="1048576 10485760"
  file_size="30000"   # changed from 30000 to try to make fuse2 works
  conv="1024"
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

for i in $(seq 1 $nrun) ; do
  for j in $size_vec; do
    for k in $nproc_vec; do
      run_file $i $j $k $file_size $conv
    done
  done
done

if grep -qs "$mount" /proc/mounts
then
  fusermount -u mnt-fuse
else
  echo "The system was supposed to be mounted!"
fi
