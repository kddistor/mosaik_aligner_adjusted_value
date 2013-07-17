#!/usr/bin/bash
#Mosaik Pipeline full
#by Kevin Distor
#Build input sequence files into native MOSAIK file format
for FILE in *.fastq
do
./MosaikBuild -q $FILE -out $FILE.dat -st illumina
done
for FILE in *.fastq.dat
do
#Align reads to UTE_tags
./MosaikAligner -in $FILE -out $FILE.align -ia UTE_tags.dat -hs 10 -minp 0.3 -mmp 0.2 -mhp 100 -act 11 -mmal  -p 16 > $FILE.UTE_tags.txt
./MosaikSort -in $FILE.align -out $FILE.sorted -nu
#Assemble ace files
./MosaikAssembler -in $FILE.sorted -ia UTE_tags.dat -out $FILE.UTE_tags.assembled
#Create directory with name of Maize line
mkdir ~/mosaik/assembled_$FILE.UTE_tags
for file in *.ace
do
#Move assembled ace files to sequence directory
mv $file ~/mosaik/assembled_$FILE.UTE_tags
#Copy all scripts to parse alignment data into sequence directory
cp one_hash_ace_parser.pl ~/mosaik/assembled_$FILE.UTE_tags
cp UTE_tags.fasta ~/mosaik/assembled_$FILE.UTE_tags
cp parsed_file_splitter.sh ~/mosaik/assembled_$FILE.UTE_tags
cp R_bash_here_file.sh ~/mosaik/assembled_$FILE.UTE_tags
done
rm $FILE
done
for i in /home/kvdistor/mosaik/assembled_*;
#Go into each sequence directory and invoke scripts to parse Ace Files. Move Alignment file to 
do (cd "$i" && perl one_hash_ace_parser.pl && sh parsed_file_splitter_bash.sh && sh split_parsed_file_adjuster.sh && sh file_concatenator.sh);
done
#Remove all unneccesary MosaikFiles
for FILE in *.sorted
do
rm $FILE
done
for FILE in *.align
do
rm $FILE
done
# for FILE in *.txt
# do
# mv $FILE ~/dnasim/
# done
