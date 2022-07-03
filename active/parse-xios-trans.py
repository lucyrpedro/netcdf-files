#!/usr/bin/env python3
import sys
import re
import csv
import os

# Create the output filename

cwd = os.getcwd()
print(cwd)

filename = "results-trans.csv"
file_old = cwd + "/" + filename

if os.path.exists(file_old):
  os.remove(file_old)
  
# print(file_old)

# Open the output file

fd = open(filename, "w")
fields = ["TOTAL"]
out = csv.DictWriter(fd, fieldnames=fields, delimiter=',', quoting=csv.QUOTE_MINIMAL)
out.writeheader()

data_M = {}

filename = "trans.txt";
print(filename)

isFile = os.path.isfile(filename)
#    print(isFile)

if isFile:

    f = open(filename, "r")
    with open (filename, "r") as myfile:

#        for l in f:

        text = myfile.read()
#        print(text)
        text = text.split();
#        print(text)
        ntook=text.count('time')
        print(ntook)

        if ntook:

            took_list = []

#            for i in range(0, 50):
#                print("%d" % (i))
#                print("%s" % (text[i]))

            for i in range(0, ntook):
                pos=7+8*i
#                print("%s" % (text[pos]))
                took_list.append(text[pos])

#            for i in range(0, ntook):
#                print(took_list[i])

            took_vector = []
            for item in took_list:
                took_vector.append(float(item))
            
#            print(took_vector)

            filename_took = "results-trans.csv";
            with open(filename_took, 'w') as myfile2:
                wr = csv.writer(myfile2, quoting=csv.QUOTE_ALL)
                wr.writerow(took_vector)

            total=0;
            for i in range(1, ntook):
                total=total+took_vector[i]

            data_M["TOTAL"] = round(total, 2)

            print(total)

            out.writerow(data_M)

fd.close()

