#!/usr/bin/env python3
import sys
import re
import csv
import os

# Create the output filename

cwd = os.getcwd()
print(cwd)

filename = "results3.csv"
file_old = cwd + "/" + filename

if os.path.exists(file_old):
  os.remove(file_old)
  
print(file_old)

# Open the output file

fd = open(filename, "w")
fields = ["SUITE", "TIME", "INITIAL", "DUMPCTL", "JOB_ID", "JOB_PID", "JOB_SUBMIT_TIME", "JOB_INIT_TIME", "JOB_EXIT_TIME", "JOB_STATUS" , "TOOK1", "TOOK2", "TOOK3"]
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

    # Parse the data for the information inside time.txt

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
            m4 = re.match("(.*)JOB_ID=(?P<JOB_ID>[0-9.]+)", l)
            m5 = re.match("(.*)JOB_PID=(?P<JOB_PID>[0-9.]+)", l)
            m6 = re.match("(.*)JOB_SUBMIT_TIME=(?P<JOB_SUBMIT_TIME>[0-9.TZ:-]+)", l)
            m7 = re.match("(.*)JOB_INIT_TIME=(?P<JOB_INIT_TIME>[0-9.TZ:-]+)", l)
            m8 = re.match("(.*)CYLC_JOB_EXIT=(?P<JOB_STATUS>[SUCED]+)(.*)", l)
            m9 = re.match("(.*)JOB_EXIT_TIME=(?P<JOB_EXIT_TIME>[0-9.TZ:-]+)", l)

            if m1:    
                data_M.update(m1.groupdict())       
                del m1
            if m2:
                data_M.update(m2.groupdict())
                del m2
            if m3:
                data_M.update(m3.groupdict())
                del m3
            if m4:
                data_M.update(m4.groupdict())
                del m4
            if m5:
                data_M.update(m5.groupdict())
                del m5
            if m6:
                data_M.update(m6.groupdict())
                del m6
            if m7:
                data_M.update(m7.groupdict())
                del m7
            if m8:
                data_M.update(m8.groupdict())
                del m8
            if m9:
                data_M.update(m9.groupdict())
                del m9
                
        f.close()

    # Parse the data for the information inside took.txt

    filename = cwd + "/results/" + file.strip() + "/took.txt";
    print(filename)

    isFile = os.path.isfile(filename)
    print(isFile)

    if isFile:

        f = open(filename, "r")

        for l in f:
    
            print(l)

            m1 = re.match("(.*) 1 took (?P<TOOK1>[0-9.]*) ", l)
            m2 = re.match("(.*) 2 took (?P<TOOK2>[0-9.]*) ", l)
            m3 = re.match("(.*) 3 took (?P<TOOK3>[0-9.]*) ", l)

            if m1:    
                data_M.update(m1.groupdict())        
                del m1
            if m2:
                data_M.update(m2.groupdict())
                del m2
            if m3:
                data_M.update(m3.groupdict())
                del m3
                
        f.close()
        
        out.writerow(data_M)

f_dir.close()

fd.close()

