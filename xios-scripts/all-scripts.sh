#!/bin/bash

./res3.sh
./res-1280.sh
./parse-xios-all3.py
./calc-size.sh
./calc-size-x.sh

git add -A; git commit -m "files"; git push;

