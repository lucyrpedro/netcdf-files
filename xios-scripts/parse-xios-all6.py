#!/usr/bin/env python3
import sys
import re
import csv
import os

# Create the output filename

cwd = os.getcwd()
print(cwd)

filename = "results-time.csv"
file_old = cwd + "/" + filename

if os.path.exists(file_old):
  os.remove(file_old)
  print(file_old)

# Open the output file

fd = open(filename, "w")
fields = ["SUITE", "TIME", "INITIAL", "TIME-INITIAL","TIME-INITIAL-TOOK1","ENSEMBLE", "RESOLUTION", "NODES", "JOB_SUBMIT_TIME", "JOB_INIT_TIME", "JOB_EXIT_TIME", "JOB_STATUS" , "JOB_ID", "JOB_PID", "TOOK", "PROCX", "PROCY", "XIOS_NPROC"]
out = csv.DictWriter(fd, fieldnames=fields, delimiter=',', quoting=csv.QUOTE_MINIMAL)
out.writeheader()

f_dir = open("aux-files/dir.txt", "r")
for file in f_dir:
    data_M = {}
    print(file)

    # Parse the data for the information inside the filename

    data_M["SUITE"] = file.strip()
#    data_M["ENSEMBLE"] = file[-3:-1]
    m0 = re.match("(.*)u-ch427-n(?P<RESOLUTION>[0-9]*)-ens(.*)", file)
    if m0:
      data_M.update(m0.groupdict())

    # Change to the suite directory

    # Parse the data for the information inside time.txt

    filename = cwd + "/results/" + file.strip() + "/time.txt";

    isFile = os.path.isfile(filename)
    print(isFile)

    if isFile:

        f = open(filename, "r")

        for l in f:
    
            m1 = re.match("(.*)Elapsed Wallclock Time:(?P<TIME>[0-9. ]*)", l)
            m2 = re.match("(.*) INITIAL 1 [0-9.]+ [0-9.]+ (?P<INITIAL>[0-9.]+) ", l)
#            m3 = re.match("(.*) DUMPCTL 1 (?P<DUMPCTL>[0-9.]+) ", l) # It seems DUMPCTL doesn't exist anymore
            m4 = re.match("(.*)JOB_ID=(?P<JOB_ID>[0-9.]+)", l)
            m5 = re.match("(.*)JOB_PID=(?P<JOB_PID>[0-9.]+)", l)
            m6 = re.match("(.*)JOB_SUBMIT_TIME=(?P<JOB_SUBMIT_TIME>[0-9.TZ:-]+)", l)
            m7 = re.match("(.*)JOB_INIT_TIME=(?P<JOB_INIT_TIME>[0-9.TZ:-]+)", l)
            m8 = re.match("(.*)JOB_EXIT=(?P<JOB_STATUS>[SUCEDXIT]+)", l)
            m9 = re.match("(.*)JOB_EXIT_TIME=(?P<JOB_EXIT_TIME>[0-9.TZ:-]+)", l)
            m10 = re.match("(.*)nodes=(?P<NODES>[0-9]+)", l)
            m11 = re.match("(.*)UM_ATM_NENS=\"(?P<ENSEMBLE>[0-9]+)\"", l)
            m12 = re.match("(.*)UM_ATM_NPROCX=\"(?P<PROCX>[0-9]+)\"", l)
            m13 = re.match("(.*)UM_ATM_NPROCY=\"(?P<PROCY>[0-9]+)\"", l)
            m14 = re.match("(.*)XIOS_NPROC=\"(?P<XIOS_NPROC>[0-9]+)\"", l)
            m15 = re.match("(.*)(ga7p0)(.*)(n\"(?P<RESOLUTION>[0-9]+)\"e)(.*)", l)

            print(m1)
            if m1:    
                data_M.update(m1.groupdict())       
            if m2:
                data_M.update(m2.groupdict())
#            if m3:
#                data_M.update(m3.groupdict())
            if m4:
                data_M.update(m4.groupdict())
            if m5:
                data_M.update(m5.groupdict())
            if m6:
                data_M.update(m6.groupdict())
            if m7:
                data_M.update(m7.groupdict())
            if m8:
                data_M.update(m8.groupdict())
            if m9:
                data_M.update(m9.groupdict())
            if m10:
                data_M.update(m10.groupdict())
            if m11:
                data_M.update(m11.groupdict())
            if m12:
                data_M.update(m12.groupdict())
            if m13:
                data_M.update(m13.groupdict())
            if m14:
                data_M.update(m14.groupdict())
            if m15:
                data_M.update(m15.groupdict())

        f.close()

  # Parse the data for the information inside took.txt

    filename = cwd + "/results/" + file.strip() + "/took.txt";

    isFile = os.path.isfile(filename)

    if isFile:

      f = open(filename, "r")

      for l in f:
    
        m1 = re.match("(.*) took (?P<TOOK>[0-9.]*) ", l)

        if m1:    
            data_M.update(m1.groupdict())        
                
      f.close()

#    data_M["TIME-INITIAL"] = data_M["TIME"] - data_M["INITIAL"] (It doesn't work!)
        
    # This next command can be used to already exclude from the .csv the files that do not have took

    out.writerow(data_M)
#    data_M["TIME-INITIAL"] = data_M["TIME"] - data_M["INITIAL"] (It doesn't work!)
    print("EOF\n\n")

f_dir.close()

fd.close()

