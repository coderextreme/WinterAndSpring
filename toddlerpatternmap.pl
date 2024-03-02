#!/usr/bin/perl
use strict;
use warnings;

# Node name cleanups
# STDIN -- original humanoid
# STDOUT -- humanoid with image texture in appearance

my %joints = ();
my $prefix = "$ENV{GENERATION}_";
my $humanoid = "";
while(<STDIN>) {
	my $line = $_;
	if ($line =~ /DEF([ \t]+)([^ \t]+)([ \t]+)HAnim(Humanoid|Joint|Segment|Site)/) {
		my $def = $2;
		$joints{$def} = qr/([ \t\$]+)$def([ \t\$\.\n\]]+)/m;
	}
	$humanoid .=  $line;
}
while(my($def, $pattern) = each %joints) {
	$humanoid =~ s/$pattern/$1$prefix$def$2/g;
}

print $humanoid;
