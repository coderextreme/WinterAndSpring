#!/usr/bin/perl
use strict;
use warnings;
#
# parameters
#
# Taks as Input a VRML joints skeleton with DEF and name for HAnimJoints, and add a joints field

# STDIN -- old skeleton
# STDOUT -- new skeleton

my @skeleton = ();
my @joints = ();

# first find joints
while(<STDIN>) {
	my $line = $_;
	push(@skeleton, $line);
	if ($line =~ /^(.*)DEF[ \t]+([^ \t]+)[ \t]+HAnimJoint/) {
		my $header = $1;
		my $defjoint = $2;
		push @joints, "USE $defjoint";
	} elsif ($line =~ /(HAnimJoint)/) {
		print STDERR $line;
		my $j = $1;
		$j =~ s/\r*$//g;
		print STDERR "Couldn't match $j in replacejoints.pl\n";
	}
}
my $joints = "\n".join("\n", @joints);

for (my $l = 0; $l < @skeleton; $l++) {
	my $line = $skeleton[$l];
	if ($line =~ /(.*)joints[\t ]+\[([^\]]*)\](.*)/) {
		my $header = $1;
		my $js = $2;
		my $footer = $3;
		$skeleton[$l] = $header."joints [$joints]".$footer;
	}
}
print join("\n", @skeleton);
