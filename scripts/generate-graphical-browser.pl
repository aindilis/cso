#!/usr/bin/perl -w

# program to generate a graph for use by Touchgraph LinkBrowser

use PerlLib::MySQL;

use Data::Dumper;
use Lingua::EN::Tagger;

my $p = new Lingua::EN::Tagger(stem => 0);

my $mysql = PerlLib::MySQL->new
  (DBName => "cso");

my $s = "select * from systems where ID < 1000";
my $r = $mysql->Do(Statement => $s);

my $docs = {};
my $tota;
foreach my $k (keys %$r) {
  my $tagged_text = $p->add_tags( $r->{$k}->{LongDesc} );
  my %w = $p->get_noun_phrases($tagged_text);
  $phrases->{$k} = \%w;
  foreach my $k1 (keys %w) {
    $docs->{$k1}->{$k} = $w{$k1};
    $total += $w{$k1};
  }
}

print Dumper($docs);

# now compute which are the important ones by TFIDF or something


# compute related tools
