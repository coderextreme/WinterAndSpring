#!/bin/env perl
use strict;
use warnings;
#
# ARGV -- list of characters to substitute Timer for, to make a timer for each character

foreach my $character (@ARGV) {
	open (TIMERS, "<takes.$character.timers.txt") or die "ls of takes.$character.timers.txt failed!\n";
	while (<TIMERS>) {
		chomp;
		my $pattern = $character."_([A-Z][a-z][a-z]*)([0-9][0-9]*)Timer";

		if ( /$pattern/) {
			my $wsmove = $1;
			my $move = $1;
			my $submove = $2;
			if ($submove eq "") {
				die "Bad submove $submove\n";
			}
			$move =~ s/Turn/Yaw/g;
			open(MOVE, "<$ENV{GENERATION}.$move.txt") or die "Cannot open $ENV{GENERATION}.$move.txt\n";
			while(<MOVE>) {
				my $line = $_;
				$line =~ s/$ENV{GENERATION}(.)/$character$1/g;
				$line =~ s/$move/$character\_$wsmove$submove/g;
				print $line;
			}
			close(MOVE);

		}
	}
	close(TIMERS);
}
