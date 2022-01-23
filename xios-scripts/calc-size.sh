#!/bin/bash

# suites=3

./size.sh u-ch427-n96-max18
./size.sh u-ch427-n96-max18-mf
./size.sh u-ch427-n96-max18-single
./size.sh u-ch427-n96-max18-stdev
./size.sh u-ch427-n96-max18-stdev-one
./size.sh u-ch427-n216-max18
./size.sh u-ch427-n216-max18-mf
./size.sh u-ch427-n216-max18-single
./size.sh u-ch427-n216-max18-stdev
./size.sh u-ch427-n216-max18-stdev-one
./size.sh u-ch427-n512-max18
./size.sh u-ch427-n512-max18-mf
./size.sh u-ch427-n512-max18-single
./size.sh u-ch427-n512-max18-stdev
./size.sh u-ch427-n512-max18-stdev-one

rm -rf total-all-suites.csv
touch total-all-suites.csv

#for (( c=0; c<=$suites; c++ ))
#do
	suite=u-ch427-n96-max18
	cat total-$suite.csv >> total-all-suites.csv
	cat blank.txt >> total-all-suites.csv
	suite=u-ch427-n96-max18-mf
        cat total-$suite.csv >> total-all-suites.csv
        cat blank.txt >> total-all-suites.csv
	suite=u-ch427-n96-max18-single
        cat total-$suite.csv >> total-all-suites.csv
        cat blank.txt >> total-all-suites.csv
        suite=u-ch427-n96-max18-stdev
        cat total-$suite.csv >> total-all-suites.csv
        cat blank.txt >> total-all-suites.csv
        suite=u-ch427-n96-max18-stdev-one
        cat total-$suite.csv >> total-all-suites.csv
        cat blank.txt >> total-all-suites.csv
	suite=u-ch427-n216-max18
        cat total-$suite.csv >> total-all-suites.csv
        cat blank.txt >> total-all-suites.csv
        suite=u-ch427-n216-max18-mf
        cat total-$suite.csv >> total-all-suites.csv
        cat blank.txt >> total-all-suites.csv
        suite=u-ch427-n216-max18-single
        cat total-$suite.csv >> total-all-suites.csv
        cat blank.txt >> total-all-suites.csv
        suite=u-ch427-n216-max18-stdev
        cat total-$suite.csv >> total-all-suites.csv
        cat blank.txt >> total-all-suites.csv
        suite=u-ch427-n216-max18-stdev-one
        cat total-$suite.csv >> total-all-suites.csv
        cat blank.txt >> total-all-suites.csv
	suite=u-ch427-n512-max18
        cat total-$suite.csv >> total-all-suites.csv
        cat blank.txt >> total-all-suites.csv
        suite=u-ch427-n512-max18-mf
        cat total-$suite.csv >> total-all-suites.csv
        cat blank.txt >> total-all-suites.csv
        suite=u-ch427-n512-max18-single
        cat total-$suite.csv >> total-all-suites.csv
        cat blank.txt >> total-all-suites.csv
        suite=u-ch427-n512-max18-stdev
        cat total-$suite.csv >> total-all-suites.csv
        cat blank.txt >> total-all-suites.csv
        suite=u-ch427-n512-max18-stdev-one
        cat total-$suite.csv >> total-all-suites.csv
        cat blank.txt >> total-all-suites.csv
#done


