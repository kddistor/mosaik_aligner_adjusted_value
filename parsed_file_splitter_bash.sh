#!/usr/bin/bash
#Parsed Ace file compiler
for FILE in *.csv
do
#split file into eights
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
