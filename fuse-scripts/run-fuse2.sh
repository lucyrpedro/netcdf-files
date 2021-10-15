# !/bin/bash

# Assuming libfuse is installed in the directory ../libfuse

# Change the use of libfuse directory, which is not necessary at all!

if [ $1 == 'clean' ]
then
  rm -rf results-database
  rm -rf results-figures
  rm -rf out-files
  rm -rf ../libfuse/build/out*
  rm -f ../libfuse/build/*.sh
  rm -f ../libfuse/build/*.py
  rm -f ../libfuse/build/*.R
fi

## Creating the Output Directories ###

mkdir -p results-database/
mkdir -p results-figures/
mkdir -p out-files/

## Running DD ###

# cp -f bash-scripts/run-dd.sh ../libfuse/build/
# cd ../libfuse/build/

# echo 'xxxxxxxxxxxxxxxxxx'
# echo 'Running dd'
# echo 'xxxxxxxxxxxxxxxxxx'
#
# # Running the filters with a Bash script
#
# ./run-dd.sh tmpfs fusexmp $2 $3
# ./run-dd.sh fuse fusexmp $2 $3
# ./run-dd.sh tmpfs fusexmp_fh $2 $3
# ./run-dd.sh fuse fusexmp_fh $2 $3
#
# cp -f ../../asm-eurolab-project-files/python-scripts/parse-dd.py out-dd
#
# cd out-dd
#
# # Running the Python script to parse the results to a csv file
#
# python3 parse-dd.py *.txt
#
# # Saving results and intermediate files
#
# cp -f results-dd.csv ../../../asm-eurolab-project-files/results-database/
# cp -rf ../out-dd/ ../../../asm-eurolab-project-files/out-files/
#
# # Cleaning the files
#
# cd ..
# rm -rf out-dd
# rm run-dd.sh
#
# ## Running MD ###
#
# echo 'xxxxxxxxxxxxxxxxxx'
# echo 'Running md'
# echo 'xxxxxxxxxxxxxxxxxx'
#
# cd ../../asm-eurolab-project-files
# cp -f bash-scripts/run-md.sh ../libfuse/build/
# cp -f benchmarks/md-workbench ../libfuse/build/
#
# cd ../libfuse/build/
#
# # Running the filters with a Bash script
#
# ./run-md.sh tmpfs fusexmp $2 $3
# ./run-md.sh fuse fusexmp $2 $3
# ./run-md.sh tmpfs fusexmp_fh $2 $3
# ./run-md.sh fuse fusexmp_fh $2 $3
#
# cp -f ../../asm-eurolab-project-files/python-scripts/parse-md.py out-md/
#
# cd out-md
#
# # Running the Python script to parse the results to a csv file
#
# python3 parse-md.py *.txt
#
# # Saving results and intermediate files
#
# cp -f results-md.csv ../../../asm-eurolab-project-files/results-database/
# cp -rf ../out-md/ ../../../asm-eurolab-project-files/out-files/
#
# ## Cleaning the files
#
# cd ..
# rm -rf out-md
# rm run-md.sh
# rm md-workbench

##### Install ior and then copy the executable!!!

# IOR needs to be updated to include all filters

# IOR and IOR-r need the same parameters so that parse and plot will work

echo 'xxxxxxxxxxxxxxxxxx'
echo 'Running ior'
echo 'xxxxxxxxxxxxxxxxxx'

# cd ../../asm-eurolab-project-files
cp bash-scripts/run-ior-s-mpi.sh ../libfuse/build/
cp bash-scripts/run-ior-s-mpi-r.sh ../libfuse/build/
cp benchmarks/ior ../libfuse/build/

cd ../libfuse/build/

## Running IOR-s-mpi

echo 'xxxxxxxxxxxxxxxxxx'
echo 'Running ior-segments-mpi'
echo 'xxxxxxxxxxxxxxxxxx'

# Running the filters with a Bash script

./run-ior-s-mpi.sh tmpfs fusexmp $2 $3
./run-ior-s-mpi.sh fuse fusexmp $2 $3
./run-ior-s-mpi.sh tmpfs fusexmp_fh $2 $3
./run-ior-s-mpi.sh fuse fusexmp_fh $2 $3

cp -f ../../asm-eurolab-project-files/python-scripts/parse-ior-s-mpi.py out-ior-s-mpi

cd out-ior-s-mpi

# Running the Python script to parse the results to a csv file

python3 parse-ior-s-mpi.py *.txt

# Saving results and intermediate files

cp -f results-ior-s-mpi.csv ../../../asm-eurolab-project-files/results-database/
cp -rf ../out-ior-s-mpi/ ../../../asm-eurolab-project-files/out-files/

# Running IOR-s-mpi

echo 'xxxxxxxxxxxxxxxxxx'
echo 'Running ior-segments-mpi-random'
echo 'xxxxxxxxxxxxxxxxxx'

cd ../

# Running the filters with a Bash script

./run-ior-s-mpi-r.sh tmpfs fusexmp $2 $3
./run-ior-s-mpi-r.sh fuse fusexmp $2 $3
./run-ior-s-mpi-r.sh tmpfs fusexmp_fh $2 $3
./run-ior-s-mpi-r.sh fuse fusexmp_fh $2 $3

cp -f ../../asm-eurolab-project-files/python-scripts/parse-ior-s-mpi.py out-ior-s-mpi-r/

cd out-ior-s-mpi-r

# Running the Python script to parse the results to a csv file

python3 parse-ior-s-mpi.py *.txt

# Saving results and intermediate files

cp -f results-ior-s-mpi-r.csv ../../../asm-eurolab-project-files/results-database/
cp -rf ../out-ior-s-mpi-r/ ../../../asm-eurolab-project-files/out-files/

# Cleaning the files

cd ..
rm -rf out-ior-s-mpi-r
rm -rf run-ior-s-mpi.sh
rm ior

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
