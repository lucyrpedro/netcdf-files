#!/bin/bash

./res4.sh
./res-1280.sh
./parse-xios-all5.py
./parse-xios-took3.py
./calc-size-all.sh
./calc-size-all-n1280.sh

git add -A; git commit -m "files"; git push;

