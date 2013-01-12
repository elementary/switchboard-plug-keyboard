#! /usr/bin/perl

use strict;
use warnings;

use XML::LibXML;
use Data::Dumper;

my $filename = '/usr/share/X11/xkb/rules/evdev.xml' ;

my $parser = XML::LibXML->new();
my $doc    = $parser->parse_file($filename);

my %languages;

foreach my $lang ( $doc->findnodes('//layout') )
{
	my @variants;
	
	my($desc) = $lang->findnodes('configItem/description')->to_literal;
	my($name) = $lang->findnodes('configItem/name')->to_literal;
	
	foreach my $list ($lang->findnodes('./variantList/variant'))
	{
		my($desc_2) = $list->findnodes('configItem/description')->to_literal;
		my($name_2) = $list->findnodes('configItem/name')->to_literal;
	
		push @variants, "$desc_2:$name_2";
	}
	
	$languages{ "$desc:$name" } = \@variants;
}

foreach my $key ( sort keys %languages )
{
	print "#" . $key . "\n";
	
	my @vars = @{$languages{$key}};
	
	foreach my $var ( sort @vars )
	{
		print $var . "\n";
	}
}
