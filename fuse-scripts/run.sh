# !/bin/bash

# Assuming libfuse is installed in the directory ../libfuse

if [ $1 == 'clean' ]
then
  rm -rf results-database/*
  rm -rf results-figures/*
  rm -rf out-files/*
  rm -rf ../libfuse/build/out*
  rm -f ../libfuse/build/*.sh
  rm -f ../libfuse/build/*.py
  rm -f ../libfuse/build/*.R
fi

## Creating the Output Directories ###

mkdir -p results-database/
mkdir -p results-figures/

## Running DD ###

## DD needs to be update to run the last filter, passthrough_hp

cp -f bash-scripts/run-dd.sh ../libfuse/build/
cd ../libfuse/build/

echo 'xxxxxxxxxxxxxxxxxx'
echo 'Running dd'
echo 'xxxxxxxxxxxxxxxxxx'

# Running the filters with a Bash script

./run-dd.sh tmpfs passthrough
./run-dd.sh fuse passthrough
./run-dd.sh tmpfs passthrough_ll
./run-dd.sh fuse passthrough_ll
./run-dd.sh tmpfs passthrough_fh
./run-dd.sh fuse passthrough_fh

cp -f ../../asm-eurolab-project-files/python-scripts/parse-dd.py out-dd/

cd out-dd

# Running the Python script to parse the results to a csv file

python3 parse-dd.py *.txt

# Saving results and intermediate files

cp -f results-dd.csv ../../../asm-eurolab-project-files/results-database/
cp -rf ../out-dd ../../../asm-eurolab-project-files/out-files/

# Cleaning the files

cd ..
rm -rf out-dd
rm run-dd.sh

##### Install ior and then copy the executable!!!

# IOR needs to be updated to include all filters

# IOR and IOR-r need the same parameters so that parse and plot will work

echo 'xxxxxxxxxxxxxxxxxx'
echo 'Running ior'
echo 'xxxxxxxxxxxxxxxxxx'

cd ../../asm-eurolab-project-files
cp bash-scripts/run-ior-s-mpi.sh ../libfuse/build/
cp bash-scripts/run-ior-s-mpi-r.sh ../libfuse/build/
cp benchmarks/ior ../libfuse/build/

cd ../libfuse/build/

## Running IOR-s-mpi

echo 'xxxxxxxxxxxxxxxxxx'
echo 'Running ior-segments-mpi'
echo 'xxxxxxxxxxxxxxxxxx'

# Running the filters with a Bash script

./run-ior-s-mpi.sh tmpfs passthrough
./run-ior-s-mpi.sh fuse passthrough
./run-ior-s-mpi.sh tmpfs passthrough_ll
./run-ior-s-mpi.sh fuse passthrough_ll
./run-ior-s-mpi.sh tmpfs passthrough_fh
./run-ior-s-mpi.sh fuse passthrough_fh

cp -f ../../asm-eurolab-project-files/python-scripts/parse-ior-s-mpi.py out-ior-s-mpi/

cd out-ior-s-mpi

# Running the Python script to parse the results to a csv file

python3 parse-ior-s-mpi.py *.txt

# Saving results and intermediate files

cp -f results-ior.csv ../../../asm-eurolab-project-files/results-database/results-ior-s-mpi.csv
cp -rf ../out-ior-s-mpi ../../../asm-eurolab-project-files/out-files/

## Running IOR-s-mpi

echo 'xxxxxxxxxxxxxxxxxx'
echo 'Running ior-segments-mpi-random'
echo 'xxxxxxxxxxxxxxxxxx'

cd ../

# Running the filters with a Bash script

./run-ior-s-mpi-r.sh tmpfs passthrough
./run-ior-s-mpi-r.sh fuse passthrough
./run-ior-s-mpi-r.sh tmpfs passthrough_ll
./run-ior-s-mpi-r.sh fuse passthrough_ll
./run-ior-s-mpi-r.sh tmpfs passthrough_fh
./run-ior-s-mpi-r.sh fuse passthrough_fh

cp -f ../../asm-eurolab-project-files/python-scripts/parse-ior-s-mpi.py out-ior-s-mpi-r/

cd out-ior-s-mpi-r

# Running the Python script to parse the results to a csv file

python3 parse-ior-s-mpi.py *.txt

# Saving results and intermediate files

cp -f results-ior.csv ../../../asm-eurolab-project-files/results-database/results-ior-s-mpi-r.csv
cp -rf ../out-ior-s-mpi-r ../../../asm-eurolab-project-files/out-files/

# Cleaning the files

cd ..
rm -rf out-ior-s-mpi-r
rm run-ior-s-mpi.sh
rm ior

## Running MD ###

# MD needs to be update to run all filters

echo 'xxxxxxxxxxxxxxxxxx'
echo 'Running md'
echo 'xxxxxxxxxxxxxxxxxx'

cd ../../asm-eurolab-project-files
cp -f bash-scripts/run-md.sh ../libfuse/build/
cp -f benchmarks/md-workbench ../libfuse/build/

cd ../libfuse/build/

# Running the filters with a Bash script

./run-md.sh tmpfs passthrough
./run-md.sh fuse passthrough
./run-md.sh tmpfs passthrough_ll
./run-md.sh fuse passthrough_ll
./run-md.sh tmpfs passthrough_fh
./run-md.sh fuse passthrough_fh

cp -f ../../asm-eurolab-project-files/python-scripts/parse-md.py out-md/

cd out-md

# Running the Python script to parse the results to a csv file

python3 parse-md.py *.txt

# Saving results and intermediate files

cp -f results-md.csv ../../../asm-eurolab-project-files/results-database/
cp -rf ../out-md ../../../asm-eurolab-project-files/out-files/

# Cleaning the files

cd ..
rm -rf out-md
rm run-md.sh
rm md-workbench

# echo 'xxxxxxxxxxxxxxxxxx'
# echo 'Updating Git'
# echo 'xxxxxxxxxxxxxxxxxx'
#
# cd ../../../fuse/test-local
#
# git pull
# git add *
# git commit -m "Updating the results and the scripts"
# git push

### At some point, use the parse files to check if the real parameters were used
