#!/bin/perl
use strict;
use warnings;

# parameters
#  STDIN -- VRML skeleton
#  STDOUT -- VRML skeleton with skinCoord fields


while (<STDIN>) {
	my $line = $_;
	if ($line =~ /(.*)HAnimJoint(.*)(children|#)(.*)\r?$/) {
		my $header = $1;
		my $fields = $2;
		my $eofields = $3;
		my $rest = $4;
		$line = "${header}HAnimJoint${fields} skinCoordIndex [  ] skinCoordWeight [  ] $eofields$rest\n";
	} elsif ($line =~ /HAnimJoint/) {
		print STDERR "Couldn't parse line $line in SkeletonParse.pl\n"
	}
	print $line;
}
