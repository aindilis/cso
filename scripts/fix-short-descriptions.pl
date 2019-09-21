#!/usr/bin/perl -w

use PerlLib::MySQL;

use Lingua::EN::Sentence qw (get_sentences);

my $mysql = PerlLib::MySQL->new(DBName => "cso");
my $s = "select * from systems where Source='Sourceforge';";
my $r = $mysql->Do(Statement => $s);
my $length = 100;
foreach my $key (keys %$r) {
  if (length($r->{$key}->{ShortDesc}) > $length) {
    my $desc = $r->{$key}->{LongDesc};
    my $s = get_sentences($desc);
    if ($s and @$s) {
      my $f = $s->[0];
      $f =~ s/[\n\r]/ /g;
      $f =~ s/\s+/ /g;
      if (length($f) > $length) {
	$f = substr($f,0,$length);
	my $c = "update systems set ShortDesc=".$mysql->Quote($f)." where ID=".$r->{$key}->{ID}.";";
	$mysql->Do(Statement => $c);
	print ".\n";
      }
    }
  }
}
