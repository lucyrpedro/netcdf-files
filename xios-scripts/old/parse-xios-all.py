#!/usr/bin/env python3
import sys
import re
import csv
import os

# Create the output filename

cwd = os.getcwd()
print(cwd)

filename = "results.csv"
file_old = cwd + "/" + filename

if os.path.exists(file_old):
  os.remove(file_old)
  
print(file_old)

# Open the output file

fd = open(filename, "w")
fields = ["SUITE", "TIME", "INITIAL", "DUMPCTL"]
out = csv.DictWriter(fd, fieldnames=fields, delimiter=',', quoting=csv.QUOTE_MINIMAL)
out.writeheader()

data_M = {}

f_dir = open("aux-files/dir.txt", "r")
for file in f_dir:
    print(file)

    # Parse the data for the information inside the filename

    data_M["SUITE"] = file.strip()
    print(file)

    # Change to the suite directory

    # Parse the data for the information inside the result file

    filename = cwd + "/results/" + file.strip() + "/time.txt";
    print(filename)

    isFile = os.path.isfile(filename)
    print(isFile)

    if isFile:

        f = open(filename, "r")

        for l in f:
    
            print(l)

            m1 = re.match("(.*) 0 Elapsed Wallclock Time: (?P<TIME>[0-9.]*) ", l)
            m2 = re.match("(.*) INITIAL 1 (?P<INITIAL>[0-9.]+) ", l)
            m3 = re.match("(.*) DUMPCTL 1 (?P<DUMPCTL>[0-9.]+) ", l)

            if m1:    
                data_M.update(m1.groupdict())        
            if m2:
                data_M.update(m2.groupdict())
            if m3:
                data_M.update(m3.groupdict())
                
        f.close()
        
        out.writerow(data_M)

f_dir.close()

fd.close()

