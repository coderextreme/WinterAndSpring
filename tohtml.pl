# Example
"
-7.9962 0.0046 3.000, #(0) (Leif_Stand01)
-7.9962 0.0046 3.000, #(0.09) (Leif_Stand01)
-7.9962 0.0046 3.000, #(0.11) (Leif_Stand01)
-7.9962 0.0046 3.000, #(0.223) (Leif_Run01)
9.004 0.0796 3.4999, #(0.433) (Leif_Turn01)
11.5048 0.0796 3.3699, #(0.55) (Leif_Walk01)
16.0038 0.0796 7.8699, #(0.63) (Leif_Walk01)
18.5038 0.0796 14.8699, #(0.73) (Leif_Skip01)
23.0038 0.0796 24.3699, #(0.85) (Leif_Stand01)
23.0038 0.0796 24.3699, #(0.90) (Leif_Stand01)
23.0038 0.0796 24.3699, #(1) (Leif_Stand01)
";

open(BRIDGE, "<WinterAndSpringHumanoidTimingsRoot0406.txt") || die "Can't open 0MainStageTotal_7Saved.txt!\n";

print "<!DOCTYPE html>
<html>
<head>
<title>Main Stage</title>
</head>
<body>
<table>
<tr><th>X</th><th>Y</th><th>Z</th><th>Time</th><th>Character</th><th>Primary Move</th><th>Su move</th></tr>
";
while(<BRIDGE>) {
	my $line = $_;
	# print $line;
	if ($line =~ /([-0-9\.e\+]+)[ \t]+([-0-9\.e\+]+)[ \t]+([-0-9\.e\+]+),[ \t]+#?\(([0-9\.]+)\)[ \t]+#?\(([A-Za-z]+)_([A-Za-z]+)([0-9]+)\)/) {
		print STDERR "Match\n";
		my $x = $1;
		my $y = $2;
		my $z = $3;
		my $t = $4;
		my $name = $5;
		my $move = $6;
		my $submove = $7;
		print "<tr><td>$x</td><td>$y</td><td>$z</td><td>$t</td><td>$name</td><td>$move</td><td>$submove</td></tr>\n"
	} else {
		print STDERR "No match\n";
	}
}
print "</table>
</body>
</html>
";
close(BRIDGE);
