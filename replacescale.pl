#!/usr/bin/perl
use strict;
use warnings;
#
# parameters
#
# Quick script to replace scale (everywhere for now)

# STDIN -- old skeleton
# STDOUT -- new skeleton

while(<STDIN>) {
	my $line = $_;
	$line =~ s/scale[ \t]+([-0-9+e\.]+)[ \t]+([-0-9+e\.]+)[ \t]+([-0-9+e\.]+)/scale 0.5 0.5 0.5/;
	print $line;
}
