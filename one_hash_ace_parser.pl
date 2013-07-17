#!/usr/bin/perl
#One hash Mosaik ace file parser
#by Kevin Distor

my ($teCount, $myTE, $file, $i, $hash);
my (@teArray, @array, @files);
my (%hash);

#grab all files ending with ace in the current directory
@files = glob("*.ace");
open(FINAL, '>parsed_ace_final.csv');

#grab all reads and store to an array
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
		#if file is RITD0001.2.fastq.dat.UTE_tags.assembled_[RLX_osed_AC191084-2931.1] grab what's in brackets
		$file =~ s/\D{4}\d{4}\.\d{1}\.\D{5}\.\D{3}\.\D{3}\_\D{4}\.\D{9}\_//g;
		$file =~ s/\D{4}\d{4}\.\d{2}\.\D{5}\.\D{3}\.\D{3}\_\D{4}\.\D{9}\_//g;
		#if file is RIMMA0001.2.fastq.dat.UTE_tags.assembled_[RLX_osed_AC191084-2931.1] grab what's in brackets
		$file =~ s/\D{5}\d{4}\.\d{1}\.\D{5}\.\D{3}\.\D{3}\_\D{4}\.\D{9}\_//g;
		$file =~ s/\D{5}\d{4}\.\d{2}\.\D{5}\.\D{3}\.\D{3}\_\D{4}\.\D{9}\_//g;
		$file =~ s/\.ace/,/;
		chomp;
		if ($_=~ m/^AF\s(\D+\-\D+\d+\_\d+\:\d\:\d+\:\d+\:\d+)/) {
			#AF HWI-ST611_0210:8:1101:7570:2203#0/1 U 2982
				my ($key)=$1;
				my($index)= grep { $teArray[$_] eq "$file" } 0..$teCount;
				$hash{$key}[$index] = 1;
			}
	}
}

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
