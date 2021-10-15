# !/bin/bash

# Bash Script for cloning the files and run the tests with FUSE2

# Options: Parameter $1

# test      small parameters (short run)
# none      real parameters (long run)

# Options: Parameter $2

# run      Number of runs

## Copying files ###

git clone https://github.com/lucyrpedro/asm-eurolab-project-files.git

./prepare.sh

echo 'Copying ior'
cp /home/pedro/ior-3.2.1/build/src/ior asm-eurolab-project-files/benchmarks

echo 'Copying md-benchwork'
cp /home/pedro/md-workbench/build/src/md-workbench asm-eurolab-project-files/benchmarks

echo 'Copying Fuse2 Filters'
cp fusexmp libfuse/build/example/
cp fusexmp_fh libfuse/build/example/

## Running the tests ###

cd asm-eurolab-project-files/

./run-fuse2.sh clean $1 $2
