#!/bin/perl
use strict;
use warnings;

# takes VRML skeleton and produces comparable weights files to input
# perl SkeletonParseLineValidate.pl "${REVERSE}" "${SKELETONWEIGHTSDIR}" "$MAPPINGFILE"
# perl SkeletonParseLineValidate.pl "${FINAL}" "${SKELETONWEIGHTSDIR}" "$MAPPINGFILE"
#
# export MAPPINGFILE="${PROCESSDIR}"/mapping.txt  # joint listing table
# export SKELETONWEIGHTSDIR="${OUTPUTDIR}"/SkeletonOut/  # folder for skeleton weights
#
# export REVERSE="${OUTPUTDIR}/ToddlerFinal.x3dv"
#export FINAL="${OUTPUTDIR}/${CHARACTER}Final.x3dv"  # final output
#export FINAL="${OUTPUTDIR}/${CHARACTER}Final.x3dv"  # final output
#export FINAL="${OUTPUTDIR}/${CHARACTER}Final.x3dv"  # final output
#

# parameters
#
# ARGV[0] OutputDir/${CHARACTER}/Final.x3dv
# ARGV[1] OutputDir/SkeletonOut/<joint>_weights.txt
# ARGV[2] ProcessDir/mapping.text

my $joint = "WRONG JOINT";
my %files = ();
open(MAPPING, "<$ARGV[2]") or die "Failure opening $ARGV[2] for reading\n";
while (<MAPPING>) {
	chomp;
	if (/<(.*)>/) {
		$joint = $1;
		open my $fh, ">", "$ARGV[1]/$joint"."_weights.txt"
				or warn "Failure opening $ARGV[1]/$joint"."_weights.txt\n";
		print $fh "[$ENV{GENERATION}_2T::Weight]\r\n\r\n";
		print $fh "<$joint>\r\n\r\n";
		$files{$joint} = $fh;
	} else {
		print STDERR "Didn't create $_"."_weights.txt\n";
	}
}
close(MAPPING);

$joint = "WRONG JOINT";

open(MAPPING, "<$ARGV[2]") or die "Couldn't open mapping file";

my %map = ();
while(<MAPPING>) {
	chomp;
	if (/<(.*)\/(.*)>/) {
		$map{$2} = $1;
		print "Initialize map $2 to $1\n";
	} elsif (/<(.*)>/) {
		$map{$1} = $1;
		# print "Initialize map $1 to $1\n";
	}
}

close(MAPPING);

open (JOINTS, "<$ARGV[0]") or die "Couldn't open joints file $ARGV[0]";
$joint = "WRONG JOINT";
while (<JOINTS>) {
	chomp;
	my $line = $_;
	if (/^(.*)DEF ([^ ]*) HAnimJoint (.*) skinCoordIndex (0|\[([^\]]*)\]) skinCoordWeight (0|\[([^\]]*)\])/) {
		# print "Match $1\n";
		my $header = $1;
		my $defjoint = $2;
		my $fields = $3;
		my $sci = $4;
		my $indexes = $5;
		my $scw = $6;
		my $weights = $7;

		$indexes =~ s/^ *(.*) */$1/;
		#print $indexes."\n";
		$weights =~ s/^ *(.*) */$1/;
		#print $weights."\n";
		$defjoint =~ s/^([^_]*_)(.*)//;
		my $def = $1;
		$joint = $2;
		# print STDERR "Searching for Joint $joint in mapping table at $map{$joint}\n";
		if (defined $map{$joint}) {
			print "Match! $joint\n";
			my @weights =  split(/ +/, $weights);
			my @indexes = split(/ +/, $indexes);
			my $indexeslen = @indexes;
			my $weightslen = @weights;
			if ($indexeslen != $weightslen) {
				print STDERR "Lengths for joint $joint index $indexeslen != $weightslen\n";
			} else {
				# print STDERR "Lengths for joint $joint index $indexeslen == $weightslen\n";
			}
			for (my $i = 0, my $w = 0; $i < $indexeslen && $w < $weightslen; $i++, $w++) {
				my $fh = $files{$joint};
				print $fh "($indexes[$i]) = $weights[$w]\r\n";
			}
		} else {
			print STDERR "No match for Joint $joint in weights table! (no weights?)\n";
		}
	} else {
		# print STDERR "No match HAnimJoint\n";
	}
}

close(JOINTS);

open(MAPPING, "<$ARGV[2]") or die "Failure opening $ARGV[2] for reading\n";
while (<MAPPING>) {
	chomp;
	if (/<(.*)>/) {
		$joint = $1;
		close $files{$joint} or warn "Failure closing $joint"."_weights.txt\n";
	} else {
		print STDERR "Didn't create $_"."_weights.txt\n";
	}
}
close(MAPPING);
