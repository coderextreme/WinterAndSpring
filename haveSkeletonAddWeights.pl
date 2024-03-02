#!/bin/perl
use strict;
use warnings;

# cat  "$JOINTOUTPUT"  | perl haveSkeletonAddWeigths.pl "${WEIGHTS}" | sed -e "s/IMAGE.png/${IMAGE}/" > "${OUTPUT}"
#
# Adds skinCoordIndexes, skinCoordWeights, Boxes in Skeleton
#
#export WEIGHTSFILE='lily_7_2 wieghts.txt'  # joint index and a weight for skinCoord*
#export WEIGHTSFILE="LILY 7_2 wieghts.txt"  # joint index and a weight for skinCoord*
#export WEIGHTSFILE="LILY 7_1 weights.txt"  # joint index and a weight for skinCoord*
#export WEIGHTSFILE="lily_6_1_weights.txt"  # joint index and a weight for skinCoord*
#export WEIGHTSFILE="Lily Rev 5 weights.txt"
#export WEIGHTS="${INPUTDIR}/${WEIGHTSFILE}"
#
# $ARGV[0] -- Weights InputDir/*weights.txt, (Could be STDIN)
# STDIN -- A skeleton
# STDOUT -- skeleton with weights

my $joint = "WRONG JOINT";

open (WEIGHTS, "<$ARGV[0]") or die "Couldn't open weights file $ARGV[0]";

my %joints = ();
my $first = 1;
$joint = "WRONG JOINT";
while (<WEIGHTS>) {
	chomp;
	my $line = $_;
	if ($line =~ /^.*<(.*)>.*\r*$/) {
		$joint = $1;
		$joints{$joint} = {};
		$joints{$joint}->{INDEX} = [];
		$joints{$joint}->{WEIGHT} = [];
		print STDERR "FOUND $joint in weights\r\n";
		# print STDERR "JOINT is |$joint|\n";
	} elsif ($line =~ /^\(([0-9]+)\) = ([0-9\.]+)\r*$/) {
		#print STDERR "($1) = $2\r\n";
		push(@{$joints{$joint}->{INDEX}}, $1);
		push(@{$joints{$joint}->{WEIGHT}}, $2);
	} else {
		print STDERR "DEAD SPACE $line\n";
	}
}
close(WEIGHTS);

my $skinCoordIndex = " ";
my $skinCoordWeight = " ";
$joint = "WRONG JOINT";
while (<STDIN>) {
	my $line = $_;
	if (/^(.*)DEF ([^ ]*) HAnimJoint(.*)name[ \t]*["']([^\"\']*)['"](.*)[ \t]*center[ \t]*([-0-9.e][-0-9.e]*[ \t]*[-0-9.e][-0-9.e]*[ \t]*[-0-9.e][-0-9.e]*)[ \t]*skinCoordIndex[ \t]*(\[[^\]]*\])[ \t]*skinCoordWeight[ \t]*(\[*[^\]]*\])(.*)children[ \t]*\[(.*)\r*$/) {
		my $header = $1;
		my $defjoint = $2;
		my $leadingfields = $3;
		my $name = $4;
		my $fields = $5;
		my $center = $6;
		my $sci = $7;
		my $scw = $8;
		my $trailer = $9;
		my $trailer2 = $10;
		$defjoint =~ m/^([^_]*_)(.*)/;
		my $def = $1;
		$joint = $2;
		if ($joint ne $name) {
			print STDERR "DEF $defjoint does not match $name\n";
		}
		my $jointobj = $joints{$joint};
		if (defined($jointobj)) {
			# print STDERR "Match! $joint\n";
			$skinCoordIndex = join(" ", @{$jointobj->{'INDEX'}});
			$skinCoordWeight = join(" ", @{$jointobj->{'WEIGHT'}});
			print STDOUT "$header"."\nDEF ".$def.$joint." HAnimJoint$leadingfields"."name \"$name\" $fields center $center skinCoordIndex [ ".join(" ", $skinCoordIndex)." ] skinCoordWeight [ ".join(" ", $skinCoordWeight)." ]$trailer"."children [ Transform { translation $center children [ Shape { geometry Box { size 0.01 0.01 0.01 } } ] }\r\n $trailer2";
			print STDERR "Found Joint $joint in weights table!\n";
		} else {
			print STDERR "No match for Joint $joint in weights table! (no weights?)\n";
			print STDOUT $_."\n";
		}
	} elsif (/HAnimJoint/) {
		print STDERR "Couldn't match $line in haveSkeletonAddWeights.pl\n";
		print STDOUT $_;
	} else {
		print STDOUT $_;
	}
}
