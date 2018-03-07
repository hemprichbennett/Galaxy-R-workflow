#!/usr/bin/perl -w#Put this into the directory with your QIIME output that needs to be converted for R, then type  perl MakeQIIMEOTUtable.pl x. (where x is the name of the OTU reps file to be modified
### Freddy Chain Jan27.2015
use strict;
use warnings;

###Open QIIME output file
my $file = shift;
if(!($file)){ die "you must supply 1 file with the QIIME list/table of MOTU components\n";}

#unix:\n mac:\r dos:\r\n
system "tr '\r' '\n' < $file > temp"; #mac to unix
system "tr '\n\n' '\n' < temp > $file.temp"; #dos to unix (after changing \r to \n)
system "rm temp";##remove temp file
#############################################################################################
open(INFILE, "$file.temp") or die "The file $file could not be found.\n";
my %Rep=();### Rep-->Samples-->Count
my %Samples=(); ##Sample-->Count
my $OTUs=0; ##Keeps track of OTU number
my $rep=""; ##First column
while(<INFILE>){
	my $Theline=$_;chomp ($Theline);
	my @Line=split(/\s/,$Theline);##Separates by whitespace
	#	if($Line[0]=~/^(\d+[A-Z\d]+)_\d+/){
		$rep=shift(@Line);#MOTUx
	#	}
	foreach my $hit (@Line){#loops through remaining columns
		if($hit=~/^(F\d+_R\d+)_(\d+)-/){#regex to capture F#_R#
			$Rep{$rep}{$1}+=$2;
			$Samples{$1}++;
		}else{#otherwise look for hyphen, get the previous number as #reads, and everything else as label
			my @dash=split(/-/,$hit);
			my @underscore=split(/_/,$dash[0]);
			my $num=pop(@underscore);
			my $name=join("_",@underscore);
			$Rep{$rep}{$name}+=$num;
			$Samples{$name}++;
		}
	}
	$OTUs++;
}
close INFILE;
print "Found $OTUs OTUs\n";
system "rm $file.temp";
#############################################################################################
#############################################################################################
#my $Thenewfile = ">$file.table.out";
open(OUTFILE, ">$file.table.out") or die "Can't write to Output File 1\n";
open(OUTFILE2, ">$file.table_binary.out") or die "Can't write to Output File 2\n";

print OUTFILE "MOTU";
print OUTFILE2 "MOTU";
for my $s (sort keys %Samples){
	print OUTFILE "\t$s";
	print OUTFILE2 "\t$s";
}
print OUTFILE "\n";
print OUTFILE2 "\n";

for my $x (sort keys %Rep){
	print OUTFILE "$x";
	print OUTFILE2 "$x";
	for my $s (sort keys %Samples){
		if($Rep{$x}{$s}){
			print OUTFILE "\t$Rep{$x}{$s}";
			print OUTFILE2 "\t1";
		}else{
			print OUTFILE "\t0";
			print OUTFILE2 "\t0";
		}
	}
	print OUTFILE "\n";
	print OUTFILE2 "\n";
}
close OUTFILE;
close OUTFILE2;
##################################################################################################################################################
