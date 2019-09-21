#!/usr/bin/perl -w

use PerlLib::Cacher;

use Data::Dumper;

my $cacher = PerlLib::Cacher->new();
$cacher->get('http://frdcsa.org');
print Dumper({IsCached => $cacher->Cacher->is_cached()});
