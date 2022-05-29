#!/usr/bin/env Rscript

# ########################################################

pdf("temp.pdf") # either save all files in one pdf or the files in specific pdfs; find an option to automatise the choice

# temp_inst = read.csv("temp-inst.csv")
# temp_max = read.csv("temp-max.csv")
# temp_min = read.csv("temp-min.csv")
# temp_mean = read.csv("temp-mean.csv")

# data = read.table("test.csv", header=FALSE, sep = ',')
temp_inst = read.table("temp-inst.csv", header=FALSE, sep = ',')
temp_max = read.table("temp-max.csv", header=FALSE, sep = ',')
temp_min = read.table("temp-min.csv", header=FALSE, sep = ',')

x1=length(temp_inst)
x2=length(temp_max)
x3=length(temp_min)
# x4=length(data)

print(x1)
print(x2)
print(x3)
#print(x4)
#print(data)

x = seq(1, x1, 1)

plot(x,temp_inst,type="l",col="blue")
lines(x,temp_max,col="green")
lines(x,temp_min,col="red")

# dev.off()
print("Graphics constructed with success!")
