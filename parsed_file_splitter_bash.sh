#!/usr/bin/bash

#########################################
#  Parsed Ace File Splitter			#
#	by Kevin Distor						#
#	University of California, Davis		#
#################################################################################################################################
#Step 3 - Split the original parsed sequence file into eights																	#
#																																#
#	The generated csv file is then split into eight files. Each file will have TE names at the top and eight of the 			#
#	"parsed_ace_final.csv" file's read values. The ouput of this part is labled "$FILE.1st.out" to "$FILE.8th.out" where		#
#	$FILE is the name of the original input sequence at the beginning of the pipeline.											#
#																																#
#################################################################################################################################
#grab .csv parsed ace file
for FILE in *.csv
do
#Split parsed_ace_file.csv file into eights. Rationale: Server load can't parse a full file.
#Output by default is parsed_ace_final.csv.1st.out to parsed_ace_final.csv.8th.out
#The first file will have an eighth - 1 line of the original file.
#The second to seventh file will have an eighth of the original file.
#The eighth file will have an eighth of the original file plus the remainder of lines.
file_line_count=$(wc -l < $FILE)
line_count=$(($file_line_count-1))
split_line_count=$(($line_count/8))
head -$split_line_count $FILE > $FILE.1st.out
split_line_count_2=$(($split_line_count*2))
split_line_count_3=$(($split_line_count*3))
split_line_count_4=$(($split_line_count*4))
split_line_count_5=$(($split_line_count*5))
split_line_count_6=$(($split_line_count*6))
split_line_count_7=$(($split_line_count*7))
head -1 $FILE > $FILE.2nd.out
head -1 $FILE > $FILE.3rd.out
head -1 $FILE > $FILE.4th.out
head -1 $FILE > $FILE.5th.out
head -1 $FILE > $FILE.6th.out
head -1 $FILE > $FILE.7th.out
head -1 $FILE > $FILE.8th.out
split_line_count1=$(($split_line_count+1))
split_line_count2=$(($split_line_count_2+1))
split_line_count3=$(($split_line_count_3+1))
split_line_count4=$(($split_line_count_4+1))
split_line_count5=$(($split_line_count_5+1))
split_line_count6=$(($split_line_count_6+1))
split_line_count7=$(($split_line_count_7+1))
split_line_count8=$(($split_line_count_8+1))
sed -n "${split_line_count1},${split_line_count_2}p;${split_line_count_2}q" $FILE >> $FILE.2nd.out
sed -n "${split_line_count2},${split_line_count_3}p;${split_line_count_3}q" $FILE >> $FILE.3rd.out
sed -n "${split_line_count3},${split_line_count_4}p;${split_line_count_4}q" $FILE >> $FILE.4th.out
sed -n "${split_line_count4},${split_line_count_5}p;${split_line_count_5}q" $FILE >> $FILE.5th.out
sed -n "${split_line_count5},${split_line_count_6}p;${split_line_count_6}q" $FILE >> $FILE.6th.out
sed -n "${split_line_count6},${split_line_count_7}p;${split_line_count_7}q" $FILE >> $FILE.7th.out
sed -n "${split_line_count7},${file_line_count}p;${file_line_count}q" $FILE >> $FILE.8th.out
done
