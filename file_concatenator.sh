#!/usr/bin/bash
count=0
dir=$(pwd)
for i in *.final
do
sed -i 1d $i
sed -n '$!x;1!p' $i > $i.temp
# echo "$dir/$i"
count=$(($count+1))
echo "$count"
dir$count=$i
done
R --quiet --no-save <<HEREFILE
data1 <- read.csv("$dir/parsed_ace_final.csv.1st.out.UTE_tags.final.temp", header=T)
data2 <- read.csv("$dir/parsed_ace_final.csv.2nd.out.UTE_tags.final.temp", header=T)
data3 <- read.csv("$dir/parsed_ace_final.csv.3rd.out.UTE_tags.final.temp", header=T)
data4 <- read.csv("$dir/parsed_ace_final.csv.4th.out.UTE_tags.final.temp", header=T)
data5 <- read.csv("$dir/parsed_ace_final.csv.5th.out.UTE_tags.final.temp", header=T)
data6 <- read.csv("$dir/parsed_ace_final.csv.6th.out.UTE_tags.final.temp", header=T)
data7 <- read.csv("$dir/parsed_ace_final.csv.7th.out.UTE_tags.final.temp", header=T)
data8 <- read.csv("$dir/parsed_ace_final.csv.8th.out.UTE_tags.final.temp", header=T)
All <- cbind(data1,data2,data3,data4,data5,data6,data7,data8)
All["total_hits"] <- NA
All\$total_hits <- rowSums(All[2:7], na.rm = TRUE)
write.table(All\$total_hits, "C:/cygwin/home/Kevin/Perl/FullPipeMosaik/final.csv", sep=",", quote=FALSE)
HEREFILE
tail -1 final.csv > $dir.adujsted_alignmentscore.txt
cp $dir.adujsted_alignmentscore.txt ~/mosaik/bin
