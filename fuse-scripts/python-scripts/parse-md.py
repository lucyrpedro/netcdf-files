#!/usr/bin/env python3
import sys
import re
import csv

# Python Script for Running MD-WORKBENCH

# Command Line: python3 parse-file-md.py *.txt

# # # # All data in MBs

# Create the output filename

filename = "results-md.csv"

# Open the output file

fd = open(filename, "w")
fields = ["file", "bytes", "MB", "MiB", "time", "tp", "filter", "dir_mem", "iter", "blocksize", "transfersize", "isize", "psize", "size", "options", "read_time1", "write_time1", "read_time2", "write_time2", "read_time3", "write_time3", "read_time4", "write_time4", "read_time5", "write_time5", "read_time6", "write_time6", "read_time7", "write_time7", "read_tp", "write_tp", "prefix", "n", "ppn", "config", "timesteps", "sync_t", "nproc", "rate_iops", "rate_objs", "total_time"]
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

# "nproc"       number of processors
# "rate_iops"   rate iops/s
# "rate_objs"   rate objs/s

data_M = {}
f_in = 0
f_out = 0

files = sys.argv[1:]
for file in files:
    f_in += 1
    data_M["file"] = file
    data_M["options"] = 'md'

    # Parse the data for the information inside the filename

    n = re.match("(?P<filter>[a-z\_]*)-(?P<dir_mem>[a-z\_]*)-(?P<iter>[0-9]*)-(?P<isize>[0-9]*)-(?P<psize>[0-9]*)-(?P<nproc>[0-9]*).txt", file)

    if n:
        data_M.update(n.groupdict())

    # Parse the data for the information inside the result file

    f = open(file, "r")

    aux = 0;
    for l in f:

        m = re.match(".*benchmark process.*rate:(?P<rate_iops>[0-9.]*) iops/s.*rate:(?P<rate_objs>[0-9.]*) obj/s.*op-max:([0-9e.\-+]*)s.*read\((?P<read_time1>[0-9e.\-+]*)s, (?P<read_time2>[0-9e.\-+]*)s, (?P<read_time3>[0-9e.\-+]*)s, (?P<read_time4>[0-9e.\-+]*)s, (?P<read_time5>[0-9e.\-+]*)s, (?P<read_time6>[0-9e.\-+]*)s, (?P<read_time7>[0-9e.\-+]*)s\).*stat\(([0-9e.\-+]*)s.*create\((?P<write_time1>[0-9e.\-+]*)s, (?P<write_time2>[0-9e.\-+]*)s, (?P<write_time3>[0-9e.\-+]*)s, (?P<write_time4>[0-9e.\-+]*)s, (?P<write_time5>[0-9e.\-+]*)s, (?P<write_time6>[0-9e.\-+]*)s, (?P<write_time7>[0-9e.\-+]*)s\).*delete\(([0-9e.\-+]*)s.*", l)

        if m:
            data_M.update(m.groupdict())
            f_out += 1
            aux += 1

        m2 = re.match(".*Total runtime: (?P<total_time>[0-9]*)s.*", l)

        if m2:
            data_M.update(m2.groupdict())
            out.writerow(data_M)
            f_out += 1
            aux += 1

    if aux == 0:
        print("Error processing file", file)

    f.close()

fd.close()

# print(f_in)
# print(f_out/2)

if f_in != f_out/2:
    print("Some files were not properly processed!")
else:
    print("Parsing completed with success!")
