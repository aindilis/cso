#!/usr/bin/perl -w

use XML::Twig;

$sourceslist = "apt-get.org.sources.list";
$outputlist = "sources.list";

sub update {
  system "lynx -source http://www.apt-get.org/main.php > apt-get.org.sources.list";
}

sub update_sources_file {
  # check whether file already exists, and when it was last written, if more than 1 day old
  my @stats = stat($sourceslist);
  my $diff = time - $stats[9];
  if (-f $sourceslist) {
    if ($diff > 86400) {
      print "$sourceslist file more than one day old, updating\n";
      update();
      return 1;
    } else {
      print "$sourceslist file less than one day old, not updating\n";
    }
  } else {
    print "no $sourceslist file, updating";
    update();
    return 1;
  }
  return 0;
}

sub extract_possible_sources {
  my $twig = XML::Twig->new(           twig_handlers =>
				       {
					span     => sub { dospan($_)  }, # output and free memory
				       },
				       pretty_print => 'indented');

  $twig->parsefile($sourceslist);

  open(FILE,">$outputlist") or
    die "can't open output file $outputlist\n";

  foreach $source (sort keys %output) {
    print FILE $source."\n" if validate($source);
  }

  close(FILE);
}

sub validate {
  my $source = shift;
  return $source =~ q%^deb(-src)? (file|cdrom|http|ftp|copy|rsh|ssh)://?\S+ (\S+)+%;
}

sub dospan {
  $span = shift;
  $li = $span->parent;
  if ((defined $li->atts->{'class'}) && ($li->atts->{'class'} eq "verifiedsite")) {
    if ((defined $span->atts->{'class'}) && ($span->atts->{'class'} eq "url")) {
      foreach $line (split(/\n/,$span->text)) {
	if ($line =~ /^deb/) {
	  chomp $line;
	  $line =~ s/\s+/ /;
	  $output{$line} = 1;
	}
      }
    }
  }
}

extract_possible_sources if update_sources_file;
