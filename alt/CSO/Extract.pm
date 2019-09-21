package CSO::Extract;

use WWW::Mechanize;

sub Extract {
  my $url = shift;
  print "<$url>\n";
  my $mech = WWW::Mechanize->new;
  $mech->get($url);
  my $c = $mech->content;

  # do extraction of system information from the contents

  # first save it to a temp file
  my $OUT;
  open(OUT,">") or die "ouch!\n";
}

1;
