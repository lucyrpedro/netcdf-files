#!/bin/bash

./res4.sh
./parse-xios-all5.py
./parse-xios-took2.py
./calc-size-all.sh

git add -A; git commit -m "files"; git push;

