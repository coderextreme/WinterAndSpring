#!/usr/bin/perl
use strict;
use warnings;

# tAke as input a VRML skeleton with a name for each Transform and producd a skeleton with Joints instead

# parameters
#
# STDIN -- input VRML skeleton
# STDOUT -- output VRML skeleton with Joints
#
#
# TODO, look up joints in mapping.txt. Only accept names in that mapping

while(<STDIN>) {
	my $line = $_;
	$line =~ s/^(.*)Transform(.*)name[ \t]*(["'])([^\"\']*)(['"])/$1HAnimJoint$2name $3$4$5/;
	print STDOUT $line;
}
