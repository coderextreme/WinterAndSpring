#!/usr/bin/perl
use strict;
use warnings;

# tAke as input a VRML skeleton and add HAnimHumanoid and name

# STDIN -- input VRML skeleton
# STDOUT -- output VRML skeleton humanoid with names added, and skeleton moved under Humanoid
#
# TODO, look up DEFs in mapping.txt, reject HAnim Joints (not sites or segments yet) that don't fit list

# my $lines = "";
my $startTransformation = 0;
my $countBracketOpen = 0;
my $countBracketClosed = 0;
my $countBraceOpen = 0;
my $countBraceClosed = 0;
while(<STDIN>) {
	my $line = $_;
	$line =~ s/(scaroiliac|Sacroiliac)/sacroiliac/g;
	if ($line =~ /DEF[ \t]*([^ \t][^ \t]*)[ \t]*Transform/) {
		my $name = $1;
		my $nodeType = "HAnimJoint";
		if ($name =~ /[Hh]umanoid_[Rr]oot/) {
			$name = lc($name);
			$nodeType = "HAnimJoint";
			$startTransformation = 1;
		} elsif ($name =~ /_end$/) {
			$nodeType = "HAnimSite";
			$startTransformation = 1;
		} elsif ($name =~ /node_t_Lily_RV7_Shape/) {
			$name = "hanim";
			$nodeType = "HAnimHumanoid";
			$startTransformation = 1;
		} elsif ($name =~ /Armature$/) {
			$name = "hanim";
			$nodeType = "HAnimHumanoid";
			$startTransformation = 1;
		} else {
			$nodeType = "Transform";
			$startTransformation = 0;
		}
		if ($startTransformation == 1) {
			$line =~ s/DEF[ \t]*[^ \t]+[ \t]*Transform([ \t\{]+)/DEF $name $nodeType $1 name "$name" /;
		}
	} elsif ($line =~ /(EXPORT) (.*)/) {
		# $line = "$1 $2";
		# delete
		$line = "";
	} elsif ($line =~ /lily_7_3_animate/) {
		$line =~ s/lily_7_3_animate/hanim/g;
	}
	$countBracketOpen += $line =~ tr/\[//;
	$countBracketClosed += $line =~ tr/\]//;
	$countBraceOpen += $line =~ tr/\{//;
	$countBraceClosed += $line =~ tr/\}//;
	if ($countBraceOpen == $countBraceClosed && $countBraceOpen > 0 && $countBraceClosed > 0 &&
	  $countBracketOpen == $countBracketClosed && $countBracketOpen > 0 && $countBracketClosed > 0) {
		$line .= "# TIS ALL GOOD!\n";
		$startTransformation = 0;
	} else {
		# $line .= "# ace $countBraceOpen != $countBraceClosed acket $countBracketOpen != $countBracketClosed !\n";
	}
	print $line;
	# $lines .= $line;	
}
