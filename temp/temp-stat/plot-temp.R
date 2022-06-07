#!/usr/bin/env Rscript

# ########################################################

pdf("temp.pdf") # either save all files in one pdf or the files in specific pdfs; find an option to automatise the choice

# temp_inst = read.csv("temp-inst.csv")
# temp_max = read.csv("temp-max.csv")
# temp_min = read.csv("temp-min.csv")
# temp_mean = read.csv("temp-mean.csv")

# data = read.table("test.csv", header=FALSE, sep = ',')
temp_inst = read.table("inst2.txt", header=FALSE, sep = ',')
temp_max = read.table("max2.txt", header=FALSE, sep = ',')
temp_min = read.table("min2.txt", header=FALSE, sep = ',')
temp_mean = read.table("mean2.txt", header=FALSE, sep = ',')
temp_stdev = read.table("stdev2.txt", header=FALSE, sep = ',')

x1=length(temp_inst)
x2=length(temp_max)
x3=length(temp_min)
x4=length(temp_mean)
x5=length(temp_stdev)

print(x1)
print(x2)
print(x3)
print(x4)
print(x5)

x = seq(1, x2, 1)


plot(x,temp_inst[1:27648],type="s",col="blue") 
par(new = TRUE)
plot(x,temp_inst[27649:55296],type="s",col="pink") 
par(new = TRUE)
plot(x,temp_max,type="p",col="green",) 
par(new = TRUE)
plot(x,temp_min,type="p",col="red") 
par(new = TRUE)
plot(x,temp_mean,type="p",col="orange") 
par(new = TRUE)
#lines(x,temp_stdev,col="pink")
plot_colors <- c("blue","pink","green","red","orange") 
par(new = TRUE)
legend(x = "top",inset = 0,
        legend = c("ens0", "ens1","max", "min","mean"), 
        col=plot_colors, lwd=5, cex=.5, horiz = TRUE)


plot(x,temp_inst[1:27648],col="blue")
par(new = TRUE)
plot(x,temp_inst[27649:55296],col="pink")

plot(x,temp_max,col="green")

plot(x,temp_min,col="red")

plot(x,temp_mean,col="orange")

#plot(x,temp_stdev,col="pink")

# dev.off()
print("Graphics constructed with success!")
