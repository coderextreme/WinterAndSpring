#!/bin/perl
use strict;
use warnings;
use Scalar::Util qw/looks_like_number/;

# provide statistics on Weights file
# SubProcess.sh:perl WeightsProcess.pl "${WEIGHTS}" > "$WEIGHTSOUT"
#
#export WEIGHTSFILE='lily_7_2 wieghts.txt'  # joint index and a weight for skinCoord*
#export WEIGHTSFILE="LILY 7_2 wieghts.txt"  # joint index and a weight for skinCoord*
#export WEIGHTSFILE="LILY 7_1 weights.txt"  # joint index and a weight for skinCoord*
#export WEIGHTSFILE="lily_6_1_weights.txt"  # joint index and a weight for skinCoord*
#export WEIGHTSFILE="Lily Rev 5 weights.txt"
#export WEIGHTS="${INPUTDIR}/${WEIGHTSFILE}"
#export WEIGHTSOUT="${PROCESSDIR}"/WeightsOut.txt   # summary file of weights
#
# $ARGV[0] -- InputDir/*weights.txt, list of joint weights
# STDOUT -- ProcessDir/WeightsOut.txt Statistics

open (WEIGHTS, "<$ARGV[0]") || die "Couldn't open weights file";



my @sums = ();
$sums[0] = 0;  # initialize the sucker, so we don't get a huge string
my @sumstrs = ();
$sumstrs[0] = 0;  # initialize the sucker, so we don't get a huge string
my @jointsForSum = ();
my $joint = "WRONG JOINT";
while (<WEIGHTS>) {
	chomp;
	if (/^\(([0-9]+)\) = ([0-9\.]+)\r/) {
		# print "|$1|$2|\n";
		if (looks_like_number($1)) {
			my $left = $1;
			if (looks_like_number($2)) {
				my $right = $2; # use it as a number!
				if (! defined $sums[$left]) {
					$sums[$left] = 0;
				}
				if (! defined $sumstrs[$left]) {
					$sumstrs[$left] = "0";
				}
				if (! defined $jointsForSum[$left]) {
					$jointsForSum[$left] = "";
				}
				$sums[$left] += $right;
				$sumstrs[$left] .= "+$right";
				$jointsForSum[$left] .= ":$joint";
			} else {
				print "What's $2?\n";
			}
		} else {
			print "What's $1?\n";
		}
	}
	if (/^<(.*)>\r/) {
		$joint = $1;
	} else {
		# print "What's $_?\n";
	}
}

my $len = @sums;
my %counts = ();
for (my $index = 0; $index < $len; $index++) {
	my $index = $index;
	if (defined $sumstrs[$index] && defined $sums[$index]) {
		print "Index $index sum:  ".$sums[$index]."=".$sumstrs[$index]."\n";
		if (defined $jointsForSum[$index]) {
			print "Joints for index $index sum:  ".$sums[$index].$jointsForSum[$index]."\n";
		} else {
			print "Cannot compute for joints for index $index.\n";
		}
		$counts{$sums[$index]}++;
	}
}
print "\n";
my $weightCount = 0;
print "Sum appearance\n";
foreach my $c (keys %counts) {
	if ($counts{$c}) {
		print "$c appears $counts{$c} times.\n";
	}
	$weightCount += $counts{$c};
}
close(WEIGHTS);
print "total of sum appearance = $weightCount\n";
