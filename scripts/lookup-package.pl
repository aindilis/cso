#!/usr/bin/perl -w

my $query = "lynx -dump \"http://www1.apt-get.org/search.php?query=" .
  join('+',@ARGV) . "\&submit=\&arch\%5B\%5D=i386&arch\%5B\%5D=all\"";
my $contents = `$query`;

print $contents;

sub AddSourceToSourcesFile {
  my ($source) = (shift);
  my $sourcesfile = "/etc/apt/sources.list";
  system "echo \"$source\" >> $sourcesfile";
  system "cat $sourcesfile | sort -u > $sourcesfile";
}
