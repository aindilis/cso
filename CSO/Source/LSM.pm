package CSO::Source::LSM;

use Manager::Dialog qw (Message);
use PerlLib::Collection;
use CSO::System;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MySystems Loaded /

  ];

# this is a system to update /etc/apt/sources.list intelligently

sub init {
  my ($self,%args) = (shift,@_);
  $self->MySystems
    (PerlLib::Collection->new
     (StorageFile => "$UNIVERSAL::systemdir/data/source/LSM/.cso",
      Type => "CSO::System"));
  $self->MySystems->Contents({});
  $self->Loaded(0);
}

sub UpdateSource {
  my ($self,%args) = (shift,@_);
  Message(Message => "Updating source: LSM");
  system "wget ftp://lsm.execpc.com/pub/lsm/LSM.current.gz";
  system "mv LSM.current.gz $UNIVERSAL::systemdir/data/source/LSM";
}

sub LoadSource {
  my ($self,%args) = (shift,@_);
  # Package Priority Section Installed-Size Maintainer Architecture
  # Source Version Depends Filename Size MD5sum Description Tag
  my $contents = `gunzip -d -c "data/source/LSM/LSM.current.gz"`;
  my @items = split /Begin4/, $contents;
  foreach my $item (@items) {
    my @lines = split /[\n\r]/, $item;
    my $package = {};
    my $current = "";
    my $done;
    while (@lines and ! $done) {
      my $l = shift @lines;
      if ($l =~ /^End/) {
	$done = 1;
      } elsif ($l =~ /^([A-Za-z-]+):\s*(.*?)\s*$/) {
	$current = $1;
	$package->{$current} .= $2;
      } elsif ($l =~ /^\s*(.*?)\s*$/) {
	$package->{$current} .= "\n".$1;
      }
    }
    my @t = split /[\n\r]/, $package->{Description};
    my $sd = $t[0];
    my $s = CSO::System->new
      (Name => $package->{Title},
       ShortDesc => $sd,
       LongDesc => $package->{Description},
       Source => "LSM");
    # print $s->SPrint."\n";
    $self->MySystems->Add($s->ID => $s);
  }
  $self->MySystems->Save;
}

1;



