#$ -S /bin/bash
#$ -cwd
#$ -N test
#$ -pe threaded 16
#
#
#################################################
#  Relative TE Abundance using Mosaik			#
#	by Kevin Distor								#
#	University of California, Davis				#
#########################################################################################################################################
#STEP 1 - Invoke Master Script																											#
#																																		#
#	This is the master script to invoke all scripts to get relative TE abundance for each sequence file based on the reference used. 	#
#	This master file contains all of Mosaik's steps as well as the moving of files to respective sequence directories where the parsing #
#	will happen. Finally this file cleans all unnecessary files																			#
#																																		#
#########################################################################################################################################
#Build input sequence(fastq) files into native MOSAIK file format
for FILE in *.fastq
do
./MosaikBuild -q $FILE -out $FILE.dat -st illumina
done
for FILE in *.fastq.dat
do
#Pairwise align reads to UTE_tags reference file
./MosaikAligner -in $FILE -out $FILE.align -ia UTE_tags.dat -hs 10 -minp 0.3 -mmp 0.2 -mhp 100 -act 11 -mmal  -p 16 > $FILE.UTE_tags.txt
#Prepare alignment files for MSA
./MosaikSort -in $FILE.align -out $FILE.sorted -nu
#Produce MSA files(.ace) files
./MosaikAssembler -in $FILE.sorted -ia UTE_tags.dat -out $FILE.UTE_tags.assembled
#Create directory with name of sequence file
mkdir ~/mosaik/assembled_$FILE.UTE_tags
for file in *.ace
do
#Move all assembled .ace files to sequence directory
mv $file ~/mosaik/assembled_$FILE.UTE_tags
#Copy all scripts to parse alignment data into sequence file directory
cp one_hash_ace_parser.pl ~/mosaik/assembled_$FILE.UTE_tags
cp UTE_tags.fasta ~/mosaik/assembled_$FILE.UTE_tags
cp parsed_file_splitter_bash.sh ~/mosaik/assembled_$FILE.UTE_tags
cp split_parsed_file_adjuster.sh ~/mosaik/assembled_$FILE.UTE_tags
cp file_concatenator.sh ~/mosaik/assembled_$FILE.UTE_tags
done
rm $FILE
done
for i in /home/kvdistor/mosaik/assembled_*;
#Go into each sequence directory and invoke scripts to parse Ace Files. Move Alignment file to ~/mosaik/bin path.
do (cd "$i" && perl one_hash_ace_parser.pl && sh parsed_file_splitter_bash.sh && sh split_parsed_file_adjuster.sh && sh file_concatenator.sh);
for FILE in *.ace;
do
rm $FILE
done
done
#Remove all unneccesary Mosaik Files and text
for FILE in *.sorted
do
rm $FILE
done
for FILE in *.align
do
rm $FILE
done
for FILE in *.dat.UTE_tags.txt
do
rm $FILE
done
# for FILE in *.txt
# do
# mv $FILE ~/dnasim/
# done
