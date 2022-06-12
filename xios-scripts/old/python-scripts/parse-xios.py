#!/usr/bin/env python3
import sys
import re
import csv

# Create the output filename

filename = "results.csv"

# Open the output file

fd = open(filename, "w")
fields = ["TIME", "INITIAL", "DUMPCTL"]
out = csv.DictWriter(fd, fieldnames=fields, delimiter=',', quoting=csv.QUOTE_MINIMAL)
out.writeheader()

data_M = {}

# Parse the data for the information inside the result file

f = open("time.txt", "r")

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

fd.close()

