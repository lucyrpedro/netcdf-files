#!/usr/bin/env Rscript

# R Script for Running IOR

# Options for the output parameters

# time
# throughput

# ########################################################

args = commandArgs(trailingOnly=TRUE)

pdf("figs-ior-s-mpi-r.pdf") # either save all files in one pdf or the files in specific pdfs; find an option to automatise the choice

d = read.csv("results-ior-s-mpi-r.csv")

filter_op     = levels(as.factor(d$filter))
size_op       = levels(as.factor(d$size))
nproc_op      = levels(as.factor(d$nproc))

for (k in 1:length(filter_op)){

    d_filter    = subset(d,   filter == filter_op[k])

#    print(d_filter)

    read_tmpfs      = subset(d_filter, operation == 'read'  & dir_mem == 'tmpfs')
    read_fuse       = subset(d_filter, operation == 'read'  & dir_mem == 'fuse')
    write_tmpfs     = subset(d_filter, operation == 'write' & dir_mem == 'tmpfs')
    write_fuse      = subset(d_filter, operation == 'write' & dir_mem == 'fuse')

#    print(read_tmpfs)

    for (j in 1:length(size_op)){

        read_tmpfs_time    = numeric(0)
        read_fuse_time     = numeric(0)
        write_tmpfs_time   = numeric(0)
        write_fuse_time    = numeric(0)

        read_tmpfs_tp    = numeric(0)
        read_fuse_tp     = numeric(0)
        write_tmpfs_tp   = numeric(0)
        write_fuse_tp    = numeric(0)

        for (i in 1:length(nproc_op)){

            x_read_tmpfs      = subset(read_tmpfs,   size == size_op[j] & nproc == nproc_op[i])
            x_read_fuse       = subset(read_fuse,    size == size_op[j] & nproc == nproc_op[i])
            x_write_tmpfs     = subset(write_tmpfs,  size == size_op[j] & nproc == nproc_op[i])
            x_write_fuse      = subset(write_fuse,   size == size_op[j] & nproc == nproc_op[i])

#            print(x_read_tmpfs)

            read_tmpfs_time       = c(read_tmpfs_time, x_read_tmpfs$time)
            read_fuse_time        = c(read_fuse_time, x_read_fuse$time)
            write_tmpfs_time      = c(write_tmpfs_time, x_write_tmpfs$time)
            write_fuse_time       = c(write_fuse_time, x_write_fuse$time)

            read_tmpfs_tp         = c(read_tmpfs_tp, x_read_tmpfs$tp_MB)
            read_fuse_tp          = c(read_fuse_tp, x_read_fuse$tp_MB)
            write_tmpfs_tp        = c(write_tmpfs_tp, x_write_tmpfs$tp_MB)
            write_fuse_tp         = c(write_fuse_tp, x_write_fuse$tp_MB)

        }

        # Plotting the results

        len_bs = length(nproc_op)       # number of options for the nproc
        len = length(read_tmpfs_time)/len_bs;   # number of run

        # #### TIME READ

#        print(read_tmpfs_time)

    if (length(read_tmpfs_time) == length(read_fuse_time)){

        DF = data.frame(
        x = c(read_tmpfs_time, read_fuse_time),
        y = rep(c("READ TMPFS", "READ FUSE"), each = len_bs*len),
        z = rep(rep(1:len_bs, each = len), 2), # two categories, tmpfs and fuse
        stringsAsFactors = FALSE
        )
#        str(DF)
#        print(DF)

        filename = sprintf("%s_%s_time_%s.pdf", filter_op[k], size_op[j], "read");
        title = sprintf("IOR Random - Filter %s - Size %s bytes", filter_op[k], size_op[j]);

#        pdf(filename)
        cols = rainbow(len_bs, s = 0.5)
        boxplot(x ~ z + y, data = DF,
                at = c(1:(2*len_bs)), col = cols,
                names = c("tmp", rep("", len_bs-1), "f", rep("", len_bs-1)),
                xaxs = FALSE, main = title, ylab = "Time Read (in seconds)")
        legend("topright", fill = cols, legend = nproc_op, horiz = F, title = "# Proc")

    } else {
    print (length(read_tmpfs_time))
    print (length(read_fuse_time))
    }

        # #### TIME WRITE

    if (length(write_tmpfs_time) == length(write_fuse_time)){

        DF = data.frame(
        x = c(write_tmpfs_time, write_fuse_time),
        y = rep(c("WRITE TMPFS", "WRITE FUSE"), each = len_bs*len),
        z = rep(rep(1:len_bs, each = len), 2), # two categories, tmpfs and fuse
        stringsAsFactors = FALSE
        )
    #    str(DF)
    #    print(DF)

        filename = sprintf("%s_%s_time_%s.pdf", filter_op[k], size_op[j], "write");
        title = sprintf("IOR Random - Filter %s - Size %s bytes", filter_op[k], size_op[j]);

#        pdf(filename)
        cols = rainbow(len_bs, s = 0.5)
        boxplot(x ~ z + y, data = DF,
                at = c(1:(2*len_bs)), col = cols,
                names = c("tmp", rep("", len_bs-1), "f", rep("", len_bs-1)),
                xaxs = FALSE, main = title, ylab = "Time Write (in seconds)")
        legend("topright", fill = cols, legend = nproc_op, horiz = F, title = "# Proc")

    } else {
    print (length(write_tmpfs_time))
    print (length(write_fuse_time))
    }

        # #### TP READ

    if (length(read_tmpfs_tp) == length(read_fuse_tp)){

        DF = data.frame(
        x = c(read_tmpfs_tp, read_fuse_tp),
        y = rep(c("READ TMPFS", "READ FUSE"), each = len_bs*len),
        z = rep(rep(1:len_bs, each = len), 2), # two categories, tmpfs and fuse
        stringsAsFactors = FALSE
        )
    #    str(DF)
    #    print(DF)

        filename = sprintf("%s_%s_tp_%s.pdf", filter_op[k], size_op[j], "read");
        title = sprintf("IOR Random - Filter %s - Size %s bytes", filter_op[k], size_op[j]);

#        pdf(filename)
        cols = rainbow(len_bs, s = 0.5)
        boxplot(x ~ z + y, data = DF,
                at = c(1:(2*len_bs)), col = cols,
                names = c("tmp", rep("", len_bs-1), "f", rep("", len_bs-1)),
                xaxs = FALSE, main = title, ylab = "Throughput Read (in MB/s)")
        legend("topleft", fill = cols, legend = nproc_op, horiz = F, title = "# Proc")

    } else {
    print (length(read_tmpfs_tp))
    print (length(read_fuse_tp))
    }

        # #### TP WRITE

    if (length(write_tmpfs_tp) == length(write_fuse_tp)){

        DF = data.frame(
        x = c(write_tmpfs_tp, write_fuse_tp),
        y = rep(c("WRITE TMPFS", "WRITE FUSE"), each = len_bs*len),
        z = rep(rep(1:len_bs, each = len), 2), # two categories, tmpfs and fuse
        stringsAsFactors = FALSE
        )
    #    str(DF)
    #    print(DF)

        filename = sprintf("%s_%s_tp_%s.pdf", filter_op[k], size_op[j], "write");
        title = sprintf("IOR Random - Filter %s - Size %s bytes", filter_op[k], size_op[j]);

#        pdf(filename)
        cols = rainbow(len_bs, s = 0.5)
        boxplot(x ~ z + y, data = DF,
                at = c(1:(2*len_bs)), col = cols,
                names = c("tmp", rep("", len_bs-1), "f", rep("", len_bs-1)),
                xaxs = FALSE, main = title, ylab = "Throughput Write (in MB/s)")
        legend("topleft", fill = cols, legend = nproc_op, horiz = F, title = "# Proc")

    } else {
    print (length(write_tmpfs_tp))
    print (length(write_fuse_tp))
    }

    }

}

# dev.off()
print("Graphics constructed with success!")
