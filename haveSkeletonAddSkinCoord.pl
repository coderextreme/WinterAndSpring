#!/bin/perl
use strict;
use warnings;

# Adds skinCoordIndexes, skinCoordWeights
#
# $ARGV[0] -- Weights InputDir/*weights.txt, (Could be STDIN)
# STDIN -- A skeleton
# STDOUT -- skeleton with skin coord indexes and weights

my $joint = "WRONG JOINT";

open (WEIGHTS, "<$ARGV[0]") or die "Couldn't open weights file $ARGV[0]";

my %joints = ();
my $first = 1;
$joint = "WRONG JOINT";
while (<WEIGHTS>) {
	chomp;
	my $line = $_;
	if ($line =~ /^.*<(.*)>.*\r*$/) {
		$joint = $1;
		$joints{$joint} = {};
		$joints{$joint}->{INDEX} = [];
		$joints{$joint}->{WEIGHT} = [];
		#print STDERR "<$joint>\r\n";
	} elsif ($line =~ /^\(([0-9]+)\) = ([0-9\.]+)\r*$/) {
		#print STDERR "($1) = $2\r\n";
		push(@{$joints{$joint}->{INDEX}}, $1);
		push(@{$joints{$joint}->{WEIGHT}}, $2);
	} else {
		# print STDERR "DEAD SPACE $line\n";
	}
}
close(WEIGHTS);

my $skinCoordIndex = " ";
my $skinCoordWeight = " ";
$joint = "WRONG JOINT";
while (<STDIN>) {
	my $line = $_;
	while ($line =~ /^.*DEF [^ \t]* HAnimJoint/ && $line !~ /^(.*DEF [^ \t]* HAnimJoint.*name[ \t]*["'][^\"\']*['"].*skinCoordIndex[ \t]*\[[^\]]*\][ \t]*skinCoordWeight[ \t]*\[*[^\]]*\])(.*\r*)$/) {
		#if ($line =~ /^(.*DEF [^ \t]* HAnimJoint.*name[ \t]*["'][^\"\']*['"])(.*\r*)$/) {
		#	my $header = $1;
		#	my $footer = $2;
		#	$line = "$header skinCoordIndex [  ] skinCoordWeight[  ] $footer";
		#}
		my $newline = <STDIN>;
		if ($newline) {
			# print STDERR "Adding $newline\n";
			$line .= $newline;
			$line =~ s/[\r\n]/ /g;
		} else {
			last;
		}
	}
	if ($line =~ /^(.*)DEF ([^ ]*) HAnimJoint(.*)name[ \t]*["']([^\"\']*)['"](.*)skinCoordIndex[ \t]*(\[[^\]]*\])[ \t]*skinCoordWeight[ \t]*(\[*[^\]]*\])(.*)\r*$/) {
	# if (/^(.*)DEF ([^ ]*) HAnimJoint(.*)name[ \t]*["']([^\"\']*)['"](.*)/) {
		my $header = $1;
		my $defjoint = $2;
		my $leadingfields = $3;
		my $name = $4;
		my $joint = $4;
		my $fields = $5;
		my $sci = $6;
		my $scw = $7;
		my $rest = $8;
		my $jointobj = $joints{$joint};
		if (defined($jointobj)) {
			# print STDERR "Match! $joint\n";
			$skinCoordIndex = join(" ", @{$jointobj->{'INDEX'}});
			$skinCoordWeight = join(" ", @{$jointobj->{'WEIGHT'}});
			if ($sci ne $skinCoordIndex) {
				print STDERR "Replacing skinCoordIndex $sci\n";
			}
			if ($scw ne $skinCoordWeight) {
				print STDERR "Replacing skinCoordWeight $scw\n";
			}
			print STDOUT "$header"."\nDEF ".$defjoint." HAnimJoint$leadingfields"."name \"$name\" $fields skinCoordIndex [ ".join(" ", $skinCoordIndex)." ] skinCoordWeight [ ".join(" ", $skinCoordWeight)." ] $rest";
			print STDERR "Found Joint $joint in weights table!\n";
		} else {
			print STDERR "No match for Joint $joint in weights table! (no weights?)\n";
			print STDOUT $_."\n";
		}
	} elsif ($line =~ /HAnimJoint/) {
		print STDERR "Couldn't match $line in haveSkeletonAddSkinCoord.pl\n";
		print STDOUT $_;
	} else {
		print STDOUT $_;
	}
}
