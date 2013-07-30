#!/usr/bin/perl


#####################################
#	One Hash Mosaik Ace File Parser	#
#	by Kevin Distor					#
#	University of California, Davis	#
#############################################################################################################################
#STEP 2 - Align TE from alignment file to reference TE file.																#
#																															#
#	The assembly file format is then run through a perl script one_hash_ace_parser.pl which takes in a reference 			#
#	Transposable Element(TE) file(in fasta format)and counts once if a TE appears in an ace file to show the number 		#
#	of times a TE uniquely maps to a SimSeqRead. It produces a grid with the reads that the script obtained from 			#
#	the ace files in the first column and the TEs that that script obtained from the TE reference file in the first row.	# 
#	Reads that aligned to a TE will have a 1 marked in the crossposition. The output is labeled "parsed_ace_final.csv" by 	#
#	default.																												#
#																															#
#############################################################################################################################

#Declare all global variables
my ($teCount, $myTE, $file, $i, $hash);
my (@teArray, @array, @files);
my (%hash);

#Grab all files ending with ace in the current directory
@files = glob("*.ace");
open(FINAL, '>parsed_ace_final.csv');

#Grab all TEs from reference and store to an array
open(FASTA, '<UTE_tags.fasta');
while (<FASTA>) {
	chomp;
	if ($_ =~ m/\>(\S+)/) {
		chomp;
		push (@teArray, "$1,");
		$teCount++;
	}
}

foreach $file (@files) {
	open(FILE, $file);
	while (<FILE>) {
		#Get the TEs from sequence file to be matched against the reference TE array. 
		#Examples precede the code. This part grabs what is denoted by the bracket.
		#RIMMA0385.1.fastq.dat.UTE_tags.assembled_[RST_ZmSINE3_consensus-0.1].ace
		$file =~ s/\D{5}\d{4}\.\d{1}\.\D{5}\.\D{3}\.\D{3}\_\D{4}\.\D{9}\_//g;
		#RIMMA0030.13.fastq.dat.UTE_tags.assembled_[RST_ZmSINE2_consensus-0.1].ace
		$file =~ s/\D{5}\d{4}\.\d{2}\.\D{5}\.\D{3}\.\D{3}\_\D{4}\.\D{9}\_//g;
		#if file is RITD0001.2.fastq.dat.UTE_tags.assembled_[RLX_osed_AC191084-2931.1].ace 
		$file =~ s/\D{4}\d{4}\.\d{1}\.\D{5}\.\D{3}\.\D{3}\_\D{4}\.\D{9}\_//g;
		#if file is RITD0001.01.fastq.dat.UTE_tags.assembled_[DTA_ZM00346_consensus.1].ace
		$file =~ s/\D{4}\d{4}\.\d{2}\.\D{5}\.\D{3}\.\D{3}\_\D{4}\.\D{9}\_//g;
		$file =~ s/\.ace/,/;
		print "$file\n";
		chomp;
		#Get read names from each sequnce file and if there is a match of TEs from sequence file to that of reference TE array. 
		#Denote a 1 if there is a match, else put NULL.
		if ($_=~ m/^AF\s(\D+\-\D+\d+\_\d+\:\d\:\d+\:\d+\:\d+)/) {
			#The read matching statement for this part is for UTE_tags reference.
			#The format of reads for UTE_tags reference is: AF HWI-ST611_0210:8:1101:7570:2203#0/1 U 2982
			#If using a different reference than UTE_tags, modify previous line of code.
				my ($key)=$1;
				my($index)= grep { $teArray[$_] eq "$file" } 0..$teCount;
				$hash{$key}[$index] = 1;
			}
	}
}

#Print the output. Default output is parsed_ace_final.csv. Change line 18 to change ouput name. Only output names
#ending with .csv will be used for the rest of the pipeline.
print FINAL "SimSeqReadName, @teArray\n";
foreach (sort keys %hash) {
	print FINAL "$_,";
	for ($i=0; $i < $teCount; $i++) {
	print FINAL "$hash{$_}[$i],"; 
	}
	if ($i = $teCount) {
		print FINAL "\n";
	}
}
