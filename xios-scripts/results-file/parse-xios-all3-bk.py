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
fields = ["SUITE", "TIME", "INITIAL", "ENSEMBLE", "RESOLUTION", "NODES", "JOB_SUBMIT_TIME", "JOB_INIT_TIME", "JOB_EXIT_TIME", "JOB_STATUS" , "JOB_ID", "JOB_PID", "TOOK1", "TOOK2", "TOOK3"]
out = csv.DictWriter(fd, fieldnames=fields, delimiter=',', quoting=csv.QUOTE_MINIMAL)
out.writeheader()

f_dir = open("aux-files/dir.txt", "r")
for file in f_dir:
    data_M = {}
    print(file)

    # Parse the data for the information inside the filename

    data_M["SUITE"] = file.strip()
    data_M["ENSEMBLE"] = file[-3:-1]
#    data_M["RESOLUTION"] = file[9:12]
    m0 = re.match("(.*)u-ch427-n(?P<RESOLUTION>[0-9]*)-ens(.*)", file)
    if m0:
#     print(m0)
      data_M.update(m0.groupdict())
      del m0

#    print(data_M["SUITE"])

    # Change to the suite directory

    # Parse the data for the information inside time.txt

    filename = cwd + "/results/" + file.strip() + "/time.txt";
#    print(filename)

    isFile = os.path.isfile(filename)
    print(isFile)

    if isFile:

        f = open(filename, "r")

        for l in f:
    
#            print(l)

            m1 = re.match("(.*) 0 Elapsed Wallclock Time: (?P<TIME>[0-9.]*) ", l)
            m2 = re.match("(.*) INITIAL 1 [0-9.]+ [0-9.]+ (?P<INITIAL>[0-9.]+) ", l)
#            m3 = re.match("(.*) DUMPCTL 1 (?P<DUMPCTL>[0-9.]+) ", l) # It seems DUMPCTL doesn't exist anymore
            m4 = re.match("(.*)JOB_ID=(?P<JOB_ID>[0-9.]+)", l)
            m5 = re.match("(.*)JOB_PID=(?P<JOB_PID>[0-9.]+)", l)
            m6 = re.match("(.*)JOB_SUBMIT_TIME=(?P<JOB_SUBMIT_TIME>[0-9.TZ:-]+)", l)
            m7 = re.match("(.*)JOB_INIT_TIME=(?P<JOB_INIT_TIME>[0-9.TZ:-]+)", l)
            m8 = re.match("(.*)JOB_EXIT=(?P<JOB_STATUS>[SUCED]+)", l)
            m9 = re.match("(.*)JOB_EXIT_TIME=(?P<JOB_EXIT_TIME>[0-9.TZ:-]+)", l)
            m10 = re.match("(.*)nodes=(?P<NODES>[0-9]+)", l)

            if m1 is not None:    
#                print(m1)
                data_M.update(m1.groupdict())       
                m1 = None
#                print(file)
#                print(l)
#                print(m1)
#            else: 
#                m1 = "0"
#                data_M.update(m1.groupdict())
            if m2:
#                print(m2)
                data_M.update(m2.groupdict())
                m2 = None
#            if m3:
#                data_M.update(m3.groupdict())
#                del m3
                m3 = None

            if m4:
#                print(m4)
                data_M.update(m4.groupdict())
#                del m4
                m4 = None
            if m5:
#                print(m5)
                data_M.update(m5.groupdict())
#                del m5
                m5 = None

            if m6:
#                print(m6)
                data_M.update(m6.groupdict())
#               del m6
                m6 = None
            if m7:
#                print(m7)
                data_M.update(m7.groupdict())
#               del m7
                m7 = None
            if m8:
#                print(m8)
                data_M.update(m8.groupdict())
#               del m8
                m8 = None
            if m9:
#                print(m9)
                data_M.update(m9.groupdict())
#               del m9
                m9 = None
            if m10:
#                print(m10)
                data_M.update(m10.groupdict())
#               del m10
                m10 = None

            del l

        f.close()

  # Parse the data for the information inside took.txt

    filename = cwd + "/results/" + file.strip() + "/took.txt";
#   print(filename)

    isFile = os.path.isfile(filename)
#   print(isFile)

    if isFile:

      f = open(filename, "r")

      for l in f:
    
     #   print(l)

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

      print("EOF\n\n")

f_dir.close()

fd.close()

