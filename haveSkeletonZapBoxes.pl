#!/usr/bin/perl
use strict;
use warnings;

# parameters
#
# STDIN -- X3DV file with box translations
# STDOUT -- X3DV file without box translations
#
#

while(<STDIN>) {
	my $line = $_;
	if ($line =~ /^(DEF.*)(translation.*)(children.*)$/) {
		my $header = $1;
		my $translation = $2;
		my $trailer = $3;
		$line = "";
	}
	print $line;
}
