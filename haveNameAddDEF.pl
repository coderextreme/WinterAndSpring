#!/usr/bin/perl
use strict;
use warnings;

# tAke as input a VRML skeleton with a name for each Joint and producd a skeleton with DEFs

# parameters
#
# STDIN -- input VRML skeleton
# $ARGV[0] -- Prefix to add to DEF in front of name
# STDOUT -- output VRML skeleton with DEFs
#

my $prefix = $ARGV[0];
while(<STDIN>) {
	my $line = $_;
	$line =~ s/^(.*)HAnim(Joint|Segment|Site)(.*)name[ \t]*(["'])([^\"\']*)(['"])/$1 DEF $ARGV[0]_$5 HAnim$2$3name $4$5$6/;
	print STDOUT $line;
}
