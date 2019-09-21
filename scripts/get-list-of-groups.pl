#!/usr/bin/perl -w

use Data::Dumper;

my $OUT;
open(OUT,">projects") or die "ouch\n";

my $projects = {};

foreach my $d0 (split /\n/,`ls /home/groups`) {
    print "$d0: ";
    foreach my $d1 (split /\n/,`ls /home/groups/$d0`) {
	print "$d1 ";
	foreach my $d2 (split /\n/,`ls /home/groups/$d0/$d1`) {
	    $projects->{$d2} = "/home/groups/$d0/$d1/$d2";
	}
    }
    print "\n";
}

print OUT Dumper($projects);
close(OUT);
