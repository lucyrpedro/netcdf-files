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


plot(x,temp_inst[1:27648],type="l",col="blue")
plot(x,temp_inst[27649:55296],type="l",col="blue")
lines(x,temp_max,col="green")
lines(x,temp_min,col="red")
lines(x,temp_mean,col="orange")
#lines(x,temp_stdev,col="pink")
plot_colors <- c("blue","green","red","orange", "pink")
legend(x = "top",inset = 0,
        legend = c("Instant", "Max", "Min","Mean", "Stdev"), 
        col=plot_colors, lwd=5, cex=.5, horiz = TRUE)


plot(x,temp_inst[1:27648],type="l",col="blue")
lines(x,temp_inst[27649:55296],type="l",col="blue")

plot(x,temp_max,col="green")

plot(x,temp_min,col="red")

plot(x,temp_mean,col="orange")

#plot(x,temp_stdev,col="pink")

# dev.off()
print("Graphics constructed with success!")
