#!/usr/bin/env Rscript

# ########################################################

pdf("temp.pdf") # either save all files in one pdf or the files in specific pdfs; find an option to automatise the choice

# temp_inst = read.csv("temp-inst.csv")
# temp_max = read.csv("temp-max.csv")
# temp_min = read.csv("temp-min.csv")
# temp_mean = read.csv("temp-mean.csv")

# data = read.table("test.csv", header=FALSE, sep = ',')
temp_inst1 = read.table("inst12.txt", header=FALSE, sep = ',')
temp_inst2 = read.table("inst22.txt", header=FALSE, sep = ',')
temp_max = read.table("max2.txt", header=FALSE, sep = ',')
temp_min = read.table("min2.txt", header=FALSE, sep = ',')
temp_mean = read.table("mean2.txt", header=FALSE, sep = ',')
temp_stdev = read.table("stdev2.txt", header=FALSE, sep = ',')

x1=length(temp_inst1)
x2=length(temp_inst2)
x3=length(temp_max)
x4=length(temp_min)
x5=length(temp_mean)
x6=length(temp_stdev)

print(x1)
print(x2)
print(x3)
print(x4)
print(x5)
print(x6)

x = seq(1, x1, 1)

lmin = min(temp_inst1,temp_inst2,temp_max,temp_min,temp_mean)
print(lmin)

lmax = max(temp_inst1,temp_inst2,temp_max,temp_min,temp_mean)
print(lmax)

plot(x,temp_inst1,type="l",col="blue",ylim = c(lmin, lmax),ylab="") 
par(new = TRUE)
plot(x,temp_inst2,type="l",col="pink",ylim = c(lmin, lmax),ylab="") 
par(new = TRUE)
plot(x,temp_max,type="l",col="green",ylim = c(lmin, lmax),ylab="") 
par(new = TRUE)
plot(x,temp_min,type="l",col="red",ylim = c(lmin, lmax),ylab="") 
par(new = TRUE)
plot(x,temp_mean,type="l",col="orange",ylim = c(lmin, lmax),ylab="") 
par(new = TRUE)
#lines(x,temp_stdev,col="pink")
plot_colors <- c("blue","pink","green","red","orange") 
par(new = TRUE)
legend(x = "top",inset = 0,
        legend = c("ens0", "ens1","max", "min","mean"), 
        col=plot_colors, lwd=5, cex=.5, horiz = TRUE)


xa = seq(1, 100, 1)


plot(xa,temp_inst1[1:100],type="s",col="blue",ylim = c(lmin, lmax),ylab="")
par(new = TRUE)
plot(xa,temp_inst2[1:100],type="s",col="pink",ylim = c(lmin, lmax),ylab="")
par(new = TRUE)
plot(xa,temp_max[1:100],type="p",col="green",ylim = c(lmin, lmax),ylab="")
par(new = TRUE)
plot(xa,temp_min[1:100],type="p",col="red",ylim = c(lmin, lmax),ylab="")
par(new = TRUE)
plot(xa,temp_mean[1:100],type="p",col="orange",ylim = c(lmin, lmax),ylab="")
par(new = TRUE)
#lines(x,temp_stdev,col="pink")
plot_colors <- c("blue","pink","green","red","orange")
par(new = TRUE)
legend(x = "top",inset = 0,
        legend = c("ens0", "ens1","max", "min","mean"),
        col=plot_colors, lwd=5, cex=.5, horiz = TRUE)


xb = seq(1, 10, 1)


plot(xb,temp_inst1[1:10],type="s",col="blue",ylim = c(lmin, lmax),ylab="")
par(new = TRUE)
plot(xb,temp_inst2[1:10],type="s",col="pink",ylim = c(lmin, lmax),ylab="")
par(new = TRUE)
plot(xb,temp_max[1:10],type="p",col="green",ylim = c(lmin, lmax),ylab="")
par(new = TRUE)
plot(xb,temp_min[1:10],type="p",col="red",ylim = c(lmin, lmax),ylab="")
par(new = TRUE)
plot(xb,temp_mean[1:10],type="p",col="orange",ylim = c(lmin, lmax),ylab="")
par(new = TRUE)
#lines(x,temp_stdev,col="pink")
plot_colors <- c("blue","pink","green","red","orange")
par(new = TRUE)
legend(x = "top",inset = 0,
        legend = c("ens0", "ens1","max", "min","mean"),
        col=plot_colors, lwd=5, cex=.5, horiz = TRUE)

#print(temp_inst1[1:10])
#print(temp_inst2[1:10])
#print(temp_max[1:10])
#print(temp_min[1:10])
#print(temp_mean[1:10])


plot(x,temp_inst1,type="l",col="blue",ylim = c(lmin, lmax),ylab="")
par(new = TRUE)
plot(x,temp_inst2,type="l",col="pink",ylim = c(lmin, lmax),ylab="")

plot(x,temp_max,type="l",col="green",ylim = c(lmin, lmax),ylab="")

plot(x,temp_min,type="l",col="red",ylim = c(lmin, lmax),ylab="")

plot(x,temp_mean,type="l",col="orange",ylim = c(lmin, lmax),ylab="")

#plot(x,temp_stdev,col="pink")

#dev.off()
print("Graphics constructed with success!")
