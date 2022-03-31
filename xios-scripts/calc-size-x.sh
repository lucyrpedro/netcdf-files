#!/bin/bash

./size-pack.sh u-ch427-n1280-pack0
./size-pack.sh u-ch427-n1280-pack5
./size-pack.sh u-ch427-n1280-start-paper-pack0
./size-pack.sh u-ch427-n1280-start-paper-pack5

rm -rf total-all-suites-x.csv
touch total-all-suites-x.csv

        suite=u-ch427-n1280-pack0
        cat total-$suite.csv >> total-all-suites.csv
        cat blank.txt >> total-all-suites.csv
        suite=u-ch427-n1280-pack5
        cat total-$suite.csv >> total-all-suites.csv
        cat blank.txt >> total-all-suites.csv
        suite=u-ch427-n1280-start-paper-pack0
        cat total-$suite.csv >> total-all-suites.csv
        cat blank.txt >> total-all-suites.csv
        suite=u-ch427-n1280-start-paper-pack5
        cat total-$suite.csv >> total-all-suites.csv
        cat blank.txt >> total-all-suites.csv


