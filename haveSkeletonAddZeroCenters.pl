#!/usr/bin/perl
use strict;
use warnings;

use Math::Trig;

# tAke as input a VRML skeleton with DEF/USE and name for Joints and produce a skeleton with blank centers replaced by 0 0 0

# parameters
#
# $ARGV[0] -- JOint center and rotation
# STDIN -- X3DV file with HAnimJoints
#
#

my %joints = ();
my $joint = "WRONG JOINT";
my @skeleton = ();
my @joints = ();
while(<STDIN>) {
	push @skeleton, $_;

	if (/^(.*)(DEF|USE) ([^ ]*) HAnimJoint(.*)name[ \t]*["']([^\"\']*)['"]/) {
		my $header = $1;
		my $defuse = $2;
		my $defjoint = $3;
		my $leadingfields = $4;
		my $name = $5;
		$defjoint =~ m/^([^_]*_)(.*)/;
		my $def = $1;
		my $joint = $2;
		$joints{$joint} = {};
		my $jointobj = $joints{$joint};
		$jointobj->{DEF} = $defjoint;
		push @joints, $jointobj;
		if ($joint ne $name) {
			print STDERR "DEF/USE $defjoint does not match $name\n";
		}
	} elsif (/HAnimJoint/) {
		print STDERR "Couldn't match $_ in haveSkeletonAddZeroCenters.pl stdin loop\n";
	}
}

my $joints = "\r\n".join("\r\n", @joints);
for (@skeleton) {
	my $line = $_;
	if ($line =~ /^(.*)HAnimJoint(.*)name[ \t][ \t]*["']([^\"\']*)['"](.*)([ \t][ \t]*center[ \t]*[-0-9.e][-0-9.e]*[ \t][ \t]*[-0-9.e][-0-9.e]*[ \t][ \t]*[-0-9.e][-0-9.e]*)([ \t][ \t]*.*)$/) {
		my $header = $1;
		my $leadingfields = $2;
		my $joint = $3;
		my $fields = $4;
		my $center = $5;
		my $trailer = $6;
		# override center
		$center = "0.0 0.0 0.0";
		# replace the existing line
		$line = $header."HAnimJoint".$leadingfields."name \"$joint\" $fields"." center $center $trailer\n";
	} elsif ($line =~ /^(.*)HAnimJoint(.*)name[ \t][ \t]*["']([^\"\']*)['"](.*)[ \t][ \t]*([^a-zA-Z\[]*)(.*)$/) {
		my $header = $1;
		my $leadingfields = $2;
		my $joint = $3;
		my $fields = $4;
		my $center = $5;
		my $trailer = $6;
		# override center
		$center = "0.0 0.0 0.0";
		# replace the existing line
		$line = $header."HAnimJoint".$leadingfields."name \"$joint\" $fields"." center $center $trailer\n";
	} elsif ($line =~ /HAnimJoint/) {
		$line =~ s/^[ \t][ \t]*//g;
		$line =~ s/[ \t][ \t]*$//g;
		print STDERR "Couldn't match $line in haveSkeletonAddZeroCenters.pl skeleton loop\n";
	}
	print $line;
}
