#!/bin/bash

# suites=2

./size-x.sh u-ch427-n1280-x
./size-x.sh u-ch427-n1280-x5

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
#done


