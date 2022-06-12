#!/bin/bash

# suites=3

./size2.sh u-ch427-n96-max18
./size2.sh u-ch427-n96-max18-mf
./size2.sh u-ch427-n96-max18-single
./size2.sh u-ch427-n96-max18-stdev
./size2.sh u-ch427-n96-max18-stdev-one
./size2.sh u-ch427-n216-max18
./size2.sh u-ch427-n216-max18-mf
./size2.sh u-ch427-n216-max18-single
./size2.sh u-ch427-n216-max18-stdev
./size2.sh u-ch427-n216-max18-stdev-one
./size2.sh u-ch427-n512-max18
./size2.sh u-ch427-n512-max18-mf
./size2.sh u-ch427-n512-max18-single
./size2.sh u-ch427-n512-max18-stdev
./size2.sh u-ch427-n512-max18-stdev-one

rm -rf total/total-all-suites.csv
touch total/total-all-suites.csv

#for (( c=0; c<=$suites; c++ ))
#do
	suite=u-ch427-n96-max18
	cat total/total-$suite.csv >> total/total-all-suites.csv
	cat blank.txt >> total/total-all-suites.csv
	suite=u-ch427-n96-max18-mf
        cat total/total-$suite.csv >> total/total-all-suites.csv
        cat blank.txt >> total/total-all-suites.csv
	suite=u-ch427-n96-max18-single
        cat total/total-$suite.csv >> total/total-all-suites.csv
        cat blank.txt >> total/total-all-suites.csv
        suite=u-ch427-n96-max18-stdev
        cat total/total-$suite.csv >> total/total-all-suites.csv
        cat blank.txt >> total/total-all-suites.csv
        suite=u-ch427-n96-max18-stdev-one
        cat total/total-$suite.csv >> total/total-all-suites.csv
        cat blank.txt >> total/total-all-suites.csv
	suite=u-ch427-n216-max18
        cat total/total-$suite.csv >> total/total-all-suites.csv
        cat blank.txt >> total/total-all-suites.csv
        suite=u-ch427-n216-max18-mf
        cat total/total-$suite.csv >> total/total-all-suites.csv
        cat blank.txt >> total/total-all-suites.csv
        suite=u-ch427-n216-max18-single
        cat total/total-$suite.csv >> total/total-all-suites.csv
        cat blank.txt >> total/total-all-suites.csv
        suite=u-ch427-n216-max18-stdev
        cat total/total-$suite.csv >> total/total-all-suites.csv
        cat blank.txt >> total/total-all-suites.csv
        suite=u-ch427-n216-max18-stdev-one
        cat total/total-$suite.csv >> total/total-all-suites.csv
        cat blank.txt >> total/total-all-suites.csv
	suite=u-ch427-n512-max18
        cat total/total-$suite.csv >> total/total-all-suites.csv
        cat blank.txt >> total/total-all-suites.csv
        suite=u-ch427-n512-max18-mf
        cat total/total-$suite.csv >> total/total-all-suites.csv
        cat blank.txt >> total/total-all-suites.csv
        suite=u-ch427-n512-max18-single
        cat total/total-$suite.csv >> total/total-all-suites.csv
        cat blank.txt >> total/total-all-suites.csv
        suite=u-ch427-n512-max18-stdev
        cat total/total-$suite.csv >> total/total-all-suites.csv
        cat blank.txt >> total/total-all-suites.csv
        suite=u-ch427-n512-max18-stdev-one
        cat total/total-$suite.csv >> total/total-all-suites.csv
        cat blank.txt >> total/total-all-suites.csv
#done


