#!/usr/bin/perl
use strict;
use warnings;
#
# parameters
#
# Taks as Input a VRML joints skeleton with DEF and name for HAnimJoints, and add a joints field

# STDIN -- old skeleton
# STDOUT -- new skeleton
#
#
# Adjust tabs as needed TODO

my $skeleton = 0;
my $deletedFirstMeshDEF = 0;

# first find joints
while(<STDIN>) {
	my $line = $_;
	if ($skeleton == 0 && $line =~ /^\t\t\t\t\t\t\tchildren/) {
		$line =~ s/children/skeleton/;
		print $line;
		$line = <STDIN>;
		$line = <STDIN>;
		$line = <STDIN>;
		$line = <STDIN>;
		# $line = <STDIN>;
		$skeleton = 1;
	} elsif ($skeleton == 1 && $line =~ /^\t\t\t\t\t\t\t\]/) {
		$skeleton = 2;
		print $line;
	} elsif ($deletedFirstMeshDEF == 0 && $line =~ /mesh_t_Lily_RV7_Shape/) {
		$line = <STDIN>;
		$deletedFirstMeshDEF = 1;
	} else {
		print $line;
	}
}
