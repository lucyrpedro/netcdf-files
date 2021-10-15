#!/usr/bin/env Rscript

# Options for the input parameters

# 0   test parameters
# 1   real parameters

# Options for the output parameters

# time
# throughput

# ########################################################

options(scipen = 999) # disable scientific notation

args = commandArgs(trailingOnly = TRUE)

pdf("figs-dd.pdf") # either save all files in one pdf or the files in specific pdfs; find an option to automatise the choice

d = read.csv("results-dd.csv")

filter_op     = levels(as.factor(d$filter))
blocksize_op  = levels(as.factor(d$blocksize))
size_op       = levels(as.factor(d$size))

for (k in 1:length(filter_op)){

    d_filter    = subset(d,   filter == filter_op[k])

    # print(d_filter)

    read_tmpfs_time     = subset(d_filter, operation == 'read'  & dir_mem == 'tmpfs')
    read_fuse_time      = subset(d_filter, operation == 'read'  & dir_mem == 'fuse')
    write_tmpfs_time    = subset(d_filter, operation == 'write' & dir_mem == 'tmpfs')
    write_fuse_time     = subset(d_filter, operation == 'write' & dir_mem == 'fuse')

    for (j in 1:length(size_op)){

        x_read_tmpfs_time     = numeric(0)
        x_read_fuse_time      = numeric(0)
        x_write_tmpfs_time    = numeric(0)
        x_write_fuse_time     = numeric(0)

        x_read_tmpfs_tp       = numeric(0)
        x_read_fuse_tp        = numeric(0)
        x_write_tmpfs_tp      = numeric(0)
        x_write_fuse_tp       = numeric(0)

        for (i in 1:length(blocksize_op)){

            x_read_tmpfs      = subset(read_tmpfs_time,    size == size_op[j] & blocksize == blocksize_op[i])
            x_read_fuse       = subset(read_fuse_time,     size == size_op[j] & blocksize == blocksize_op[i])
            x_write_tmpfs     = subset(write_tmpfs_time,   size == size_op[j] & blocksize == blocksize_op[i])
            x_write_fuse      = subset(write_fuse_time,    size == size_op[j] & blocksize == blocksize_op[i])

            x_read_tmpfs_time       = c(x_read_tmpfs_time,  x_read_tmpfs$time)
            x_read_fuse_time        = c(x_read_fuse_time,   x_read_fuse$time)
            x_write_tmpfs_time      = c(x_write_tmpfs_time, x_write_tmpfs$time)
            x_write_fuse_time       = c(x_write_fuse_time,  x_write_fuse$time)

            x_read_tmpfs_tp       = c(x_read_tmpfs_tp,  x_read_tmpfs$tp)
            x_read_fuse_tp        = c(x_read_fuse_tp,   x_read_fuse$tp)
            x_write_tmpfs_tp      = c(x_write_tmpfs_tp, x_write_tmpfs$tp)
            x_write_fuse_tp       = c(x_write_fuse_tp,  x_write_fuse$tp)

        }

        # Plotting the results

        len_bs = length(blocksize_op)               # number of options for the blocksize
        len = length(x_read_tmpfs_time)/len_bs;     # number of run

        # #### TIME READ

        DF = data.frame(
        x = c(x_read_tmpfs_time, x_read_fuse_time),
        y = rep(c("TIME READ TMPFS", "TIME READ FUSE"), each = len_bs*len),
        z = rep(rep(1:len_bs, each = len), 2), # two categories, tmpfs and fuse
        stringsAsFactors = FALSE
        )
    #   str(DF)
    #   print(DF)

        filename = sprintf("%s_%s_time_%s.pdf", filter_op[k], size_op[j], "read");
        title = sprintf("DD - Filter %s - Size %s bytes", filter_op[k], size_op[j]);

#        pdf(filename)
        cols = rainbow(len_bs, s = 0.5)
        boxplot(x ~ z + y, data = DF,
                at = c(1:(2*len_bs)), col = cols,
                names = c("tmpfs", rep("", len_bs-1), "fuse", rep("", len_bs-1)),
                xaxs = FALSE, main = title, ylab = "Time Read (in seconds)")
        legend("topright", fill = cols, legend = blocksize_op, horiz = F, title = "Blocksize (in bytes)")

        # #### TIME WRITE

        DF = data.frame(
        x = c(x_write_tmpfs_time, x_write_fuse_time),
        y = rep(c("TIME WRITE TMPFS", "TIME WRITE FUSE"), each = len_bs*len),
        z = rep(rep(1:len_bs, each = len), 2), # two categories, tmpfs and fuse
        stringsAsFactors = FALSE
        )
    #    str(DF)
    #    print(DF)

        filename = sprintf("%s_%s_time_%s.pdf", filter_op[k], size_op[j], "write");
        title = sprintf("DD - Filter %s - Size %s bytes", filter_op[k], size_op[j]);

#        pdf(filename)
        cols = rainbow(len_bs, s = 0.5)
        boxplot(x ~ z + y, data = DF,
                at = c(1:(2*len_bs)), col = cols,
                names = c("tmpfs", rep("", len_bs-1), "fuse", rep("", len_bs-1)),
                xaxs = FALSE, main = title, ylab = "Time Write (in seconds)")
        legend("topright", fill = cols, legend = blocksize_op, horiz = F, title = "Blocksize (in bytes)")

        # #### TP READ

        DF = data.frame(
        x = c(x_read_tmpfs_tp, x_read_fuse_tp),
        y = rep(c("TP READ TMPFS", "TP READ FUSE"), each = len_bs*len),
        z = rep(rep(1:len_bs, each = len), 2), # two categories, tmpfs and fuse
        stringsAsFactors = FALSE
        )
    #    str(DF)
    #    print(DF)

        filename = sprintf("%s_%s_tp_%s.pdf", filter_op[k], size_op[j], "read");
        title = sprintf("DD - Filter %s - Size %s bytes", filter_op[k], size_op[j]);

#        pdf(filename)
        cols = rainbow(len_bs, s = 0.5)
        boxplot(x ~ z + y, data = DF,
                at = c(1:(2*len_bs)), col = cols,
                names = c("tmpfs", rep("", len_bs-1), "fuse", rep("", len_bs-1)),
                xaxs = FALSE, main = title, ylab = "Throughput Read (in MB/s)")
        legend("topleft", fill = cols, legend = blocksize_op, horiz = F, title = "Blocksize (in bytes)")

        # #### TP WRITE

        DF = data.frame(
        x = c(x_write_tmpfs_tp, x_write_fuse_tp),
        y = rep(c("TP WRITE TMPFS", "TP WRITE FUSE"), each = len_bs*len),
        z = rep(rep(1:len_bs, each = len), 2), # two categories, tmpfs and fuse
        stringsAsFactors = FALSE
        )
    #    str(DF)
    #    print(DF)

        filename = sprintf("%s_%s_tp_%s.pdf", filter_op[k], size_op[j], "write");
        title = sprintf("DD - Filter %s - Size %s bytes", filter_op[k], size_op[j]);

#        pdf(filename)
        cols = rainbow(len_bs, s = 0.5)
        boxplot(x ~ z + y, data = DF,
                at = c(1:(2*len_bs)), col = cols,
                names = c("tmpfs", rep("", len_bs-1), "fuse", rep("", len_bs-1)),
                xaxs = FALSE, main = title, ylab = "Throughput Write (in MB/s)")
        legend("topleft", fill = cols, legend = blocksize_op, horiz = F, title = "Blocksize (in bytes)")

    }

}

# dev.off()
print("Graphics constructed with success!")
