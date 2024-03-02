#!/usr/bin/perl
use strict;
use warnings;

# parameters
#
# STDIN - VRML Humaoid with separate skin
# STDOUT -- VRML Humanoid with skin in place
#

my $skin = "";
while(<STDIN>) {
	my $line = $_;
	# $line =~ s/IndexedTriangleSet/IndexedFaceSet/;
	$skin .= $line;
}

# pull IFS fields out of skin
#
#
# $skin = "{...A{.{EF}.} B {CdB} {DDD {EEEE}}}";
# $skin = "{ appearance DEF MAT_PBR_1 Appearance { material Material { ambientIntensity 0.2 diffuseColor 0 0 0 specularColor 0 0 0 emissiveColor 0 0 0 shininess 0 transparency 0 } } geometry DEF FACESET__t_Lily_RV7_Shape1 IndexedFaceSet { } }";
my $shape = $skin;
$shape =~ s/((\n|.)*)(children DEF Shape)([ \t]*)(Shape[ \t])([^{]*)\{/{/;
my $leading = $1;
my $children = $3;
my $space = $4;
my $obj = $5;
my $rest = $6;

if ($shape =~ /(\{([^{}]+|(?R))*\})/)
{
	my $ifs = $1;
	my $trailing = substr($skin, length $leading.$children.$space.$obj.$ifs);
	print STDERR "leading length ".length($leading);
	print STDERR "\nchildren".length($children);
	print STDERR "\nspace".length($space);
	print STDERR "\nleading obj ".length($obj);
	print STDERR "\nifs length ".length($ifs);
	print STDERR "\ntrailing length ".length($trailing);
	$skin =~ s/\Q$children$space$obj$rest$ifs\E//;
	$skin =~ s/(DEF[ \t]*[^ \t][^ \t]*[ \t]*HAnimHumanoid[^{]*\{)/$1\nskin [\n DEF Shape $obj $rest $ifs\n]\n/;
}
print STDOUT $skin;
