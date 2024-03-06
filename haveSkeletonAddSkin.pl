#!/usr/bin/perl
use strict;
use warnings;

# parameters
#
# $ARGV[0] -- VRML skeleton without skin
# $ARGV[1] -- VRML skin (IFS, no weights) converted from X3D exported from Blender
# STDOUT -- combined VRML skeleton
#
# TODO, look up DEFs in mapping.txt, reject HAnim Joints (not sites or segments yet) that don't fit list
#

my $skin = "";
open(SKIN, "<$ARGV[1]") or die "Cannot open $ARGV[1], skeleton with skin converted from X3D output from Blender\n";
print STDERR "Reading $ARGV[1]\n";
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

print STDERR "Extracting $ARGV[1]\n";
$skin =~ /(.|\n)(.|\n)*DEF[ \t][ \t]*[^ \t][^ \t]*(_ifs_TRANSFORM|ID360)(.|\n)(.|\n)*geometry IndexedFaceSet(.|\n)(.|\n)*texCoord(.|\n)(.|\n)*TextureCoordinate \{.*point[^\[]*\[([^\]]*)\]/;
$tcpoint = $10;
$skin =~ /skinCoord.*[^e]Coordinate \{.*point[^}\[]*\[([^}\]]*)\]/;
$cpoint = $1;
$skin =~ /(.|\n)(.|\n)*DEF[ \t][ \t]*[^ \t][^ \t]*(_ifs_TRANSFORM|ID360)(.|\n)(.|\n)*geometry IndexedFaceSet(.|\n)(.|\n)*coordIndex[^\[]*\[([^\]]*)\]/;
$ci = $8;
$skin =~ /(.|\n)(.|\n)*DEF[ \t][ \t]*[^ \t][^ \t]*(_ifs_TRANSFORM|ID360)(.|\n)(.|\n)*geometry IndexedFaceSet(.|\n)(.|\n)*texCoordIndex[^\[]*\[([^\]]*)\]/;
$tci = $8;

$skin = "";


my $skinless = "";
open(SKINLESS, "<$ARGV[0]") or die "Cannot open $ARGV[0], skeleton without skin\n";
print STDERR "Reading $ARGV[0]\n";
while(<SKINLESS>) {
	my $skinless .= $_;
}
close(SKINLESS);

print STDERR "Substituting in data from $ARGV[0]\n";
$skinless =~ s/((.|\n)(.|\n)*DEF[ \t][ \t]*[^ \t][^ \t]*skin \[(.|\n)(.|\n)*geometry IndexedFaceSet(.|\n)(.|\n)*texCoord(.|\n)(.|\n)*TextureCoordinate \{.*point[^\[]*\[)([^\]]*)\]/$1$tcpoint]/;
$skinless =~ s/(skinCoord.*[^e]Coordinate \{.*point[^\[]*\[)([^}\]]*)\]/$1$cpoint]/;
$skinless =~ s/((.|\n)(.|\n)*DEF[ \t][ \t]*[^ \t][^ \t]*skin \[(.|\n)(.|\n)*geometry IndexedFaceSet(.|\n)(.|\n)*   coordIndex[^\[]*\[)([^\]]*)\]/$1$ci]/;
$skinless =~ s/((.|\n)(.|\n)*DEF[ \t][ \t]*[^ \t][^ \t]*skin \n(.|\n)(.|\n)*geometry IndexedFaceSet(.|\n)(.|\n)*texCoordIndex[^\[]*\[)([^\]]*)\]/$1$tci]/;

print STDERR "Outputting\n";
print STDOUT $skinless;

$skinless = "";
