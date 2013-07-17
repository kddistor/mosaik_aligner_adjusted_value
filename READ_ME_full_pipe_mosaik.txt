#####################################
#  READ-ME                      	#
#	FULL MOSAIK PIPELINE         	#
#	FOR ADJUSTED ALIGNER VALUE		#
#								   	#
#	by Kevin Distor   				#
#	University of California, Davis	#
#	Department of Plant Sciences	#
#####################################
ver1

###############################
#	OVERVIEW OF PIPELINE      #
###############################

1)MosaikBuild converts input sequence to be aligned into Mosaik’s native read format(.dat).
2)MosaikAligner pairwise aligns each read to a specified series of reference sequences(.align).
3)MosaikSort resolves paired-end reads and sorts the alignments by the reference sequence coordinates(.sort).
4)Finally, MosaikAssembler parses the sorted alignment archive and produces a multiple sequence alignment
	which is then saved into an assembly file format(.ace).
5)The assembly file format is then run through a perl script one_hash_ace_parser.pl which takes in a reference 
	Transposable Element(TE) file(in fasta format)and counts once if a TE appears in an ace file to show the number 
	of times a TE uniquely maps to a SimSeqRead. It produces a grid with the reads that the script obtained from 
	the ace files in the first column and the TEs that that script obtained from the TE reference file in the first row. 
	Reads that aligned to a TE will have a 1 marked in the crossposition. The output is labled "parsed_ace_final.csv" by 
	default.
6)The generated csv file is then split into eight files. Each file will have TE names at the top and eight of the 
	"parsed_ace_final.csv" file's read values. The ouput of this part is labled "$FILE.1st.out" to "$FILE.8th.out" where
	$FILE is the name of the original input sequence at the beginning of the pipeline.
7)The split files are then run through an R script in the form of a shell script called "split_parsed_file_adjuster.sh"
	which takes alignment values and adjusts it based on how many reads were aligned. For example, if a read had a total 
	3 alignments to transposable elements/repeats, all alignment values for that read would be adjusted to 1/3.The defualt 
	output for this step is "$dir/$i.UTE_tags.final" where $dir is the name of the output file from step 6 and $i is the 
	split file number.
8)The final step of this pipeline involves combining all 8 adjusted files and adding the TE counts. This is done with R script
	in the form of a shell script called "file_concatenator.sh". Once the TE counts are added, the final output is one line
	of TEs and their adjusted counts. The default output for this part of the pipeline is labled "$dir.adujsted_alignmentscore.txt"
	where $dir is the name of the orginal input sequence.
	
################################
#	DEPENDENCIES/ASSUMPTIONS   #
################################

Programs:
MOSAIK 1.0 (mosaik-aligner)		Download link: http://code.google.com/p/mosaik-aligner/
R/GNU S ver 2.13.0 or higher	Download link: http://www.r-project.org/

In ~/mosaik/bin
	-full_pipe_mosaik.sh (Script to invoke pipeline)
	-one_hash_ace_parser.pl
	-parsed_file_splitter_bash.sh
	-split_parsed_file_adjuster.sh
	-file_concatenator.sh
	-sequences to be alinged (FASTQ) format
	-reference in FASTA format (example: UTE_tags.fasta)
	-built reference sequences(example: UTE_tags.fasta) to align to
		To build reference sequence run ./MosaikBuild -fr UTE_tags.fasta  -oa UTE_tags.dat 
	
Usage:

	sh full_pipe_mosaik.sh
	
	If submitting as job to FARM:
		qsub full_pipe_mosaik.sh
		
#####################################
#	MODIFICATIONS					#
#####################################
-Can modify reference used
	-build reference fasta by running ./MosaikBuild -fr $input.fasta  -oa $input.dat
	-change "UTE_tags" to "$input" in scripts:
		1)full_pipe_mosaik.sh
		2)one_hash_ace_parser.pl
		3)split_file_splitter_bash.pl
		4)file_concatenator.sh
		
	
#####################################
#	DETAILED OVERVIEW OF PIPELINE	#
#####################################

INVOKE MASTER SCRIPT

usage: sh full_pipe_mosaik.sh

#	For every FASTQ file in the folder run the MOSAIK to assembly	#

for FILE in *.fastq
do
./MosaikBuild -q $FILE -out $FILE.dat -st illumina
done
for FILE in *.fastq.dat
do
./MosaikAligner -in $FILE -out $FILE.align -ia UTE_tags.dat -hs 10 -minp 0.3 -mmp 0.2 -mhp 100 -act 11 -mmal  -p 16 > $FILE.UTE_tags.txt
./MosaikSort -in $FILE.align -out $FILE.sorted -nu
./MosaikAssembler -in $FILE.sorted -ia UTE_tags.dat -out $FILE.UTE_tags.assembled

##	MosaikBuild						##

usage: ./MosaikBuild -q $FILE -out $FILE.dat -st illumina

	From MOSAIK documentation:
	"To speed up the assembly pipeline, compressed binary file formats are used extensively throughout MOSAIK.
	MosaikBuild translates external read formats to a format that the aligner can readily use. In addition to
	processing reads, the program also converts reference sequences from a FASTA file to an efficient binary format."

fastq converted to .dat 

##	MosaikAligner					##

usage: ./MosaikAligner -in $FILE -out $FILE.align -ia UTE_tags.dat -hs 10 -minp 0.3 -mmp 0.2 -mhp 100 -act 11 -mmal  -p 16 > $FILE.UTE_tags.txt

	From MOSAIK documentation:
	"MosaikAligner performs pairwise alignment between every read in the read archive and a set of reference sequences.
	The program uses a hashing scheme similar to BLAT and BLAST and places all of the hashes (k-words or seeds) into a
	hash map or into a “jump database”.
	When presented with a new read, MosaikAligner hashes up the read in a similar fashion and retrieves the reference
	positions for each hash in the hash table. These hash positions are clustered together and then evaluated with a
	full Smith-Waterman algorithm. Alignments are then screened according to the filter criteria specified by the user."
	
	Rationale for using parameters:
		Determined by Gutierrez Lopez, Jose to effectively and accurately capture TE content in maize lines.

.dat is converted to .align

##	MosaikSort						##

usage: ./MosaikSort -in $FILE.align -out $FILE.sorted -nu

	From MOSAIK documentation:
	"MosaikSort takes the alignment output and prepares it for multiple sequence alignment. For single-ended reads, 
	MosaikSort simply resorts the reads in the order they occur on each reference sequence. For mate-pair/paired-end reads, 
	MOSAIK resolves the reads according to user-specified criteria before resorting the reads in the order they occur on each 
	reference sequence."

.align converted to .sort

##	MosaikAssemble					##

usage: ./MosaikAssembler -in $FILE.sorted -ia UTE_tags.dat -out $FILE.UTE_tags.assembled

	From MOSAIK documentation:
	"MosaikAssembler takes the sorted alignment file and produces a multiple sequence alignment which is saved in an assembly file format.
	At the moment, MosaikAssembler saves the assembly in the phrap ace format and the GigaBayes gig format. By default MosaikAssembler will
	assemble each reference sequence where reads aligned. Since the sorted alignment archives incorporate an index, a specific reference 
	sequence can be assembled quickly with the region of interest (-roi) parameter."
	
.sort converted to .ace

#	Make directory with name of sequence used as $file	#
mkdir ~/mosaik/assembled_$FILE.UTE_tags

#	Move assembled ace files to sequence directory		#
for file in *.ace
do
mv $file ~/mosaik/assembled_$FILE.UTE_tags

#	Copy all scripts to parse alignment data into sequence directory	#
cp one_hash_ace_parser.pl ~/mosaik/assembled_$FILE.UTE_tags
cp UTE_tags.fasta ~/mosaik/assembled_$FILE.UTE_tags
cp parsed_file_splitter.sh ~/mosaik/assembled_$FILE.UTE_tags
cp R_bash_here_file.sh ~/mosaik/assembled_$FILE.UTE_tags
mv $file ~/mosaik/assembled_$FILE.UTE_tags

#	For every folder created invoke the copied scripts	#
for i in /home/kvdistor/mosaik/assembled_*;
do (cd "$i" && perl one_hash_ace_parser.pl && sh parsed_file_splitter_bash.sh && sh split_parsed_file_adjuster.sh && sh file_concatenator.sh);
done
	
##	one_hash_ace_parser.pl			##

usage: perl one_hash_ace_parser.pl

Script Algorithm/Processes: 
	1. Open all files/directories.
	2. Open TE Reference File (Fasta Format)
	3. While TE Reference File is open, create an array of all the TE's in the file matching the regular 
		expression in script.
	4. For each ace file in the working directory:
		a. Grab the TE name from the file name.
		b. If the file contains a read (denoted by lines starting with AF)create a hash
			with the read as the key and NULL as the key value.
			1. If file name is in the TE array(3.) store the position it was found.
			2. Use this position to change the corresponding read hash index value to 1 
				indicating that this  ead was found in that TE file.
	5. Loop to print the output.
		a. TE names in the first row. Reads in the first column. Crosspositions denoted with a "1" means
			the read hits to the corresponding TE.

Test Files/Output:
File #1:
RIMMA0385.1.fastq.assembled_chr00.1.REG.ace
	AF HWI-ST611_0210:8:1101:13479:31930#0/1 U 1
	AF HWI-ST611_0210:8:1101:12260:76451#0/1 U 1
	AF HWI-ST611_0210:8:1101:3923:100244#0/1 U 1
	AF HWI-ST611_0210:8:1101:13271:104295#0/1 C 1
	AF HWI-ST611_0210:8:1101:13319:137605#0/1 U 1
	AF HWI-ST611_0210:8:1101:14158:138911#0/1 U 1

File #2:
skimseq_fullTERef.txt
	>DHH_Hip1_1.1
	AACCCCCAATTTTGT
	>DHH_Hip1_1.2
	CCCCCATTTTTGTCG
	>chr00.1.REG
	GGCCACACAACCCCCATTTTTGTCG
	>KNOB180_15-T3-1
	GGCCACAACCCCCAATTTTGT
	>KNOB180_15-T3-2
	AGCCATGAACGACCATTTCCAATA
	>KNOB180_15-T7-1
	GACCATTTCCAATAGACCATTTCCAATA
	
File #1 and File #2 in the same working directory as the script
	
Run script:
perl one_hash_ace_parser.pl
	
Output => parsed_ace_final.csv:
Read, DHH_Hip1_1.1, DHH_Hip1_1.2, chr00.1.REG, KNOB180_15-T3-1, KNOB180_15-T3-2, KNOB180_15-T7-1
HWI-ST611_0210:8:1101:13479:31930,,,,1,,,
HWI-ST611_0210:8:1101:12260:76451,,,,1,,,
HWI-ST611_0210:8:1101:3923:100244,,,,1,,,
HWI-ST611_0210:8:1101:13271:104295,,,,1,,,	
HWI-ST611_0210:8:1101:13319:137605,,,,1,,,
HWI-ST611_0210:8:1101:14158:138911,,,,1,,,


.ace converted to parsed_ace_final.csv

##	parsed_file_splitte_bash.sh			##
	
usage: sh parsed_file_splitter_bash.sh

	Splits parsed ace files into eight files. Each file will have TE names at the top and eight of the 
	"parsed_ace_final.csv" file's read values. The ouput of this part is labled "$FILE.1st.out" to "$FILE.8th.out" where
	$FILE is the name of the original input sequence at the beginning of the pipeline.
	
parsed_ace_final.csv converted into	$dir.1st.out	
									$dir.2nd.out
									$dir.3rd.out
									$dir.4th.out
									$dir.5th.out
									$dir.6th.out
									$dir.7th.out
									$dir.8th.out where $dir is the name of the directory
									
##	split_parsed_file_adjuster.sh			##

usage: sh split_parsed_file_adjuster.sh

	Takes alignment values and adjusts it based on how many reads were aligned. For example, if a read had a total 
	3 alignments to transposable elements/repeats, all alignment values for that read would be adjusted to 1/3. The defualt 
	output for this step is "$dir/$i.UTE_tags.final" where $dir is the name of the output file from step 6 and $i is the 
	split file number.

$dir.1st.out ... $dir.8th.out converted to $dir.1st.out.UTE_tags.final	...	$dir.8th.out.UTE_tags.final

##	file_concatenator.sh			##

usage: sh file_concatenator.sh

	Combines all 8 adjusted files and adds the TE counts. Once the TE counts are added, the final output is one line
	of TEs and their adjusted counts. The default output for this part of the pipeline is labled "$dir.adujsted_alignmentscore.txt"
	where $dir is the name of the orginal input sequence.
	
$dir.1st.out.UTE_tags.final	...	$dir.8th.out.UTE_tags.final converted to $dir.adujsted_alignmentscore.txt

#Move adjusted files from directory to ~/mosaik/bin folder
tail -1 final.csv > $dir.adujsted_alignmentscore.txt
cp $dir.adujsted_alignmentscore.txt ~/mosaik/bin

#	Remove all unneccesary/used Mosaik files		#
for FILE in *.sorted
do
rm $FILE
done
for FILE in *.align
do
rm $FILE
done
