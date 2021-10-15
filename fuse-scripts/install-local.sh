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

cp -f ../../asm-eurolab-project-files/python-scripts/parse-dd.py out-dd
cp -f ../../asm-eurolab-project-files/r-scripts/plot-dd.R out-dd

cd out-dd

# Running the Python script to parse the results to a csv file

python3 parse-dd.py *.txt

# Running the R script to generate the graphics

./plot-dd.R

# Saving results and intermediate files

cp -f results-dd.csv ../../../asm-eurolab-project-files/results-database
cp -f figs-dd.pdf ../../../asm-eurolab-project-files/results-figures
cp -rf ../out-dd ../../../asm-eurolab-project-files/out-files

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
cp -f bash-scripts/run-ior.sh ../libfuse/build/
cp -f bash-scripts/run-ior-r.sh ../libfuse/build/
cp -f bash-scripts/run-ior-s.sh ../libfuse/build/
cp -f bash-scripts/run-ior-s-mpi.sh ../libfuse/build/
cp -f benchmarks/ior ../libfuse/build/

cd ../libfuse/build/

## Running IOR

# Running the filters with a Bash script

./run-ior.sh tmpfs passthrough
./run-ior.sh fuse passthrough
./run-ior.sh tmpfs passthrough_ll
./run-ior.sh fuse passthrough_ll
./run-ior.sh tmpfs passthrough_fh
./run-ior.sh fuse passthrough_fh

cp -f ../../asm-eurolab-project-files/python-scripts/parse-ior.py out-ior
cp -f ../../asm-eurolab-project-files/r-scripts/plot-ior.R out-ior

cd out-ior

# Running the Python script to parse the results to a csv file

python3 parse-ior.py *.txt

# Running the R script to generate the graphics

./plot-ior.R

# Saving results and intermediate files

cp -f results-ior.csv ../../../asm-eurolab-project-files/results-database
cp -f figs-ior.pdf ../../../asm-eurolab-project-files/results-figures
cp -rf ../out-ior ../../../asm-eurolab-project-files/out-files

## Running IOR-r

echo 'xxxxxxxxxxxxxxxxxx'
echo 'Running ior-random'
echo 'xxxxxxxxxxxxxxxxxx'

cd ../

# Running the filters with a Bash script

./run-ior-r.sh tmpfs passthrough
./run-ior-r.sh fuse passthrough
./run-ior-r.sh tmpfs passthrough_ll
./run-ior-r.sh fuse passthrough_ll
./run-ior-r.sh tmpfs passthrough_fh
./run-ior-r.sh fuse passthrough_fh

cp -f ../../asm-eurolab-project-files/python-scripts/parse-ior.py out-ior-r
cp -f ../../asm-eurolab-project-files/r-scripts/plot-ior.R out-ior-r

cd out-ior-r

# Running the Python script to parse the results to a csv file

python3 parse-ior.py *.txt

# Running the R script to generate the graphics

./plot-ior.R

# Saving results and intermediate files

cp -f results-ior.csv ../../../asm-eurolab-project-files/results-database/results-ior-r.csv
cp -f figs-ior.pdf ../../../asm-eurolab-project-files/results-figures/figs-ior-r.pdf
cp -rf ../out-ior-r ../../../asm-eurolab-project-files/out-files

## Running IOR-s

echo 'xxxxxxxxxxxxxxxxxx'
echo 'Running ior-segments'
echo 'xxxxxxxxxxxxxxxxxx'

cd ../

# Running the filters with a Bash script

./run-ior-s.sh tmpfs passthrough
./run-ior-s.sh fuse passthrough
./run-ior-s.sh tmpfs passthrough_ll
./run-ior-s.sh fuse passthrough_ll
./run-ior-s.sh tmpfs passthrough_fh
./run-ior-s.sh fuse passthrough_fh

cp -f ../../asm-eurolab-project-files/python-scripts/parse-ior.py out-ior-s
cp -f ../../asm-eurolab-project-files/r-scripts/plot-ior.R out-ior-s

cd out-ior-s

# Running the Python script to parse the results to a csv file

python3 parse-ior.py *.txt

# Running the R script to generate the graphics

# ./plot-ior.R

# Saving results and intermediate files

cp -f results-ior.csv ../../../asm-eurolab-project-files/results-database/results-ior-s.csv
# cp -f figs-ior.pdf ../../../asm-eurolab-project-files/results-figures/figs-ior-s.pdf
cp -rf ../out-ior-s ../../../asm-eurolab-project-files/out-files

## Running IOR-s-mpi

echo 'xxxxxxxxxxxxxxxxxx'
echo 'Running ior-segments-mpi'
echo 'xxxxxxxxxxxxxxxxxx'

cd ../

# Running the filters with a Bash script

./run-ior-s-mpi.sh tmpfs passthrough
./run-ior-s-mpi.sh fuse passthrough
./run-ior-s-mpi.sh tmpfs passthrough_ll
./run-ior-s-mpi.sh fuse passthrough_ll
./run-ior-s-mpi.sh tmpfs passthrough_fh
./run-ior-s-mpi.sh fuse passthrough_fh

cp -f ../../asm-eurolab-project-files/python-scripts/parse-ior-s-mpi.py out-ior-s-mpi
cp -f ../../asm-eurolab-project-files/r-scripts/plot-ior-s-mpi.R out-ior-s-mpi

cd out-ior-s-mpi

# Running the Python script to parse the results to a csv file

python3 parse-ior-s-mpi.py *.txt

# Running the R script to generate the graphics

./plot-ior-s-mpi.R

# Saving results and intermediate files

cp -f results-ior.csv ../../../asm-eurolab-project-files/results-database/results-ior-s-mpi.csv
cp -f figs-ior.pdf ../../../asm-eurolab-project-files/results-figures/figs-ior-s-mpi.pdf
cp -rf ../out-ior-s-mpi ../../../asm-eurolab-project-files/out-files

# Cleaning the files

cd ..
rm -rf out-ior
rm -rf out-ior-r
rm -rf out-ior-s
rm -rf out-ior-s-mpi
rm run-ior.sh
rm run-ior-r.sh
rm run-ior-s.sh
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

cp -f ../../asm-eurolab-project-files/python-scripts/parse-md.py out-md
cp -f ../../asm-eurolab-project-files/r-scripts/plot-md.R out-md

cd out-md

# Running the Python script to parse the results to a csv file

python3 parse-md.py *.txt

# Running the R script to generate the graphics

./plot-md.R

# Saving results and intermediate files

cp -f results-md.csv ../../../asm-eurolab-project-files/results-database
cp -f figs-md.pdf ../../../asm-eurolab-project-files/results-figures
cp -rf ../out-md ../../../asm-eurolab-project-files/out-files

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
