#!/usr/bin/perl

# Take in a VRML skeleton and Extract points and triangles from a skeleton
#
# Should be written as separate utilities if possible
#
# parameters

# perl extractpointsvertices.pl "$REVERSE" "$OUTPOLYGONS" "$OUTPUTDIR"/points.txt  "$OUTPUTDIR"/triangles.txt
# $ARGV[0] -- Skeleton to reverse engineer
# $ARGV[1] -- extracted polygons as a table
# $ARGV[2] -- extracted points as one line
# $ARGV[3] -- extracted triangles a one line
# $ARGV[4] -- extracted vertices a atable

my $skeleton = "";

# read standard input into a huge buffer

open (OLDSKEL, "<$ARGV[0]") or die "Cannot open old skeleton file $ARGV[0]\n";
open (POLYGONS, ">$ARGV[1]") or die "Cannot open polygons file $ARGV[1]\n";
open (POINTS, ">$ARGV[2]") or die "Cannot open points file $ARGV[2]\n";
open (TRIANGLES, ">$ARGV[3]") or die "Cannot open triangles file $ARGV[3]\n";
open (VERTICES, ">$ARGV[4]") or die "Cannot open vertices file $ARGV[4]\n";
while(<OLDSKEL>) {
	$skeleton .= $_;
}

my $points = "";
my $triangles = "";

if ($skeleton =~ /skinCoord.*[^e]Coordinate { point \[((\n|\r|[^}\]])*)\]/) {
	$points = $1;
	print POINTS $points;

	my @points = split(/ /, $points);
	print STDERR "Found ".@points."/3 skin points.  Written to $ARGV[2]\n";
	my $ptlen = @points;
	print VERTICES "Point\tX        \tY\t           Z\r\n";
	my $i = 0;
	for (my $p = 1; $p < $ptlen;  $p += 3, $i++) {  # $points starts with a blank for now
		print VERTICES "$i\t";
		print VERTICES "$points[$p] m\t";
		print VERTICES "$points[$p+1] m\t";
		print VERTICES "$points[$p+2] m\r\n";
	}
	print STDERR "Found $i skin vertices.  Written to $ARGV[4]\n";
} else {
	print STDERR "No skin.  Need pattern skinCoord [^e]Coordinate { point \[((\n|\r|[^}\]])*)\]/ for points\n";
}
while ($skeleton =~ /skinCoord.*[^e]Coordinate { point \[((\n|\r|[^}\]])*)\] }/) {
	$skeleton =~ s/skinCoord.*[^e]Coordinate { point \[((\n|\r|[^}\]])*)\] }//g;
	print STDERR "Patttern /skinCoord [^e]Coordinate { point \[((\n|\r|[^}\]])*)\] }/ is not a valid skin, continuing\n";
}
if ($skeleton =~ /([ \t])coordIndex \[((\n|\r|[^\]])*)\]/) {
	$triangles = $2;
	# print STDERR $triangles;
	my @triangles = split(/ -1/, $triangles);
	my $trilen = @triangles;
	print POLYGONS "Polygon\tA\tB\tC\tD\r\n";
	for (my $t = 0; $t < $trilen-1;  $t++) {
		my $triangle = "$t $triangles[$t] \r\n";
		$triangle =~ s/ /\t/g;
		print POLYGONS $triangle;
	}
	print STDERR "Found ".($trilen-1)." skin triangles.  Written to $ARGV[1]\n";
	print TRIANGLES $triangles;
	print STDERR "Found ".($trilen-1)." skin triangles.  Written to $ARGV[3]\n";
} else {
	print STDERR "No skin.  Need pattern /([ \t])coordIndex \[((\n|\r|[^\]])*)\]/ for triangles.\n";
}

close(VERTICES);
close(TRIANGLES);
close(POINTS);
close(POLYGONS);
close(OLDSKEL);
		coordIndex  # triangle count is 41772
