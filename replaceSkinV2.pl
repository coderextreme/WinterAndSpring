#!/usr/bin/perl
use strict;
use warnings;

# parameters
#
# $ARGV[0] -- VRML skeleton with skin.  This skin has IndexedRaceSet
# $ARGV[1] -- VRML skin to replace.  This skin has IndexedTriangleSet...we are replacing it
# STDOUT -- combined VRML skeleton
#
# TODO, look up DEFs in mapping.txt, reject HAnim Joints (not sites or segments yet) that don't fit list
#

my $skin = "";
open(SKIN, "<$ARGV[0]") or die "Cannot open $ARGV[0], skeleton with skin converted from X3D output from Blender\n";
print STDERR "Reading $ARGV[0]\n";
while(<SKIN>) {
	$skin .= $_;
}
close(SKIN);

# pull IFS fields out of skin
#
my $tcpoint = "";
my $cpoint = "";
my $tci = "";
my $ci = "";

print STDERR "Extracting $ARGV[0]\n";
$skin =~ /geometry IndexedFaceSet(.|\n)+texCoord([^I]|\n)+TextureCoordinate \{.*point[^\[]*\[([^\]]*)\]/;
$tcpoint = $3;
$skin =~ /geometry IndexedFaceSet(.|\n)+coord(.|\n)+[^e]Coordinate \{.*point[^\[]*\[([^\]]*)\]/;
$cpoint = $3;
$skin =~ /geometry IndexedFaceSet(.|\n)+coordIndex[^\[]*\[([^\]]*)\]/;
$ci = $2;
$skin =~ /geometry IndexedFaceSet(.|\n)+texCoordIndex[^\[]*\[([^\]]*)\]/;
$tci = $2;

$skin = "";

#print STDERR $tcpoint;
#print STDERR $tci;
#print STDERR $cpoint;
#print STDERR $ci;


my $skinless = "";
open(SKINLESS, "<$ARGV[1]") or die "Cannot open $ARGV[1], skeleton without skin\n";
print STDERR "Reading $ARGV[1]\n";
while(<SKINLESS>) {
	$skinless .= $_;
}
close(SKINLESS);

print STDERR "Substituting in data from $ARGV[0] into $ARGV[1]\n";
$skinless =~ s/(DEF[ \t][ \t]*[^ \t][^ \t]*skin \[(.|\n)(.|\n)*geometry IndexedTriangleSet(.|\n)(.|\n)*texCoord(.|\n)(.|\n)*TextureCoordinate \{.*point[^\[]*\[)([^\]]*)\]/$1$tcpoint]/;
if ($1) {
	print STDERR "Success on TextureCoordinate point\n";
} else {
	print STDERR "Failure on TextureCoordinate point\n";
}
$skinless =~ s/(DEF[ \t][ \t]*[^ \t][^ \t]*skin \[(.|\n)(.|\n)*geometry IndexedTriangleSet(.|\n)(.|\n)*coord(.|\n)(.|\n)*[^e]Coordinate \{.*point[^\[]*\[)([^\]]*)\]/$1$cpoint]/;
if ($1) {
	print STDERR "Success on Coordinate point\n";
} else {
	print STDERR "Failure on Coordinate point\n";
}
$skinless =~ s/(DEF[ \t][ \t]*[^ \t][^ \t]*skin \[(.|\n)(.|\n)*geometry IndexedTriangleSet(.|\n)(.|\n)*coordIndex[^\[]*\[)([^\]]*)\]/$1$ci]/;
if ($1) {
	print STDERR "Success on coordIndex\n";
} else {
	print STDERR "Failure on coordIndex\n";
}
$skinless =~ s/(DEF[ \t][ \t]*[^ \t][^ \t]*skin \n(.|\n)(.|\n)*geometry IndexedTriangleSet(.|\n)(.|\n)*texCoordIndex[^\[]*\[)([^\]]*)\]/$1$tci]/;
if ($1) {
	print STDERR "Success on texCoordIndex\n";
} else {
	print STDERR "Failure on texCoordIndex\n";
}

print STDERR "Outputting\n";
print STDOUT $skinless;

$skinless = "";
