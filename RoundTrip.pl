
#!/bin/perl
use strict;
use warnings;

# read mapping.text, produce weights files with each joint in a separate file

#ProcessLeif5.sh:perl RoundTrip.pl "$WEIGHTSOUT" "${ROUNDTRIPWEIGHTSDIR}" "$MAPPINGFILE"
#ProcessLilyrv4.sh:perl RoundTrip.pl "$WEIGHTSOUT" "${ROUNDTRIPWEIGHTSDIR}" "$MAPPINGFILE"
#ProcessToddlerR5.sh:perl RoundTrip.pl "$WEIGHTSOUT ${ROUNDTRIPWEIGHTSDIR} $MAPPINGFILE"
#
# $ARGV[0] -- ProcessDir/WeightsOut.txt
# $ARGV[1] -- OutputDir/WeightsOut/
# $ARGV[2] -- ProcesDir/mapping.txt

my $joint = "WRONG JOINT";
my %files = ();
open(MAPPING, "<$ARGV[2]") or die "Failure opening $ARGV[2] for reading\n";
while (<MAPPING>) {
	chomp;
	if (/<(.*)>/) {
		$joint = $1;
		my $fh;
		open $fh, ">", "$ARGV[1]/$joint"."_weights.txt" or die "Failure opening $ARGV[1]/$joint"."_weights.txt\n";
		print $fh "[$ENV{GENERATION}_2T::Weight]\r\n\r\n";
		print $fh "<$joint>\r\n\r\n";
		$files{$joint} = $fh;
	} else {
		print STDERR "Didn't create $_"."_weights.txt\n";
	}
}
close(MAPPING);


open (WEIGHTS, "<$ARGV[0]") or die "Couldn't open weights file $ARGV[0]";
my $index = "NO INDEX";
my $sum = "NO SUM";
my $weights = "NO WEIGHTS";
my @weights = ();
my $joints = "NO JOINTS";
my @joints = split(/:/, $joints);
while (<WEIGHTS>) {
	my $weightline = $_;
	chomp;
	#Joints for index 20887 sum:  1:skullbase
	if (/^Joints for index ([0-9][0-9]*) sum:  ([0-9\.][0-9\.]*):([a-z_:0-9]*)\r*$/) {
		$index = $1;
		$sum = $2;
		$joints = $3;
		@joints = split(/:/, $joints);
		my $jointslen = @joints;
		my $weightslen = @weights;
		if ($jointslen != $weightslen) {
			print STDERR "Joints $joints different length $jointslen than weights $weights length $weightslen\n";
		} else {
			# print STDERR "Matched $weightline same length $jointslen as length $weightslen\n";
			for (my $w = 0; $w < $weightslen; $w++) {
				$joint = $joints[$w];
				my $fh = $files{$joint};
				print $fh "($index) = $weights[$w]\r\n" or warn "Failed to write: $joint -> ($index) = $weights[$w]\r\n";
			}
		}
	} elsif (/appear/) {
		# print STDERR "Matched appear|$weightline";
	# Index 0 sum:  1=0+1
	# Index 2296 sum:  1=0+0.012+0.988
	# Index 20886 sum:  1=0+0.999+0.001
	} elsif (/^Index ([0-9][0-9]*) sum:  ([0-9\.][0-9\.]*)=0\+(.*)\r*$/) {
		# print STDERR "Matched $weightline";
		$index = $1;
		$sum = $2;
		$weights = $3;
		@weights = split(/\+/, $weights);
	} elsif (/^$/){
		# don't show blank lines
	} else {
		print STDERR "Didn't match $weightline";
	}

}

close(WEIGHTS);

open(MAPPING, "<$ARGV[2]") or die "Failure opening $ARGV[2] for reading\n";
while (<MAPPING>) {
	chomp;
	if (/<(.*)>/) {
		$joint = $1;
		my $fh = $files{$joint};
		close $fh or warn "Failure closing $joint"."_weights.txt\n";
	} else {
		print STDERR "Didn't create $_"."_weights.txt\n";
	}
}
close(MAPPING);
