package CSO::Source::AptGetDotOrg;

use Manager::Dialog qw (Message ApproveCommands);
use PerlLib::Collection;
use CSO::System;

use IO::File;
use Parse::Debian::Packages;
use XML::Twig;
use YAML;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Loaded MySystems CacheFile OutputFile ChrootDir Twig /

  ];

# This  system  handles  the   generation  and  usage  of  a  gigantic
# /etc/apt/sources.list from apt-get.org data.  It also handles

sub init {
  my ($self,%args) = @_;
  $self->CacheFile("$UNIVERSAL::systemdir/data/source/AptGetDotOrg/apt-get.org.sources.list");
  $self->OutputFile("$UNIVERSAL::systemdir/data/source/AptGetDotOrg/sources.list");
  $self->ChrootDir("$UNIVERSAL::systemdir/data/chroot");
  $self->MySystems
    (PerlLib::Collection->new
     (StorageFile => $args{StorageFile} || "$UNIVERSAL::systemdir/data/source/AptGetDotOrg/.cso",
      Type => "CSO::System"));
  $self->MySystems->Contents({});
  $self->Loaded(0);
}

sub UpdateSource {
  my ($self,%args) = @_;
  Message(Message => "Updating source: AptGetDotOrg");
  if ($self->UpdateSourcesFile) {
    $self->ExtractPossibleSources;
  }
  # go ahead and use this apt-get file in the chroot (when its built)
  $self->UpdateChroot;
}

sub LoadSource {
  my ($self,%args) = @_;
  my $c = "sudo /usr/sbin/chroot ".$self->ChrootDir." apt-cache search -f .";
  print "$c\n";
  my $contents = `$c`;
  my $fh = IO::File->new(">/tmp/Packages");
  print $fh $contents;
  $fh->close;
  $fh = IO::File->new("</tmp/Packages");
  # I'll have to rewrite this so it works with this
  my $parser = Parse::Debian::Packages->new( $fh );
  while (my %package = $parser->next) {
    my $s = CSO::System->new
      (Name => $package{Package},
       ShortDesc => $package{Description},
       LongDesc => $package{body},
       Dependencies => $package{Depends},
       Source => "AptGetDotOrg");
    $self->MySystems->Add($s->ID => $s);
  }
  $self->MySystems->Save;
}

sub GetSystems {
  my ($self,%args) = @_;
  # given the data that is currently available, create and return a
  # collection of systems
  return $self->MySystems;
}

sub UpdateCacheFile {
  my ($self,%args) = @_;
  system "lynx -source http://www.apt-get.org/main.php > ".$self->CacheFile;
}

sub UpdateSourcesFile {
  my ($self,%args) = @_;
  # check whether file already exists, and when it was last written, if more than 1 day old
  my @stats = stat($self->CacheFile);
  my $diff = time - $stats[9];
  if (-f $self->CacheFile) {
    if ($diff > 86400) {
      print $self->CacheFile." file more than one day old, updating\n";
      # update();
      return 1;
    } else {
      print $self->CacheFile." file less than one day old, not updating\n";
    }
  } else {
    print "no ".$self->CacheFile." file, updating";
    $self->UpdateCacheFile;
    return 1;
  }
  return 0;
}

sub ExtractPossibleSources {
  my ($self,%args) = @_;
  $self->Twig(XML::Twig->new(           twig_handlers =>
					{
					 span     => sub { $self->DoSpan($_)  }, # output and free memory
					},
					pretty_print => 'indented'));

  $self->Twig->parsefile($self->CacheFile);
  open(FILE,">".$self->OutputFile) or
    die "can't open output file ".$self->OutputFile."\n";
  foreach my $source (sort keys %output) {
    print FILE $source."\n" if $self->Validate($source);
  }
  close(FILE);
}

sub Validate {
  my ($self,%args) = @_;
  my $source = shift;
  return $source =~ /^deb(-src)? (file|cdrom|http|ftp|copy|rsh|ssh):\/\/?\S+ (\S+)+($)?/;
}

sub DoSpan {
  my ($self,%args) = @_;
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

sub UpdateChroot {
  my ($self,%args) = @_;
  # copy the file into the chroot,
  ApproveCommands
    (Commands =>
     ["sudo cp \"".$self->OutputFile."\" ".$self->ChrootDir."/etc/apt/sources.list",
      "sudo mount -t proc proc ".$self->ChrootDir."/proc", # make sure to mount proc
      "sudo chroot ".$self->ChrootDir." apt-get update"]);

  # while there are errors, cycle through it
}

1;
