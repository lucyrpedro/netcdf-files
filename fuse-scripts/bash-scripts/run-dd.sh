#!/bin/bash

# Bash Script for Running DD

# Options: Parameter $1

# tmpfs (/dev/shm/)
# fuse (mnt-fuse/dev/shm/)

# Options: Parameter $2

# passthrough
# passthrough_ll
# passthrough_fh
# passthrough_hp

# lucy@lucy-GS70-2PC-Stealth:~/esiwace/libfuse/build$ ./example/passthrough_hp --help
# Usage: ./example/passthrough_hp --help
#        ./example/passthrough_hp [options] <source> <mountpoint>
# What's source?

# Options: Parameter $3

# test
# none

# Options: Parameter $4

# Number of executions

# Options: Parameter $5

# Size of the file -- NOT WORKING

# Options: Parameter $6

# Number of processors -- NOT WORKING

###############################################################################

# Insert something to run only when necessary

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

if [ $3 == 'test' ]
then
  blocksize_vec="100 128 1000"
  filesize_vec="30000"
else
  # blocksize_vec="10000 16384 100000 131072 1000000 1048576"
  # filesize_vec="10485760 104857600 1048576000 10485760000"
  blocksize_vec="10000 1048576"
  filesize_vec="10485760 10485760000"
fi

function run_file(){
  run=$1
  blocksize=$2
  filesize=$3

  let blocks=$3/$2

  file=out-dd/${filter}-${dir}-${run}-${blocksize}-${filesize}-write.txt
  if [[ ! -e $file ]]  # this option is not good as it sounds; when a parameter is changed, the file is not replaced
  then
    echo dd if=/dev/zero of=${test_dir} bs=${blocksize} count=$blocks > out-dd/${filter}-${dir}-${run}-${blocksize}-${filesize}-write.txt 2>&1
    dd if=/dev/zero of=${test_dir} bs=${blocksize} count=$blocks >> out-dd/${filter}-${dir}-${run}-${blocksize}-${filesize}-write.txt 2>&1
  fi
  file=out-dd/${filter}-${dir}-${run}-${blocksize}-${filesize}-read.txt
  if [[ ! -e $file ]]
  then
    echo dd of=/dev/null if=${test_dir} bs=${blocksize} count=$blocks > out-dd/${filter}-${dir}-${run}-${blocksize}-${filesize}-read.txt 2>&1
    dd of=/dev/null if=${test_dir} bs=${blocksize} count=$blocks >> out-dd/${filter}-${dir}-${run}-${blocksize}-${filesize}-read.txt 2>&1
  fi
}

for i in $(seq 1 $nrun) ; do
  for j in $blocksize_vec ; do     # 7
    for k in $filesize_vec ; do   # 2
      run_file $i $j $k
    done
  done
done

if grep -qs "$mount" /proc/mounts
then
  fusermount -u mnt-fuse
else
  echo "The system was supposed to be mounted!"
fi
