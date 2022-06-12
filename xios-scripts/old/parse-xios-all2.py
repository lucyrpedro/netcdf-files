#!/usr/bin/env python3
import sys
import re
import csv
import os

# Create the output filename

cwd = os.getcwd()
print(cwd)

filename = "results-took.csv"
file_old = cwd + "/" + filename

if os.path.exists(file_old):
  os.remove(file_old)
  
print(file_old)

# Open the output file

fd = open(filename, "w")
fields = ["SUITE", "TOOK", "NUMBER"]
out = csv.DictWriter(fd, fieldnames=fields, delimiter=',', quoting=csv.QUOTE_MINIMAL)
out.writeheader()

data_M = {}

f_dir = open("aux-files/dir.txt", "r")
for file in f_dir:
#    print(file)

    # Parse the data for the information inside the filename

    #data_M["SUITE"] = file.strip()
#    print(file)

    # Change to the suite directory

    # Parse the data for the information inside the result file

    filename = cwd + "/results/" + file.strip() + "/took.txt";
#    print(filename)

    isFile = os.path.isfile(filename)
#    print(isFile)

    if isFile:

#        f = open(filename, "r")
        with open (filename, "r") as myfile:

#        for l in f:

            text = myfile.read()
#            print(text)

            for aux in range(1, 72):

                print("text")
                print(text)

                str = "{}".format(aux) + " took (?P<TOOK>[0-9.]*) seconds"
                print(str)
                
                m = re.match(str, text)
                print("m")
                print(m)

                if m:
                    data_M.update(m.groupdict())
                    data_M["NUMBER"] = aux
                
            out.writerow(data_M)

f_dir.close()

fd.close()

