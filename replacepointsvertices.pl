#!/usr/bin/perl
use strict;
use warnings;
#

# take a VRML skeleton and replace polygon points/vertices and texture points and vertices
#
# replaces point's fields, coordIndex and texCorodIndex

# parameters;

# $ARGV[0] -- Original skeleton
# $ARGV[1] -- new skeleton
# $ARGV[2] -- new points
# $ARGV[3] -- new triangles
# $ARGV[4] -- new texture trinagles

my $skeleton = "";
my $newpoints = "";
my $newtriangles = "";
my $newtextures = "";
my $newtexindex = "";

# read standard input into a huge buffer

open (OLDSKEL, "<$ARGV[0]") or die "Cannot open old skeleton file $ARGV[0]\n";
while(<OLDSKEL>) {
	$skeleton .= $_;
}
close(OLDSKEL);

open (POINTS, "<$ARGV[2]") or die "Cannot open points file $ARGV[2]\n";
while(<POINTS>) {
	$newpoints .= $_;
}
close(POINTS);

open (TRIANGLES, "<$ARGV[3]") or die "Cannot open triangles file $ARGV[3]\n";
while(<TRIANGLES>) {
	$newtriangles .= $_;
}
close(TRIANGLES);

open (TEXTURES, "<$ARGV[4]") or die "Cannot open textures file $ARGV[4]\n";
my $line = 0;
while(<TEXTURES>) {
	$newtextures .= $_;
	$line++;
	if ($_ =~ /-/) {
		warn "Negative texture coordinate, warning on line $line!\n"
	}
}
close(TEXTURES);

my @newtextures = split(/[ \t\r\n]+/, $newtextures);
my $uv = "";
my $tci = "";
my %tciset = ();

my $SEPARATOR = " "; # could be \n

for (my $tx = 0, my $row = 0; $tx < @newtextures; $tx += 7, $row += 3) {
	my $p1 = "$newtextures[$tx+1] $newtextures[$tx+2]$SEPARATOR";
	my $p2 = "$newtextures[$tx+3] $newtextures[$tx+4]$SEPARATOR";
	my $p3 = "$newtextures[$tx+5] $newtextures[$tx+6]$SEPARATOR";
	if (!$tciset{$p1}) {
		$tciset{$p1} = $row;
	}
	if (!$tciset{$p2}) {
		$tciset{$p2} = $row+1;
	}
	if (!$tciset{$p3}) {
		$tciset{$p3} = $row+2;
	}
	$uv .= $p1.$p2.$p3;
	#$tci .= ($tciset{$p1})." ".($tciset{$p2})." ".($tciset{$p3})." -1$SEPARATOR";
	$tci .= ($row)." ".($row+1)." ".($row+2)." -1$SEPARATOR";
}

my $texturecount = @newtextures / 7;

my @newtriangles = split(/[ \t\r\n]+/, $newtriangles);

my $trianglecount = @newtriangles / 4;  # also textureCoordIndex

my @newpoints = split(/[ \t\r\n]+/, $newpoints);

my $pointcount = @newpoints / 3;

# do the replacement
# We don't do TextureCoordinate yet
$skeleton =~ s/IndexedTriangleSet/IndexedFaceSet/;  # grab texturets between [ ] across multiple lines
$skeleton =~ s/(TextureCoordinate[ \r\t\n]*{[ \r\t\n]*)point \[((\n|\r|[^\]])*)\]/$1point [ $uv ] # texture count is $texturecount\r\n/;  # grab texturets between [ ] across multiple lines
$skeleton =~ s/([^e]Coordinate[ \r\t\n]*{[ \r\t\n]*)point \[((\n|\r|[^\]])*)\]/$1point [ $newpoints ] # point count is $pointcount\r\n/;  # grab points between [ ] across multiple lines
$skeleton =~ s/([ \t])coordIndex \[((\n|\r|[^\]])*)\]/$1coordIndex [ $newtriangles ] # triangle count is $trianglecount\r\n/;  # grab points betwen [ ] across multiple lines
$skeleton =~ s/texCoordIndex \[((\n|\r|[^\]])*)\]/texCoordIndex [ $tci ] # triangle count is $texturecount\r\n/;  # grab points betwen [ ] across multiple lines
#$skeleton =~ s/texCoordIndex \[((\n|\r|[^\]])*)\]/texCoordIndex [ $newtriangles ] # triangle count is $trianglecount\r\n/;  # grab points betwen [ ] across multiple lines
# TODO this looks non-standard
# $skeleton =~ s/([ \t])index \[((\n|\r|[^\]])*)\]/$1coordIndex [ $newtriangles ] # triangle count is $trianglecount\r\ntexCoordIndex [ $tci ] # triangle count is $texturecount\r\n/;  # grab points betwen [ ] across multiple lines
open (NEWSKEL, ">$ARGV[1]") or die "Cannot open new skeleton file $ARGV[1]\n";
print NEWSKEL $skeleton;
close(NEWSKEL);
