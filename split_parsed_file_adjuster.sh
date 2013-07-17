#!/usr/bin/bash
dir=$(pwd)
for i in *.out
do
echo "$dir/$i"
R --quiet --no-save <<HEREFILE
options(warn=-1)
data <- read.csv("$dir/$i", header=T)
data["total_hits"] <- NA
lengthcol <- length(data[,1])
lengthrow <- length(data[1,]) - 1
data\$total_hits <- rowSums(data[2:lengthrow], na.rm = TRUE)
data <- sapply(data, function(x) x / data[,ncol(data)])
data <- rbind(data, c(State="Total",apply(data[,-1], 2, sum, na.rm=TRUE)))
final <- data[lengthcol+1,]
write.table(final, "$dir/$i.UTE_tags.final", sep=",", quote=FALSE)
HEREFILE
done
