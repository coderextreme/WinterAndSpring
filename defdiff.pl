#!/usr/bin/perl
use strict;
use warnings;

# compare 2 files

print STDERR "Source 1 (S1): $ARGV[0]\n";
print STDERR "Source 2 (S2): $ARGV[1]\n";

my $file_name0 = $ARGV[0];
my $file_name1 = $ARGV[1];
my $stripbefore = quotemeta $ARGV[2];
my $stripafter = quotemeta $ARGV[3];

open(FILE0, "<$file_name0") or die "Couldn't open $file_name0\n";
open(FILE1, "<$file_name1") or die "Couldn't open $file_name1\n";

$file_name0 =~ s/.*\///;
$file_name1 =~ s/.*\///;

my $file_name_length0 = length $file_name0;
my $file_name_length1 = length $file_name1;

if ($file_name_length0 < $file_name_length1) {
	my $pad = $file_name_length1 - $file_name_length0;
	$file_name0 = " " x $pad . $file_name0;
}
if ($file_name_length0 > $file_name_length1) {
	my $pad = $file_name_length0 - $file_name_length1;
	$file_name1 = " " x $pad .$file_name1;
}


my $file_line_number0 = 0;
my $file_line_number1 = 0;
my $file_line0 = "";
my $file_line1 = "";
sub filter {

	# $file_line0 =~ s/^\s*//g;
	$file_line0 =~ s/\r*$//g;
	if ($stripbefore) {
		$file_line0 =~ s/.*\Q$stripbefore\E/$stripbefore/;
	}
	if ($stripafter) {
		$file_line0 =~ s/\Q$stripafter\E.*//;
	}

	# $file_line1 =~ s/^\s*//g;
	$file_line1 =~ s/\r*$//g;
	if ($stripbefore) {
		$file_line1 =~ s/.*\Q$stripbefore\E/$stripbefore/;
	}
	if ($stripafter) {
		$file_line1 =~ s/\Q$stripafter\E.*//;
	}
	return 1;
}
while(($file_line0 = <FILE0>) and ($file_line1 = <FILE1>)){
	if (not defined($file_line0) or not defined($file_line1)) {
		last;
	}
	chomp $file_line0;
	chomp $file_line1;
	$file_line_number0++;
	$file_line_number1++;

	$file_line_number0 =~ s/^(.)$/0$1/;
	$file_line_number1 =~ s/^(.)$/0$1/;
	$file_line_number0 =~ s/^(..)$/0$1/;
	$file_line_number1 =~ s/^(..)$/0$1/;

	&filter();
	if ($file_line0 eq $file_line1) {
		print "S1 $file_line_number0 S2 $file_line_number1: $file_line0\n";
	}
	while ($file_line0 ne $file_line1) {
		print "$file_name0 S1 $file_line_number0: $file_line0 <\n";
		print "$file_name1 S2 $file_line_number1: $file_line1 <\n";
		print STDERR "Lines not same.  Join lines of Source 1, Source 2, or skip. (Type 1 Enter, 2 Enter, or just Enter to skip):";
		my $ans = <STDIN>;
		chomp $ans;
		if ($ans =~ /1/) {
			$file_line0 = $file_line0 . <FILE0>;
			chomp $file_line0;
			$file_line_number0++;
		} elsif ($ans =~ /2/) {
			$file_line1 = $file_line1 . <FILE1>;
			chomp $file_line1;
			$file_line_number1++;
		} else {
			last;
		}
		&filter();
	}
}
close(FILE0);
close(FILE1);
