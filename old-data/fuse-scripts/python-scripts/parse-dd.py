#!/usr/bin/env python3
import sys
import re
import csv

#### All data in MBs

# Create the output filename

filename = "results-dd.csv"

# Open the output file

fd = open(filename, "w")
fields = ["file", "bytes", "MB", "MiB", "time", "tp", "filter", "dir_mem", "iter", "blocksize", "size", "operation", "options", "machine"]
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
#    print(file)
    data_M["file"] = file
    data_M["options"] = 'dd'
    data_M["machine"] = 'Sky1'

    # Parse the data for the information inside the filename

    n = re.match("(?P<filter>[a-z\_]*)-(?P<dir_mem>[a-z]*)-(?P<iter>[0-9]*)-(?P<blocksize>[0-9]*)-(?P<size>[0-9]*)-(read|write).txt", file)

    if n:
        #print(n.group(6))
        data_M.update(n.groupdict())
        if (n.group(6) == 'read'):
            data_M["operation"] = 'read'
        if (n.group(6) == 'write'):
            data_M["operation"] = 'write'

    # Parse the data for the information inside the result file

    f = open(file, "r")

    aux = 0
    for l in f:

        m = re.match("(?P<bytes>[0-9]*) bytes \((?P<MB>[0-9.]+) (kB|MB|GB), (?P<MiB>[0-9.]+) (KiB|MiB|GiB)\) copied, (?P<time>[0-9.]+) s, (?P<tp>[0-9.]+) (kB|MB|GB)/s", l)
        if m:
            data_M.update(m.groupdict())
            if (m.group(3) == 'GB'):
                value = float(m[2])*1024
                data_M["MB"] = value
            if (m.group(3) == 'kB'):
                value = float(m[2])/1024
                data_M["MB"] = value
            if (m.group(5) == 'GiB'):
                value = float(m[4])*1024
                data_M["MiB"] = value
            if (m.group(5) == 'KiB'):
                value = float(m[4])/1024
                data_M["MiB"] = value
            if (m.group(8) == 'GB'):
                value = float(m[7])*1024
                data_M["tp"] = value
            if (m.group(8) == 'kB'):
                value = float(m[7])/1024
                data_M["tp"] = value
            out.writerow(data_M)
            f_out += 1
            aux += 1

    if aux == 0:
        print("Error processing file", file)

    f.close()

fd.close()

# print(f_in)
# print(f_out)

if f_in != f_out:
    print("Some files were not properly processed!")
else:
    print("Parsing completed with success!")
