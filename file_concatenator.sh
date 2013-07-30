#!/usr/bin/bash

#########################################
#  Eighth Files Concatenator			#
#	by Kevin Distor						#
#	University of California, Davis		#
#########################################################################################################################################
#Step 5 - Put all files together in one file to get the relative TE abundance for the original file.									#
#	The final step of this pipeline involves combining all 8 adjusted files and adding the TE counts. This is done with R script		#
#	in the form of a shell script called "file_concatenator.sh". Once the TE counts are added, the final output is one line				#
#	of TEs and their adjusted counts. The default output for this part of the pipeline is labled "$dir.adujsted_alignmentscore.txt"		#
#	where $dir is the name of the orginal input sequence.																				#
#																																		#
#########################################################################################################################################

#Loop to process each adjusted eighth file
dir=$(pwd)
for i in *.final
do
#File will have header cut off because the previous step wrote an unecessary header line.
sed -i 1d $i
#File will second to last line cut off because previous step wrote an unecessary null row(x). Store new process file to 
#parsed_ace_final.csv.1st.out.final.temp to Default is parsed_ace_final.csv.8th.out.final.temp
sed -n '$!x;1!p' $i > $i.temp
done
R --quiet --no-save <<HEREFILE
#Read each eight file as a csv file
data1 <- read.csv("$dir/parsed_ace_final.csv.1st.out.UTE_tags.final.temp", header=T, row.names = 1)
data2 <- read.csv("$dir/parsed_ace_final.csv.2nd.out.UTE_tags.final.temp", header=T, row.names = 1)
data3 <- read.csv("$dir/parsed_ace_final.csv.3rd.out.UTE_tags.final.temp", header=T, row.names = 1)
data4 <- read.csv("$dir/parsed_ace_final.csv.4th.out.UTE_tags.final.temp", header=T, row.names = 1)
data5 <- read.csv("$dir/parsed_ace_final.csv.5th.out.UTE_tags.final.temp", header=T, row.names = 1)
data6 <- read.csv("$dir/parsed_ace_final.csv.6th.out.UTE_tags.final.temp", header=T, row.names = 1)
data7 <- read.csv("$dir/parsed_ace_final.csv.7th.out.UTE_tags.final.temp", header=T, row.names = 1)
data8 <- read.csv("$dir/parsed_ace_final.csv.8th.out.UTE_tags.final.temp", header=T, row.names = 1)
#Assign a threshhold value using sum of file "parsed_ace_final.csv.1st.out.final.temp" first column. 
thresh <- sum(data1\$Total)/2
#The threshhold value is used to create a subset for each eighth which we can process.
data1x <- subset(data1,data1\$Total<thresh)
data2x <- subset(data2,data2\$Total<thresh)
data3x <- subset(data3,data3\$Total<thresh)
data4x <- subset(data4,data4\$Total<thresh)
data5x <- subset(data5,data5\$Total<thresh)
data6x <- subset(data6,data6\$Total<thresh)
data7x <- subset(data7,data7\$Total<thresh)
data8x <- subset(data8,data8\$Total<thresh)
#Put all off data in a data frame
All <- cbind(data1x,data2x,data3x,data4x,data5x,data6x,data7x,data8x)
#Create a new collumn "total_hits" and push the sum of the values in the row to that collumn
All["total_hits"] <- NA
All\$total_hits <- rowSums(All[1:8], na.rm = TRUE)
#Sum the "total_hits" column to get alignment value. This alignment value should be equal to Mosaik's total alignment in step 1.
sumx <- sum(All\$total_hits)
#Write alignment value default final.csv
write.table(sumx, "$dir/final.csv", sep=",", quote=FALSE)
HEREFILE
#Get alignment value and move to ~mosaik/bin directory.
tail -1 final.csv > $dir.adujsted_alignmentscore.txt
cp $dir.adujsted_alignmentscore.txt ~/mosaik/bin
