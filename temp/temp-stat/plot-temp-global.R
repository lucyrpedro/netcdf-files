#!/usr/bin/env Rscript

# ########################################################

pdf("temp-global.pdf") # either save all files in one pdf or the files in specific pdfs; find an option to automatise the choice

# temp_inst = read.csv("temp-inst.csv")
# temp_max = read.csv("temp-max.csv")
# temp_min = read.csv("temp-min.csv")
# temp_mean = read.csv("temp-mean.csv")

# data = read.table("test.csv", header=FALSE, sep = ',')
temp_max = read.table("max3.txt", header=FALSE, sep = ',')
temp_min = read.table("min3.txt", header=FALSE, sep = ',')
temp_mean = read.table("mean3.txt", header=FALSE, sep = ',')

x3=length(temp_max)
x4=length(temp_min)
x5=length(temp_mean)

print(x3)
print(x4)
print(x5)

x = seq(1, x3, 1)

lmin = min(temp_min)
print(lmin)

lmax = max(temp_max)
print(lmax)

plot(x,temp_max,type="p",col="green",ylim = c(lmin, lmax),ylab="", pch = 2, cex = .1) 
par(new = TRUE)
plot(x,temp_min,type="p",col="red",ylim = c(lmin, lmax),ylab="", pch = 6, cex = .1) 
par(new = TRUE)
plot(x,temp_mean,type="b",col="orange",ylim = c(lmin, lmax),ylab="", pch = 20, cex = .5) 
par(new = TRUE)
plot_colors <- c("blue","green","orange") 
par(new = TRUE)
legend(x = "top",inset = 0,
        legend = c("max", "min","mean"), 
        col=plot_colors, lwd=5, cex=.5, horiz = TRUE)

plot(x,temp_max,type="o",col="green",ylim = c(lmin, lmax),ylab="", pch = 2, cex = .1)
par(new = TRUE)
plot(x,temp_min,type="o",col="red",ylim = c(lmin, lmax),ylab="", pch = 6, cex = .1)
par(new = TRUE)
plot(x,temp_mean,type="o",col="orange",ylim = c(lmin, lmax),ylab="", pch = 20, cex = .5)
par(new = TRUE)
plot_colors <- c("blue","green","orange")
par(new = TRUE)
legend(x = "top",inset = 0,
        legend = c("max", "min","mean"),
        col=plot_colors, lwd=5, cex=.5, horiz = TRUE)

#dev.off()
print("Graphics constructed with success!")
