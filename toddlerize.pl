#!/usr/bin/perl
use strict;
use warnings;

# Node name cleanups
# STDIN -- original humanoid
# STDOUT -- humanoid with image texture in appearance

my %joints = ();
while(<STDIN>) {
	my $line = $_;
	if ($line =~ /DEF([ \t]+)([^ \t]+)([ \t]+)HAnim(Joint|Segment|Site)/) {
		my $def = $2;
		$joints{$def} = "$ENV{GENERATION}_$def";
	}
	while(my($k, $v) = each %joints) {
		$line =~ s/([ \t])$k([ \t\.\]]|$)/$1$v$2/;
	}
	print $line;
}
