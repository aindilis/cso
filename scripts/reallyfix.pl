#!/usr/bin/perl -w

use PerlLib::MySQL;

use Lingua::EN::Sentence qw (get_sentences);

my $mysql = PerlLib::MySQL->new(DBName => "cso");
my $s = "select * from systems where Source='Sourceforge' and length(ShortDesc) > 100;";
my $r = $mysql->Do(Statement => $s);
my $i = 0;
foreach my $key (keys %$r) {
  my $f = substr($r->{$key}->{ShortDesc},0,100);
  my $c = "update systems set ShortDesc=".$mysql->Quote($f)." where ID=".$r->{$key}->{ID}.";";
  $mysql->Do(Statement => $c);
  ++$i;
  if (!($i % 100)) {
    print ".\n";
  }
}
