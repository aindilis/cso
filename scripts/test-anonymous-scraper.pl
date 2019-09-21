#!/usr/bin/perl -w

use PerlLib::AnonymousScraper;

my $scraper = PerlLib::AnonymousScraper->new;
my $uri;
foreach my $system (split /\n/,`cat ../data/source/Sourceforge/projectraw`) {
  $uri = "http://sourceforge.net/projects/$system";
  print $uri."\n";
  $scraper->ScrapeURI(URI => $uri);
}
