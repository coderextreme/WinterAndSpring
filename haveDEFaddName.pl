#!/usr/bin/perl
use strict;
use warnings;

# tAke as input a VRML skeleton with a DEF for each HAnim node and producd a skeleton with names

# WARNING the name taken from DEF follows the first _.  Since HAnim nodes have underscores, anything before HAnim name in DEF must not have underscores.
#
# parameters
#
# STDIN -- input VRML skeleton
# STDOUT -- output VRML skeleton with names added
#
# TODO, look up DEFs in mapping.txt, reject HAnim Joints (not sites or segments yet) that don't fit list

while(<STDIN>) {
	my $line = $_;
	$line =~ s/(.*)DEF ([^_]*)_(.*) HAnim(Joint|Segment|Site)([ \t\{][ \t\{]*)(.*)/$1DEF $2_$3 HAnim$4 $5 name "$3" $6/;
	print STDOUT $line;
}
