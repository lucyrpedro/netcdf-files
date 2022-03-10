#!/bin/bash

# suites=2

./size-x.sh u-ch427-n1280-x
./size-x.sh u-ch427-n1280-x5
./size-x.sh u-ch427-n1280-x-orig
./size-x.sh u-ch427-n1280-x5-orig
./size-x.sh u-ch427-n1280-x-ms
./size-x.sh u-ch427-n1280-x5-ms
./size-pack.sh u-ch427-n1280-pack0
./size-pack.sh u-ch427-n1280-pack5

rm -rf total-all-suites-x.csv
touch total-all-suites-x.csv

#for (( c=0; c<=$suites; c++ ))
#do
	suite=u-ch427-n1280-x
	cat total-$suite.csv >> total-all-suites.csv
	cat blank.txt >> total-all-suites.csv
	suite=u-ch427-n1280-x5
        cat total-$suite.csv >> total-all-suites.csv
        cat blank.txt >> total-all-suites.csv
        suite=u-ch427-n1280-x-orig
        cat total-$suite.csv >> total-all-suites.csv
        cat blank.txt >> total-all-suites.csv
        suite=u-ch427-n1280-x5-orig
        cat total-$suite.csv >> total-all-suites.csv
        cat blank.txt >> total-all-suites.csv
        suite=u-ch427-n1280-x-ms
        cat total-$suite.csv >> total-all-suites.csv
        cat blank.txt >> total-all-suites.csv
        suite=u-ch427-n1280-x5-ms
        cat total-$suite.csv >> total-all-suites.csv
        cat blank.txt >> total-all-suites.csv	
        suite=u-ch427-n1280-pack0
        cat total-$suite.csv >> total-all-suites.csv
        cat blank.txt >> total-all-suites.csv
        suite=u-ch427-n1280-pack5
        cat total-$suite.csv >> total-all-suites.csv
        cat blank.txt >> total-all-suites.csv
#done


