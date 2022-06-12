#!/usr/bin/env python3
import sys
import re
import csv
import os

# Create the output filename

filename = "test.csv"

# Open the output file

fd = open(filename, "w")
fields = ["SUITE", "TIME", "NODES"]
out = csv.DictWriter(fd, fieldnames=fields, delimiter=',', quoting=csv.QUOTE_MINIMAL)
out.writeheader()

data_M = {}

f_dir = open("test.txt", "r")

for file in f_dir:
    print(file)

    # Parse the data for the information inside the filename

    data_M["SUITE"] = file.strip()

    # Parse the data for the information inside time.txt

    cwd = os.getcwd()
    filename = cwd + "/results/" + file.strip() + "/time.txt";

    isFile = os.path.isfile(filename)
    print(isFile)

    if isFile:

        f = open(filename, "r")

        for l in f:

            print(filename)
            print(l)

            m1 = re.search("0 Elapsed Wallclock Time: (?P<TIME>[0-9.]*) ", l)
            m10 = re.search("nodes=(?P<NODES>[0-9]+)", l)

            if m1 is not None:    
                print(m1)
                data_M.update(m1.groupdict())       
#                data_M["TIME"] = m1
                m1 = None
#                print(file)
#                print(l)
#                print(m1)
#            else: 
#                m1 = ""
#                data_M.update(m1.groupdict())
            if m10 is not None:
                print(m10)
                data_M.update(m10.groupdict())
#                data_M["NODES"] = m10
#               del m10
                m10 = None

            m1 = None
            m10 = None

        f.close()

        out.writerow(data_M)

f_dir.close()

fd.close()

