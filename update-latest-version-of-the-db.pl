#!/usr/bin/perl -w

use PerlLib::Cacher;
use PerlLib::SwissArmyKnife;
use Verber::Util::DateManip;

use Data::Dumper;

my $datemanip = Verber::Util::DateManip->new();
my $cacher = PerlLib::Cacher->new();
my $url = "http://code.google.com/p/flossmole/downloads/list?num=1000";
  print "Fetching: $url\n";
$cacher->get($url);
my $c = $cacher->content();
my @allitems = $c =~ /<a href="([^"]+)">\s*(.+?)\s*<\/a>/sg;
foreach my $i (1..2) {
  $url = "http://code.google.com/p/flossmole/downloads/list?num=1000&start=".($i * 1000);
  print "Fetching: $url\n";
  $cacher->get($url);
  my $c = $cacher->content();
  my @items = $c =~ /<a href="([^"]+)">\s*(.+?)\s*<\/a>/sg;
  push @allitems, @items;
}

my $sources = {};
while (@allitems) {
  my $link = shift @allitems;
  my $linktext = shift @allitems;
  if ($linktext =~ /^datamart/) {
    if ($linktext =~ /^datamart_(.+?)(_(.+))?\.(\d{4})-(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\.sql\.bz2$/) {
      my $source = $1;
      my $releasetype = $3 || "unknown";
      my $year = $4;
      my $month = $datemanip->DOWHash->{lc($5)};
      $sources->{$source}{$releasetype}{sprintf("%04i%02i",$year,$month)} =
	{
	 Link => $link,
	 LinkText => $linktext,
	};
    } else {
      print "ERROR: linktext $linktext\n";
    }
  }
}

print Dumper($sources);

foreach my $source (keys %$sources) {
  foreach my $releasetype (keys %{$sources->{$source}}) {
    # get the latest version
    my $latestyearmonth = [sort {$b <=> $a} keys %{$sources->{$source}{$releasetype}}]->[0];
    print $source."\t".$releasetype."\t".$latestyearmonth."\n";
    GetCurrentVersion
      (
       Source => $source,
       Latest => $latestyearmonth,
       LinkText => $sources->{$source}{$releasetype}{$latestyearmonth}{LinkText},
      );
  }
}

sub GetCurrentVersion {
  my (%args) = @_;
  my $linkdir = "/var/lib/myfrdcsa/codebases/internal/cso/data/flossmole/datamarts/";
  my $downloadfile = $linkdir.$args{LinkText};
  if (! -f $downloadfile) {
    print "Downloading latest version of ".$args{Source}."\n";
    if (1) {
      system "mkdir -p ".shell_quote($linkdir);
      system "cd ".shell_quote($linkdir)." && wget ".shell_quote("http://flossmole.googlecode.com/files/".$args{LinkText});
    }
  } else {
    print "Already have latest version of ".$args{Source}."\n";
  }
}
