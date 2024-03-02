#!/usr/bin/perl
use strict;
use warnings;

use Math::Trig;

# tAke as input a VRML skeleton with DEF/USE and name for Joints and produce a skeleton with blank centers replaced by 0 0 0

# parameters
#
# STDIN -- X3DV file with centers
# STDOUT -- X3DV file without centers
#
#

while(<STDIN>) {
	my $line = $_;
	$line =~ s/center[ \t]+[-+0-9.e]+[ \t]+[-+0-9.e]+[ \t]+[-+0-9.e]+//g;
	print $line;
}
