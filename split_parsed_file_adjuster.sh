#!/usr/bin/bash

#########################################
#  Relative TE Abundance Calculator	#
#	by Kevin Distor						#
#	University of California, Davis		#
#####################################################################################################################################
#Part 4 - Get the Relative TE Abundance of each eighth parsed sequence file															#
#																																	#
#	The split files are then run through an R script in the form of a shell script called "split_parsed_file_adjuster.sh"			#
#	which takes alignment values and adjusts it based on how many reads were aligned. For example, if a read had a total			# 
#	3 alignments to transposable elements/repeats, all alignment values for that read would be adjusted to 1/3.The defualt 			#
#	output for this step is "$dir/$i.UTE_tags.final" where $dir is the name of the output file from step 6 and $i is the 			#
#	split file number.																												#
#																																	#
#####################################################################################################################################

#Loop to process each eighth file
dir=$(pwd)
for i in *.out
do
echo "$dir/$i"
#Invoke R to parse each eighth file
R --quiet --no-save <<HEREFILE
options(warn=-1)
data <- read.csv("$dir/$i", header=T)
#Create new column "total_hits" and fill with NA
data["total_hits"] <- NA
#Length of columns is stored
lengthcol <- length(data[,1])
#Length of row is stored. 1 is subtracted because there is a null column when file is read.
lengthrow <- length(data[1,]) - 1
#Store in to "total_hits" column the sum of the values of TEs from sequence files aligned to read of the row.
data\$total_hits <- rowSums(data[2:lengthrow], na.rm = TRUE)
#Divide the read row by the the number in the "total_hits" collumn. This calculates TE relative abundance.
data <- sapply(data, function(x) x / data[,ncol(data)])
#At the end of the file, make a new line that has the sum of the relative TE abundance from each read.
data <- rbind(data, c(State="Total",apply(data[,-1], 2, sum, na.rm=TRUE)))
#Write the last line to a file. Default is parsed_ace_final.csv.1st.out.final to Default is parsed_ace_final.csv.8th.out.final
final <- data[lengthcol+1,]
write.table(final, "$dir/$i.UTE_tags.final", sep=",", quote=FALSE)
HEREFILE
done
