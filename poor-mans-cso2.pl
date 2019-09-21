#!/usr/bin/perl -w

use BOSS::Config;
use PerlLib::SwissArmyKnife;

use Data::Dumper;

$specification = q(
	-s <search>		Search the DBs for SEARCH
	-w <width>		Width of the match
	-f <files>...		Restrict to these files
);

my $config =
  BOSS::Config->new
  (Spec => $specification);
my $conf = $config->CLIConfig;

my $dir = '/var/lib/myfrdcsa/codebases/internal/cso/data/flossmole/datamarts';
my $width = $conf->{'-w'} || 1000;

my $files = {};
my $ignore = {};
my @files;
if (exists $conf->{'-f'}) {
  @files = @{$conf->{'-f'}};
} else {
  @files = split /\n/, `ls $dir`;
}

if (exists $conf->{'-s'}) {
  my $s = $conf->{'-s'};
  foreach my $file (@files) {
    print "<$file>\n";
    my $command = 'bzgrep '.shell_quote($s)." $dir/$file";
    my $result = `$command`;
    # print '<'.$result.">\n";
    foreach my $entry (split /\n/, $result) {
      if (length($entry) > $width) {
	my @windows = grep {/$s/i} $entry =~ /(.{$width})/sg;
	print join("\n",map {"\t".$_} @windows)."\n";
      } else {
	print "\t".$entry."\n";
      }
    }
  }
}
