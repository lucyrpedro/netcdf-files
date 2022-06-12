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
fields = ["SUITE", "TOOK SIZE", "TOOK 0", "TOOK TOTAL", "TOOK MEAN", "TOOK 6 MEAN", "TOOK 8 MEAN", "TOOK 12 MEAN", "TOOK 6 TOTAL", "TOOK 8 TOTAL", "TOOK 12 TOTAL","TOOK TI", "TOOK 6 TI", "TOOK 8 TI","TOOK 12 TI"]
out = csv.DictWriter(fd, fieldnames=fields, delimiter=',', quoting=csv.QUOTE_MINIMAL)
out.writeheader()

data_M = {}

f_dir = open("aux-files/paper.txt", "r")
for file in f_dir:
#    print(file)

    # Parse the data for the information inside the filename

    data_M["SUITE"] = file.strip()
    print(file)

    # Change to the suite directory

    # Parse the data for the information inside the result file

    filename = cwd + "/results/" + file.strip() + "/took.txt";
    print(filename)

    isFile = os.path.isfile(filename)
#    print(isFile)

    if isFile:

        f = open(filename, "r")
        with open (filename, "r") as myfile:

#        for l in f:

            text = myfile.read()
#            print(text)
            text = text.split();
            ntook=text.count('took')
            print(ntook)

            data_M["TOOK SIZE"] = ntook

            took_list = []

            for i in range(0, ntook):
                pos=7*i+5
#                print("%s" % (text[pos]))
                took_list.append(text[pos])

#            for i in range(0, ntook):
#                print(took_list[i])

            took_vector = []
            for item in took_list:
                took_vector.append(float(item))
            
            print(took_vector)

            filename_took = cwd + "/results/" + file.strip() + "/took.csv";
            with open(filename_took, 'w') as myfile2:
                wr = csv.writer(myfile2, quoting=csv.QUOTE_ALL)
                wr.writerow(took_vector)

            total=0;
            for i in range(0, ntook):
                total=total+took_vector[i]

            total_6=0;
            for i in range(0, ntook, 6):
#                print(i)
                total_6=total_6+took_vector[i]

            total_8=0;
            for i in range(0, ntook, 8):
#                print(i)
                total_8=total_8+took_vector[i]

            total_12=0;
            for i in range(0, ntook, 12):
#                print(i)
                total_12=total_12+took_vector[i]

            data_M["TOOK TOTAL"] = round(total, 2)
            data_M["TOOK 6 TOTAL"] = round(total_6, 2)
            data_M["TOOK 8 TOTAL"] = round(total_8, 2)
            data_M["TOOK 12 TOTAL"] = round(total_12, 2)

            data_M["TOOK 0"] = round(took_vector[0], 2)

            total=total-took_vector[0] # Remove the initial time
            total_6=total_6-took_vector[0] # Remove the initial time
            total_8=total_8-took_vector[0] # Remove the initial time
            total_12=total_12-took_vector[0] # Remove the initial time

            data_M["TOOK TI"] = round(total, 2)
            data_M["TOOK 6 TI"] = round(total_6, 2)
            data_M["TOOK 8 TI"] = round(total_8, 2)
            data_M["TOOK 12 TI"] = round(total_12, 2)


            if total!=0:
                mean=total/ntook;
                data_M["TOOK MEAN"] = round(mean, 2)

            if total_6!=0:
                mean_6=total_6*6/ntook;
                data_M["TOOK 6 MEAN"] = round(mean_6, 2)

            if total_8!=0:
                mean_8=total_8*8/ntook;
                data_M["TOOK 8 MEAN"] = round(mean_8, 2)

            if total_12!=0:
                mean_12=total_12*12/ntook;
                data_M["TOOK 12 MEAN"] = round(mean_12, 2)

            print(round(total, 2))
            print(round(total_6, 2))
            print(round(total_8, 2))
            print(round(total_12, 2))
            print(round(mean, 2))
            print(round(mean_6, 2))
            print(round(mean_8, 2))
            print(round(mean_12, 2))

            out.writerow(data_M)

f_dir.close()

fd.close()

