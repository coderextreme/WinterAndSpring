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
# $ARGV[0] -- Weights InputDir/*weights.txt
# STDIN -- A skeleton
# STDOUT -- skeleton with weights

my $joint = "WRONG JOINT";

if (@ARGV == 0) {
	die "Couldn't open weights file Weights <InputDir>/*weights.txt";
}

open (WEIGHTS, "<$ARGV[0]") or die "Couldn't open weights file Weights $ARGV[0]";

my %joints = ();
$joint = "WRONG JOINT";
while (<WEIGHTS>) {
	if (/<(.*)>/) {
		$joint = $1;
		# print STDERR "Joint $joint\n";
		$joints{$joint} = {};
	}
}
close(WEIGHTS);

$joint = "WRONG JOINT";
my $line = "";
my $lines = "";
my $last = 0;
while (<STDIN>) {
	my $line = $_;
	if ($line =~ /^#/) {
		# don't merge lines with leading comments
		print $line;
		next;
	}
	$line =~ s/[\r\n][\r\n]*/ /g;
	$lines .= $line;
	if ($lines =~ /^(.*)DEF ([^_][^ ]*) HAnimJoint(.*)name[ \t]*["']([^\"\']*)['"](.*)[ \t]*center[ \t]*([-0-9.e][-0-9.e]*[ \t]*[-0-9.e][-0-9.e]*[ \t]*[-0-9.e][-0-9.e]*)(.*)children[ \r\n\t]*\[((.|\n)*)$/) {
		# print STDERR "SUCCESS".$lines."\n";
		# pass through
		$last = 0;
	} else {
		# print STDERR "FAILURE".$line."\n";
		$last = 1;
		next;
	}
	if ($lines =~ /^(.*)([ \t\r\n]*)DEF ([^_][^ ]*) HAnimJoint(.*)name[ \t]*["']([^\"\']*)['"](.*)[ \t]*center[ \t]*([-0-9.e][-0-9.e]*[ \t]*[-0-9.e][-0-9.e]*[ \t]*[-0-9.e][-0-9.e]*)(.*)children[ \r\n\t]*\[((.|\n)*)$/) {
		# print STDERR "FOUND ".$lines."\n";
		my $header = $1;
		my $spaces = $2;
		my $defjoint = $3;
		my $leadingfields = $4;
		my $name = $5;
		my $fields = $6;
		my $center = $7;
		my $trailer = $8;
		my $trailer2 = $9;
		$defjoint =~ m/^([^_]*_)(.*)/;
		my $def = $1;
		$joint = $2;
		if ($joint ne $name) {
			print STDERR "DEF $defjoint does not match $name\n";
		}
		my $jointobj = $joints{$joint};
		if (defined($jointobj)) {  # assume we have a good joint
			print STDERR "Found Joint $joint in weights table!\n";
		} else {
			print STDERR "No match for Joint $joint in weights table! (no weights?)\n";
		}
		$lines = $header.$spaces."DEF ".$def.$joint." HAnimJoint$leadingfields"."name \"$name\" $fields center $center $trailer"."children [\r\nTransform { translation $center children [ Shape { geometry Box { size 0.01 0.01 0.01 } } ] }\r\n$trailer2\r\n";
		$lines =~ s/DEF/\r\nDEF/g;
		$lines =~ s/ROUTE/\r\nROUTE/g;
		$lines =~ s/ TO ([^RP_])/ TO $ENV{GENERATION}_$1/g;
		print STDOUT $lines;
		$lines = "";
	} else {
		$lines =~ s/DEF/\r\nDEF/g;
		$lines =~ s/ROUTE/\r\nROUTE/g;
		$lines =~ s/ TO ([^RP_])/ TO $ENV{GENERATION}_$1/g;
		print STDERR "Couldn't match $lines in haveSkeletonAddBoxes.pl\n";
		print STDOUT $lines;
		$lines = "";
	}
}
if ($last) {
	$lines =~ s/DEF/\r\nDEF/g;
	$lines =~ s/ROUTE/\r\nROUTE/g;
	$lines =~ s/ TO ([^RP_])/ TO $ENV{GENERATION}_$1/g;
	print STDOUT $lines;
}
