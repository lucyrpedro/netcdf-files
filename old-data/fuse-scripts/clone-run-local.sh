# !/bin/bash

# Bash Script for cloning the files and run the tests

# Local machine, small parameters

git clone https://github.com/lucyrpedro/asm-eurolab-project-files.git

cd asm-eurolab-project-files/

./prepare.sh

## Running the tests ###

./run-local.sh clean test 3
