#!/bin/bash

# suites=3

./size-paper.sh u-ch427-n96-start-paper
./size-paper.sh u-ch427-n96-template-start-paper-00
./size-paper.sh u-ch427-n216-template-start-paper-00
./size-paper.sh u-ch427-n512-template-start-paper-00

rm -rf total-all-suites-paper.csv
touch total-all-suites-paper.csv

#for (( c=0; c<=$suites; c++ ))
#do
	suite=u-ch427-n96-start-paper
	cat total-$suite.csv >> total-all-suites-paper.csv
	suite=u-ch427-n96-template-start-paper-00
        cat total-$suite.csv >> total-all-suites-paper.csv
	suite=u-ch427-n216-template-start-paper-00
        cat total-$suite.csv >> total-all-suites-paper.csv
        suite=u-ch427-n512-template-start-paper-00
        cat total-$suite.csv >> total-all-suites-paper.csv
#done


