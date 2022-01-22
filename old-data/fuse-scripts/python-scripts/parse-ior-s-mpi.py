#!/usr/bin/env python3
import sys
import re
import csv

# Command Line: python3 parse-file-ior.py *.txt

# # # # All data in MBs

# Create the output filename

filename = "results-ior-s-mpi.csv"

# Open the output file

fd = open(filename, "w")
fields = ["file", "time", "tp_MiB", "tp_MB", "filter", "dir_mem", "iter", "size", "operation", "options", "nproc", "size", "machine"]
out = csv.DictWriter(fd, fieldnames=fields, delimiter=',', quoting=csv.QUOTE_MINIMAL)
out.writeheader()

# "file"        filename
# "bytes"       number of bytes (information inside the result file)
# "MB"          number of bytes in MB (information inside the result file)
# "MiB"         number of bytes in MiB (information inside the result file)
# "time"        time to process the operation (information inside the result file)
# "tp"          throughput to process the operation (information inside the result file)

# "filter"      chosen filter (information inside the filename)
# "dir_mem"     directory where the memory is allocated (dev/shm/ or /mnt/dev/shm/) (information inside the filename)
# "iter"        iteration for the run with the same parameters (information inside the filename)
# "blocksize"   size of the block (information inside the filename)
# "transfersize"size (in bytes) of a single data buffer to be transferred in a single I/O call
# "size"        size of the file that is being write and read (information inside the filename)
# "operation"   type of operation (read/write) (information inside the filename)

# "options"     extra options for the benchmarks
# "read_time"   not filled on purpose
# "write_time"  not filled on purpose
# "read_tp"     not filled on purpose
# "write_tp"    not filled on purpose
# "sync_t"      ???
# "prefix"      ???
# "n"           ???
# "ppn"         ???
# "config"      ???
# "timesteps"   ???

data_M = {}
f_in = 0
f_out = 0

files = sys.argv[1:]
for file in files:

    f_in += 1
    data_M["file"] = file
    data_M["options"] = 'ior'
    data_M["machine"] = 'Sky1'

    # Parse the data for the information inside the filename

    n = re.match("(?P<filter>[a-z\_]*)-(?P<dir_mem>[a-z]*)-(?P<iter>[0-9]*)-(?P<size>[0-9]*)-(?P<nproc>[0-9]*).txt", file)

    if n:
        data_M.update(n.groupdict())

    # Parse the data for the information inside the result file

    f = open(file, "r")

    aux = 0
    for l in f:

        mw = re.match("read([ ]+)(?P<tp_MiB>[0-9.]*)([ ]+)([0-9.]*)([ ]+)([0-9.]*)([ ]+)([0-9.]*)([ ]+)(?P<time>[0-9.]*)([ ]+)([0-9.]*)([ ]+)([0-9.]*)([ ]+)0([ ]+)", l)

        if mw:
            data_M.update(mw.groupdict())
            data_M["tp_MB"] = float(mw[2])*1.048
            data_M["operation"] = 'read'
            out.writerow(data_M)
            f_out += 1
            aux += 1

    if aux == 0:
        print("Error processing file", file)

    f.close()

# print(f_in)
# print(f_out)

if f_in != f_out:
    print("Some files were not properly processed!")
else:
    print("Write parsing completed with success!")

data_M = {}
f_in = 0
f_out = 0

files = sys.argv[1:]
for file in files:

    f_in += 1
    data_M["file"] = file
    data_M["options"] = 'ior'

    # Parse the data for the information inside the filename

    n = re.match("(?P<filter>[a-z\_]*)-(?P<dir_mem>[a-z]*)-(?P<iter>[0-9]*)-(?P<size>[0-9]*)-(?P<nproc>[0-9]*).txt", file)

    if n:
        data_M.update(n.groupdict())

    # Parse the data for the information inside the result file

    f = open(file, "r")

    aux = 0
    for l in f:

        mr = re.match("write([ ]+)(?P<tp_MiB>[0-9.]*)([ ]+)([0-9.]*)([ ]+)([0-9.]*)([ ]+)([0-9.]*)([ ]+)(?P<time>[0-9.]*)([ ]+)([0-9.]*)([ ]+)([0-9.]*)([ ]+)0([ ]+)", l)

        if mr:
            data_M.update(mr.groupdict())
            data_M["tp_MB"] = float(mr[2])*1.048
            data_M["operation"] = 'write'
            out.writerow(data_M)
            f_out += 1
            aux += 1;

    if aux == 0:
        print("Error processing file", file)

    f.close()

fd.close()

# print(f_in)
# print(f_out)

if f_in != f_out:
    print("Some files were not properly processed!")
else:
    print("Read parsing completed with success!")
