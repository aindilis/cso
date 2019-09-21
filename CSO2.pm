package CSO2;

# ("created-by" "PPI-Convert-Script-To-Module")

use Data::Dumper;
use PerlLib::Cacher;
use PerlLib::SwissArmyKnife;
use Verber::Util::DateManip;
use PerlLib::MySQL;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / AllItems C Cacher DateManip Sources URI Specification LinkDir /

  ];

sub init {
  my ($self,%args) = @_;
  $self->DateManip(Verber::Util::DateManip->new());
  $self->Sources({});
  $self->Cacher(PerlLib::Cacher->new());
  $self->LinkDir("/var/lib/myfrdcsa/codebases/internal/cso/data/flossmole/datamarts/");
}

sub Execute {
  my ($self,%args) = @_;
  $self->URI("http://code.google.com/p/flossmole/downloads/list?num=1000");
  print "Fetching: ".$self->URI."\n";
  $self->Cacher->get($self->URI);
  $self->C($self->Cacher->content());
  my @allitems = $self->C =~ /<a href="([^"]+)">\s*(.+?)\s*<\/a>/sg;
  $self->AllItems(\@allitems);
  foreach my $i (1..2) {
    $self->URI("http://code.google.com/p/flossmole/downloads/list?num=1000&start=".($i * 1000));
    print "Fetching: ".$self->URI."\n";
    $self->Cacher->get($self->URI);
    $self->C($self->Cacher->content());
    my @items = $self->C =~ /<a href="([^"]+)">\s*(.+?)\s*<\/a>/sg;
    push @{$self->AllItems}, @items;
  }
  while (@{$self->AllItems}) {
    my $link = shift @{$self->AllItems};
    my $linktext = shift @{$self->AllItems};
    if ($linktext =~ /^datamart/) {
      if ($linktext =~ /^datamart_(.+?)(_(.+))?\.(\d{4})-(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\.sql\.bz2$/) {
	my $source = $1;
	my $releasetype = $3 || "unknown";
	my $year = $4;
	my $month = $self->DateManip->DOWHash->{lc($5)};
	$self->Sources->{$source}{$releasetype}{sprintf("%04i%02i",$year,$month)} =
	  {
	   Link => $link,
	   LinkText => $linktext,
	  };
      } else {
	print "ERROR: linktext $linktext\n";
      }
    }
  }
  print Dumper($self->Sources);
  my @files;
  foreach my $source (keys %{$self->Sources}) {
    foreach my $releasetype (keys %{$self->Sources->{$source}}) {
      # get the latest version
      my $latestyearmonth = [sort {$b <=> $a} keys %{$self->Sources->{$source}{$releasetype}}]->[0];
      print $source."\t".$releasetype."\t".$latestyearmonth."\n";
      my %data =
	(
	 Source => $source,
	 Latest => $latestyearmonth,
	 LinkText => $self->Sources->{$source}{$releasetype}{$latestyearmonth}{LinkText},
	 ReleaseType => $releasetype,
	);
      if ($releasetype eq 'structure') {
	push @dofirstfiles,
	  {
	   File => $self->GetCurrentVersion(%data),
	   %data,
	  };
      } else {
	push @dosecondfiles,
	  {
	   File => $self->GetCurrentVersion(%data),
	   %data,
	  };
      }
    }
  }
  $self->LoadDatamartsIntoDB
    (
     Files => [
	       \@dofirstfiles,
	       \@dosecondfiles,
	      ],
    );
}

sub GetCurrentVersion {
  my ($self,%args) = @_;
  my $linkdir = $self->LinkDir;
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

sub LoadDatamartsIntoDB {
  my ($self,%args) = @_;
  if (! -f ConcatDir($ENV{HOME},'.my.cnf')) {
    die "You need to set up your .my.cnf file to have the credentials to login from the shell\n";
  }
  if (Approve("Are you sure you want to upload all the flossmole databases, it may overwrite the existing db?")) {
    my $command = "echo 'create database if not exists `cso_flossmole`' | mysql";
    print $command."\n";
    system $command;

    $command = 'cat /var/lib/myfrdcsa/codebases/internal/cso/cso_flossmole-tables/gh_projects.sql | mysql cso_flossmole';
    print $command."\n";
    system $command;

    my $seen = {};
    my $installlog = "/var/lib/myfrdcsa/codebases/internal/cso/data/install-log.txt";
    my $c = "";
    if (-f $installlog) {
      $c = read_file($installlog);
    }
    foreach my $linktext (split /\n/, $c) {
      $seen->{$linktext} = 1;
    }
    my $fh = IO::File->new();
    $fh->open('>>'.$installlog);


    my $linkdir = $self->LinkDir;
    foreach my $file (@{$args{Files}->[0]}) {
      next if $seen->{$file->{LinkText}} and print 'Seen '.$file->{LinkText}."\n";
      my $command = "bzcat ".shell_quote(ConcatDir($linkdir,$file->{LinkText}))." | mysql cso_flossmole";
      print $command."\n";
      print $fh $file->{LinkText}."\n";
      system $command;
    }

    foreach my $file (@{$args{Files}->[1]}) {
      next if $seen->{$file->{LinkText}} and print 'Seen '.$file->{LinkText}."\n";
      my $command = "bzcat ".shell_quote(ConcatDir($linkdir,$file->{LinkText}))." | mysql cso_flossmole";
      print $command."\n";
      print $fh $file->{LinkText}."\n";
      system $command;
    }
    $fh->close();

    $command = 'cat /var/lib/myfrdcsa/codebases/internal/cso/cso_flossmole-tables/alter-table-commands.sql | mysql cso_flossmole';
    print $command."\n";
    system $command;

  }
}

1;
