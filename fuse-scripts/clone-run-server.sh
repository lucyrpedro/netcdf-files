# !/bin/bash

# Bash Script for cloning the files and run the tests wuth FUSE3

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

## Running the tests ###

cd asm-eurolab-project-files/

./run-server.sh clean $1 $2
