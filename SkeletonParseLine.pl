#!/bin/perl
use strict;
use warnings;
use Math::Trig;

# perl SkeletonParseLine.pl "$JOINTOUTPUT" "${WEIGHTS}" "${CENTERS}" | sed -e "s/IMAGE.png/${IMAGE}/" > "${OUTPUT}"
#
# Adds skinCoordIndexes, skinCoordWeights, Boxes in Skeleton
#
#export WEIGHTSFILE='lily_7_2 wieghts.txt'  # joint index and a weight for skinCoord*
#export WEIGHTSFILE="LILY 7_2 wieghts.txt"  # joint index and a weight for skinCoord*
#export WEIGHTSFILE="LILY 7_1 weights.txt"  # joint index and a weight for skinCoord*
#export WEIGHTSFILE="lily_6_1_weights.txt"  # joint index and a weight for skinCoord*
#export WEIGHTSFILE="Lily Rev 5 weights.txt"
#export WEIGHTS="${INPUTDIR}/${WEIGHTSFILE}"
#
#export CENTERSFILE='lilly_7_2 joint location.txt'  # Joint locations and rotations
#export CENTERSFILE="7_2 joint location.txt"  # Joint locations and rotations
#export CENTERSFILE="7_1 joint location.txt"  # Joint locations and rotations
#export CENTERSFILE="lily_6_1_joint_rotate.txt"  # Joint locations and rotations
#export CENTERSFILE="../Edited0721.rotated.txt"
#export CENTERS="${INPUTDIR}/${CENTERSFILE}"
#
# $ARGV[0] -- joints, OutputDir/${CHARACTER}Jointed.txt (Could be STDOUT)
# $ARGV[1] -- Weights InputDir/*weights.txt, (Could be STDIN)
# $ARGV[2] -- JOint center and rotation (not used)

my $joint = "WRONG JOINT";

open (WEIGHTS, "<$ARGV[1]") or die "Couldn't open weights file $ARGV[1]";

my %joints = ();
my $first = 1;
$joint = "WRONG JOINT";
while (<WEIGHTS>) {
	chomp;
	my $line = $_;
	if ($line =~ /^.*<(.*)>.*\r*$/) {
		$joint = $1;
		print STDERR "<$joint>\r\n";
		$joints{$joint} = {};
		$joints{$joint}->{INDEX} = [];
		$joints{$joint}->{WEIGHT} = [];
		# print STDERR "JOINT is |$joint|\n";
	} elsif ($line =~ /^\(([0-9]+)\) = ([0-9\.]+)\r*$/) {
		# print STDERR "($1) = $2\r\n";
		push(@{$joints{$joint}->{INDEX}}, $1);
		push(@{$joints{$joint}->{WEIGHT}}, $2);
	} else {
		print STDERR "DEAD SPACE $line\n";
	}
}
close(WEIGHTS);

$joint = "WRONG JOINT";

#open (CENTERS, "<$ARGV[2]") or die "Couldn't open center locations and rotations file $ARGV[2]";
#  # the below is done in centers.pl
#while (<CENTERS>) {
#	chomp;
#	$joint = $_;
#	if (/^S/) {
#		$joint = lc($joint);
#	}
#	if (/^([ \t]*)\r$/) {
#		$joint = $1;
#		next;
#	}
#	# 
#	if (/^([ \r\t]*)$/) {
#		# skip blank lines
#		next;
#	}
#	while ($joint =~ /(.*)\r$/) {
#		# spin until no new carriage returns
#		$joint = $1;
#	}
#	if ($joint =~ /(.*)[_ ]end\r*$/) {
#		print STDERR "Bogus0 joint '$joint', continuing, expect problems\r\n";
#		$joint = $1;
#		next;
#	}
#	if ($joint =~ /([^ ][^ ]*) .*\r*$/) {  # vc4 (neck)
#		print STDERR "Bogus-1 joint '$joint'\r\n";
#		$joint = $1;
#	}
#	if ($joint =~ /^[XYZxyz]/) {  # centers and rotations
#		$joint = uc($joint);
#	}
#	my $jointobj = $joints{$joint};
#	# print STDERR "Joint is $joint\n";
#	if (defined $joints{$joint}) {
#		print STDERR "Joint found in centers $joint\n";
#		while(<CENTERS>) {
#			chomp;
#			my $line = $_;
#			if ($line =~ /(.*)\r*$/) {
#				$line = $1;
#			}
#			if ($line =~ /___/) {
#				last;
#			} elsif ($line =~ /^([XYZxyz]):  *([-0-9.e][-0-9.e]*) m\r*$/) {
#				my $axis = uc($1);
#				my $number = $2;
#				# $number =~ s/^00*$/0.0/;  # castle-model-viewer requires floats--Not needed when you get number of floats right
#				#if ($axis == 'Z') {
#				#$number = -$number;
#				#}
#				$jointobj->{$axis} = $number;
#				print STDERR "Axis in meters $axis = $number\n";
#			} elsif ($line =~ /^([XYZxyz]):  *([-0-9.e][-0-9.e]*) ° *\r*$/) {
#				my $axis = lc($1);
#				my $number = $2;
#				# $number =~ s/^00*$/0.0/;  # castle-model-viewer requires floats--Not needed when you get number of floats right
#				$jointobj->{$axis} = $number;
#				print STDERR "Rotation in degrees $axis = $number\n";
#			}
#			# don't handle rotation yet.
#		}
#
#		# Define the rotation angles around x, y, and z axes
## no rotations
##		my $angle_x = $jointobj->{x};  # rotation angle around x axis in degrees
##		my $angle_y = $jointobj->{y};  # rotation angle around y axis in degrees
##		my $angle_z = $jointobj->{z};  # rotation angle around z axis in degrees
##
##		if ($angle_x == 0 && $angle_y == 0 && $angle_z == 0) {
##			$angle_z = 1;
##		}
##
##		if (int($angle_z) == 40) {
##			$jointobj->{Rotation} = [0, 0, 1, 0.78539815];
##		} elsif (int($angle_z) == -40) {
##			$jointobj->{Rotation} = [0, 0, -1, 0.78539815]; 
##		} else {
##			# override rotations to keep in A pose, pre R4.5 template
##			$jointobj->{Rotation} = [0, 0, 1, 0];
##		}
#		#$jointobj->{OFFSET} = [$jointobj->{X}, $jointobj->{Y}, $jointobj->{Z}];
#		$jointobj->{Center} = "$jointobj->{X} $jointobj->{Y} $jointobj->{Z}";
#		# $jointobj->{Translation} = ($jointobj->{X})." ".(($jointobj->{Y}))." ".($jointobj->{Z});
#		print STDERR "Joint $joint Center $jointobj->{Center}\n";
#	} elsif ($joint =~ /^[ \t\r]*$/) {
#		print STDERR "Bogus3 $joint \r\n";
#	} elsif ($joint =~ /____/) {
#	} else {
#		print STDERR "Bogus4 (no weights?) $joint, not in $ARGV[1]\r\n";
#	}
#}
#
#close(CENTERS);


open (JOINTS, "<$ARGV[0]") or die "Couldn't open joints file $ARGV[0]";


my $skinCoordIndex = " ";
my $skinCoordWeight = " ";
$joint = "WRONG JOINT";
while (<JOINTS>) {
	my $line = $_;
	if (/^(.*)DEF ([^ ]*) HAnimJoint(.*)center[ \t]*([-0-9.e][-0-9.e]*[ \t]*[-0-9.e][-0-9.e]*[ \t]*[-0-9.e][-0-9.e]*)[ \t]*skinCoordIndex[ \t]*(\[[^\]]*\])[ \t]*skinCoordWeight[ \t]*(\[*[^\]]*\])(.*)children[ \t]*\[(.*\r*)$/) {
		my $header = $1;
		my $defjoint = $2;
		my $leadingfields = $3;
		my $fields = $4;
		my $center = $6;
		my $sci = $6;
		my $scw = $7;
		my $trailer = $8;
		my $trailer2 = $9;
		$defjoint =~ m/^([^_]*_)(.*)/;
		my $def = $1;
		$joint = $2;
		#if ($joint ne $name) {
		#print STDERR "DEF $defjoint does not match $name\n";
		#}
		my $jointobj = $joints{$joint};
		if (defined($jointobj)) {
			# print STDERR "Match! $joint\n";
			$skinCoordIndex = join(" ", @{$jointobj->{'INDEX'}});
			$skinCoordWeight = join(" ", @{$jointobj->{'WEIGHT'}});
			#my $newcenter = $jointobj->{Center};
			#print STDERR "Joint $joint Old center $center New center $center\n";
			#if ($newcenter) {
			#$center = $newcenter;
			#}
			# Transform { translation -0.353 0.393 0.008 children [ Shape { geometry Box { size 0.003 0.003 0.003 } } ] }
			# print "$header"."DEF ".$def.$joint." HAnimJoint $fields rotation $newrotation center $center skinCoordIndex [ ".join(" ", $skinCoordIndex)." ] skinCoordWeight [ ".join(" ", $skinCoordWeight)." ]$trailer"."children [ Transform { rotation $newrotation translation $center children [ Shape { geometry Box { size 0.01 0.01 0.01 } } ] }\r\n $trailer2";
			# print "$header"."DEF ".$def.$joint." HAnimJoint $fields center $center skinCoordIndex [ ".join(" ", $skinCoordIndex)." ] skinCoordWeight [ ".join(" ", $skinCoordWeight)." ]$trailer"."children [ Transform { translation $center rotation $newrotation[0] $newrotation[1] $newrotation[2] $newrotation[3] children [ Shape { geometry Box { size 0.01 0.01 0.01 } } ] }\r\n $trailer2";
			print "$header"."\nDEF ".$def.$joint." HAnimJoint$leadingfields"."$fields center $center skinCoordIndex [ ".join(" ", $skinCoordIndex)." ] skinCoordWeight [ ".join(" ", $skinCoordWeight)." ]$trailer"."children [ # Transform { translation $center children [ Shape { geometry Box { size 0.01 0.01 0.01 } } ] }\r\n $trailer2";
			print STDERR "Found Joint $joint in weights table!\n";
		} else {
			print STDERR "No match for Joint $joint in weights table! (no weights?)\n";
			print $_."\n";
		}
	} elsif (/HAnimJoint/) {
		print STDERR "Couldn't match $line in SkeletonParseLine.pl\n";
		print $_;
	} else {
		print $_;
	}
}

close(JOINTS);
