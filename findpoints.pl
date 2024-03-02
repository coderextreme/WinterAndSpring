#!/usr/bin/perl
use strict;
use warnings;

# parameters
#
# STDIN, a file with Coordinate points
# STDOUT, a stream of points with a header and comments every several lines
#
# Trailer, but no header

my $buffer = "";

# read standard input into a huge buffer
while(<STDIN>) {
	$buffer .= $_;
}

$buffer =~ /[^e]Coordinate[ \r\t\n]*{[ \r\t\n]*point \[(( |\n|\r|[^\]])*)\]/;  # grab points between [ ] across multiple lines
my $point = $1;
$point =~ s/^[ \t\n\r]*//;
$point =~ s/^[ \t]*(.*)\r$/$1\n/g;  # skip leading spaces then remove comment
$point =~ s/[ ,\t\r\n][ ,\t\r\n]*/\t/g;
my @axes = split(/[\t][\t]*/, $point);
my $length = @axes;
for (my $axis = 0; $axis < $length; $axis += 3) { 
	print "$axes[$axis] $axes[$axis+1] $axes[$axis+2]";
	if ($axis % 60 == 0) {
		print " # point count ".($axis / 3);
	}
	print "\n";
}
