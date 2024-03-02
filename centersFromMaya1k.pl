#!/usr/bin/perl
use strict;
use warnings;

use Math::Trig;

# tAke as input a VRML skeleton with DEF/USE and name for Joints and Joint centers file and produce a skeleton with those centers replaced by values in joint centers file

# parameters
#
# $ARGV[0] -- JOint center and rotation
# $ARGV[1] -- a skeleton source of DEFs (same as STDIN)
# STDIN -- X3DV file with HAnimJoints
#
#

my $scale = 1;
my %joints = ();
my $joint = "WRONG JOINT";
my @joints = ();

sub trim {
	my $str = shift @_;
	$str =~ s/^\s+//;
	$str =~ s/\s+$//;
	return $str;
}

open (DEFS, "<$ARGV[1]") or die "Couldn't open DEFs file $ARGV[1]";
while (<DEFS>) {
	my $line = $_;

	if ($line =~ /(DEF|USE)[ \t]+([^ \t]+)[ \t]+HAnimJoint/) {
		my $defjoint = $2;
		# print STDERR $line;
		$defjoint =~ s/(Toddler|[Gg]ramps|hanim)_//;
		my $joint = $defjoint;
		$joints{$joint} = {};
		print STDERR "Creating joint object $joint\n";
		my $jointobj = $joints{$joint};
		$jointobj->{DEF} = $defjoint;
		push @joints, $jointobj;
	} elsif ($line =~ /HAnimJoint/) {
		print STDERR "Couldn't match $_ in centersFromMaya1k.pl DEFS loop\n";
	}
}
close(DEFS);
print STDERR "Now proceeding with getting centers from $ARGV[0]\n";
open (CENTERS, "<$ARGV[0]") or die "Couldn't open center locations and rotations file $ARGV[0]";
$joint = "WRONG JOINT";
my $segment = "WRONG SEGMENT";
while (<CENTERS>) {
	chomp;
	my $line = $_;
	$line = trim($line);
	if ($line =~ /^S/) {  # Sacroiliac, etc.
		$line = lc($line);
	}
	if ($line =~ /(.*)[ _]end\r*$/) {
		print STDERR "Bogus6 joint '$line', continuing, expect problems\r\n";
		$line = $1;
		next;
	}
	#print STDERR "Processing $line...\n";
	if ($line =~ /^([^xyzXYZ][^ \t]+)[ \t]*:[ \t]*([^ \t]+)$/) {  # vc4 (neck)
		$joint = $1;
		$segment = $2;
		#print STDERR "Looking up joint object $joint\n";
		my $jointobj = $joints{$joint};
		print STDERR "Joint object is $jointobj\n";
		if ($jointobj->{DEF}) {
			#print STDERR "Entering $joint\n";
			while(<CENTERS>) {
				chomp;
				$line = $_;
				$line = trim($line);
				if ($line =~ /pre.*rotate/i) {
					#print STDERR "pre rotate\n";
					$line = <CENTERS>;
					$line = <CENTERS>;
					$line = <CENTERS>;
				} elsif ($line =~ /post.*rotate/i) {
					#print STDERR "post rotate\n";
					$line = <CENTERS>;
					$line = <CENTERS>;
					$line = <CENTERS>;
				} elsif ($line =~ /rotate:? */i) {
					#print STDERR "rotate\n";
					$line = <CENTERS>;
					$line = <CENTERS>;
					$line = <CENTERS>;
				} elsif ($line =~ /scale/i) {
					#print STDERR "scale\n";
					$line = <CENTERS>;
					$line = <CENTERS>;
					$line = <CENTERS>;
				} elsif ($line =~ /translate/i) {
					print STDERR "translate\n";
					while(<CENTERS>) {
						chomp;
						$line = $_;
						$line = trim($line);
						if ($line =~ /^([XYZxyz])[ \t]*:[ \t]*([-0-9.e][-+0-9.e]*)$/) {
							my $axis = uc($1);
							my $number = 0 + $2 * $scale;
							#if ($axis =~ /^[Zz]/) {
							#$number = -1 * $number;
							#}
							$jointobj->{$axis} = $number;
							print STDERR "$axis = $number\n";
						} else {
							print STDERR "Exiting x, y, z\n";
							last;
						}
					}
					$jointobj->{Center} = "$jointobj->{X} $jointobj->{Y} $jointobj->{Z}";
					last;
				}
			}
			print STDERR "Exiting\n$joint\n$jointobj->{Center}\n";

		} elsif ($joint =~ /^[ \t\r]*$/) {
			print STDERR "Bogus7 empty $joint \r\n";
		} elsif ($joints{$joint}) {
			print STDERR "Bogus11 Warning, joint $joint found in map, but not processed \r\n";
		} elsif ($joint =~ /^$/) {
			print STDERR "Bogus10 empty $joint \r\n";
		} else {
			print STDERR "Bogus9 (no def?) $joint \r\n";
		}
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
my $center = "0 0 0";
while(<STDIN>) {
	my $line = $_;
	$line =~ s/center[ \t]+[-\+0-9\.e]+[ \t]+[-\+0-9\.e]+[ \t]+[-\+0-9\.e]+//g;  # zap the old centers
	if ($line =~ /^(.*DEF[ \t]+)([^ \t]*)([ \t]+HAnimJoint[^{]*\{)([^{]*)$/) {
		my $header = $1;
		my $defjoint = $2;
		my $tag = $3;
		my $trailer = $4;
		my $joint = $defjoint;
		$joint =~ s/(Toddler|[Gg]ramps|hanim)_//;
		my $jointobj = $joints{$joint};
		$center = "0 0 0";
		if ($jointobj && $jointobj->{Center}) {
			$center = $jointobj->{Center};
			print STDERR "Defined center $center for $joint\n";
#			my $offset = $jointobj->{Center};
#			my @center = split(/[ \t\r]+/, $center);
#			my @offset = split(/[ \t\r]+/, $offset);
#			my @newcenter = ();
#			for (my $i = 0; $i < 3; $i++) {
#				$newcenter[$i] = 0 + $center[$i]; # + $offset[$i];
#				print STDERR "0 + $center[$i] /* + $offset[$i]*/ = $newcenter[$i]";
#				print STDERR ",\t";
#				$center = join(" ", @newcenter);
#			}
			$line = "$header$defjoint$tag center $center $trailer";
		} else {
			print STDERR "Undefined Center for $joint, skipping\n";
		}
		# replace the existing line
	} elsif ($line =~ /HAnimJoint/) {
		print STDERR "Couldn't match $line in centersFromMaya1k.pl stdin loop, not defining a center\n";
	} elsif ($line =~ /[ \t]rotation[ \t]/) {
		#$line = "";
	} elsif ($line =~ /[ \t]translation[ \t]/) {
		#$line = "";
	} elsif ($line =~ /[ \t]scale[ \t]/) {
		#$line = "";
	}
	$line =~ s/(Transform \{) .* (children USE HAnimSiteShape \})/$1 translation $center $2/;
	print $line;
}
