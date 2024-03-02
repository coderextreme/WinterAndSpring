#!/usr/bin/perl
use strict;
use warnings;

open(SCENE, "<0MainStageTotal_7Saved.txt") or die "Couldn't open main stage\n";

my $line = "";
my $oldchar = "";
my %timesperchar = ();
my %movesperchar = ();
my %booleanspermoveperchar = ();
my %char = ();
my @chars = ("Lily", "Gramps", "Leif", "Tufani");
# print join(" ",@chars)."\n";
my @times = ();
my $c = 0;
my %globalbooleanspercharpermove = ();
for ($c = 0; $c < @chars; $c++) {
	#print "$c $chars[$c]\n";
	$timesperchar{$chars[$c]} = ();
	$movesperchar{$chars[$c]} = ();
	$globalbooleanspercharpermove{$chars[$c]} = {};
}
while (<SCENE>) {
	$line = $_;
	if (/\((.*)\).*\((.*)_(.*)\)/) {
		# print $1." ".$2." ".$3."\n";
		my $time = $1;
		my $char = $2;
		my $anim = $3;
		my $move = $char."_".$anim;
		push(@{$timesperchar{$char}}, $time);
		push(@times, $time);
		push(@{$movesperchar{$char}}, $move);
	}
}
close(SCENE);

my %seen;
@times = sort grep !$seen{$_}++, @times;


print "{\n";
for ($c = 0; $c < @chars; $c++) {
	if ($c > 0) {
		print ",";
	}
	print '"'.$chars[$c].'"'.": {\n";
	print "\t".'"TimesPerCharacter": [ '.join(",", @{$timesperchar{$chars[$c]}})."], \n";
	print "\t".'"MovesPerCharacter": [ "'.join('","', @{$movesperchar{$chars[$c]}}).'" ],'."\n";
	my $movepercharprev = "";
	my $movepercharnext = "";

	my $timepercharprev = 0;
	my $timepercharnext = 1;
	for (my $m = 0; $m < @{$movesperchar{$chars[$c]}}; $m++) {
		my $move = $movesperchar{$chars[$c]}[$m];
		$globalbooleanspercharpermove{$chars[$c]}{$move} = ();
		for (my $b = 0; $b < @times; $b++) {
			# print "Set to false $move\n";
			$globalbooleanspercharpermove{$chars[$c]}{$move}[$b] = "false";
		}
	}
	print "\t".'"Global": [ '.join(",",@times)."], \n";
	for (my $tpc = 0; $tpc < @{$timesperchar{$chars[$c]}}; $tpc++) {
		my $mpc = $tpc;
		# print $movesperchar{$chars[$c]}[$mpc]."\n";

		if ($tpc > 0) {
			$movepercharprev = $movesperchar{$chars[$c]}[$mpc-1];
			$timepercharprev = 0 + $timesperchar{$chars[$c]}[$tpc-1];
		}

		my $moveperchar = $movesperchar{$chars[$c]}[$mpc];
		my $timeperchar = 0 + $timesperchar{$chars[$c]}[$tpc];

		if ($tpc < @{$timesperchar{$chars[$c]}}-1) {
			$movepercharnext = $movesperchar{$chars[$c]}[$mpc+1];
			$timepercharnext = 0 + $timesperchar{$chars[$c]}[$tpc+1];
		}
		# print $moveperchar." ";
		my $prevbool = 0;
		my $timeprev = 0;
		my $time = 0;
		my $timenext = 1;
		for (my $t = 0; $t < @times; $t++) {
			if ($t > 0) {
				$timeprev = 0 + $times[$t-1];
			}
			$time = 0 + $times[$t];
			if ($t < @times-1) {
				$timenext = 0 + $times[$t+1];
			}
			if ($time == $timeperchar) {
				$prevbool = 1;
				# print "Set to true $moveperchar $t\n";
				$globalbooleanspercharpermove{$chars[$c]}{$moveperchar}[$t] = "true";
			} elsif ($timepercharprev < $time && $time < $timepercharnext && $prevbool eq 1) {
				$prevbool = 1;
				# print "Set to true $moveperchar $t\n";
				$globalbooleanspercharpermove{$chars[$c]}{$moveperchar}[$t] = "true";
			} else {
				$prevbool = 0;
			}
		}
	}
	my %moveset = ();
	my @movelist = @{$movesperchar{$chars[$c]}};
	#print " ".join(" ", @movelist);
	#print " numer of times @movelist\n";
	for (my $mpc = @movelist-1; $mpc >= 0 ; $mpc--) {
		my $moveperchar = $movelist[$mpc];
		# print "index $mpc\n";
		# print "retrieve $moveperchar\n";
		@{$moveset{$moveperchar}} = @{$globalbooleanspercharpermove{$chars[$c]}{$moveperchar}};
	}
	keys %moveset; # reset the internal iterator so a prior each() doesn't affect the loop
	my $k;
	my $v;
	my @movebools = ();
	while(my($k, $v) = each %moveset) {
		my $movebools = "\t".'"'.$k.'": ['.(join(",", @{$v}))."]";
		push (@movebools, $movebools);
	}
	print join(",\n", @movebools);
	print "\n\t}\n";
}
print "}\n";
