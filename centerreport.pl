#!/usr/bin/perl
use strict;
use warnings;

use Math::Trig;

# tAke as input a VRML skeleton with DEF/USE and name for Joints and Joint centers file and produce a skeleton with those centers replaced by values in joint centers file

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
		} else {
			# print STDERR "DEF/USE $defjoint matches $name\n";
		}
	} elsif (/HAnimJoint/) {
		print STDERR "Couldn't match $_ in centers.pl stdin loop\n";
	}
}

open (CENTERS, "<$ARGV[0]") or die "Couldn't open center locations and rotations file $ARGV[0]";
$joint = "WRONG JOINT";

while (<CENTERS>) {
	chomp;
	$joint = $_;
	if (/^S/) {
		$joint = lc($joint);
	}
	if (/^([ \t]*)\r$/) {
		$joint = $1;
		next;  #  line with white space, skip to next
	}
	# 
	if (/^([ \r\t]*)$/) {
		# skip blank lines
		next;
	}
	while ($joint =~ /(.*)\r$/) {
		# spin until no new carriage returns
		$joint = $1;
	}
	if ($joint =~ /(.*) end\r*$/) {
		print STDERR "Bogus6 joint '$joint', continuing, expect problems\r\n";
		$joint = $1;
		next;
	}
	if ($joint =~ /^[XYZxyz]/) {  # centers and rotations
		$joint = uc($joint);
	} elsif ($joint =~ /([^ ][^ ]*) .*\r*$/) {  # vc4 (neck)
		print STDERR "Warning, Bogus-2 joint '$joint'\r\n";
		$joint = $1;
	}
	my $jointobj = $joints{$joint};
	if ($jointobj->{DEF}) {
		# print STDERR "Entering $joint \r\n";
		while(<CENTERS>) {
			chomp;
			my $line = $_;
			if ($line =~ /(.*)\r*$/) {
				$line = $1;
			}
			if ($line =~ /___/) {
				# print STDERR "Exiting $joint \r\n";
				last;
			} elsif ($line =~ /^([XYZxyz]):  *([-0-9.e][-0-9.e]*) m ?\r*$/) {
				my $axis = uc($1);
				my $number = 0 + $2;
				$jointobj->{$axis} = $number;
			} elsif ($line =~ /^([XYZxyz]):  *([-0-9.e][-0-9.e]*) ° *\r*$/) {
				my $axis = lc($1);
				my $number = $2;
				$jointobj->{$axis} = $number;
			}
		}
		$jointobj->{Center} = "$jointobj->{X} $jointobj->{Y} $jointobj->{Z}";

	} elsif ($joint =~ /^[ \t\r]*$/) {
		print STDERR "Bogus7 empty $joint \r\n";
	} elsif ($joints{$joint}) {
		print STDERR "Bogus11 Warning, joint $joint found in map, but not processed \r\n";
	} elsif ($joint =~ /____/) {
		# pass
	} elsif ($joint =~ /^$/) {
		print STDERR "Bogus10 empty $joint \r\n";
	} else {
		print STDERR "Bogus9 (no def?) $joint \r\n";
	}
}

close(CENTERS);
my $joints = "\r\n".join("\r\n", @joints);
my $jointBindingPositions = "";
# my $jointBindingRotations = "";

for (@joints) {
	#$jointBindingPositions .= $_->{Center};
	#$jointBindingPositions .= "\n";
	#$jointBindingRotations .= $_->{Rotation};
	#$jointBindingRotations .= "\n";
}
foreach my $line  (@skeleton) {
# $skeleton =~ s/jointBindingPositions \[(( |\n|\r|[^\]])*)\]/jointBindingPositions [ $jointBindingPositions\n ]/;
# $skeleton =~ s/jointBindingRotations \[(( |\n|\r|[^\]])*)\]/jointBindingRotations [ $jointBindingRotations\n ]/;
	if ($line =~ /^(.*)HAnimJoint(.*)name[ \t][ \t]*["']([^\"\']*)['"](.*)[ \t][ \t]*center[ \t]*([^a-zA-Z\[]*)(.*)$/) {
		my $header = $1;
		my $leadingfields = $2;
		my $joint = $3;
		my $fields = $4;
		my $center = $5;
		my $trailer = $6;
		my $jointobj = $joints{$joint};
		if ($jointobj && $jointobj->{Center}) {
			my $out = "Skeleton center $joint: $center|  ";
			print STDOUT (" " x (85 - length $out)).$out;
			$center = $jointobj->{Center};
			print STDOUT "$center\tlocation file center $joint \n";
		} else {
			print STDERR "Undefined Center for $joint choosing 0 0 0\n";
			$center = "0.0 0.0 0.0";
		}
		# replace the existing line
	} elsif ($line =~ /HAnimJoint/) {
		$line =~ s/^[ \t][ \t]*//g;
		$line =~ s/[ \t][ \t]*$//g;
		print STDERR "Couldn't match $line in centers.pl skeleton loop, not defining a center\n";
	}
}
