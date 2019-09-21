package CSO::Source::Sourceforge;

use CSO::System;
use Manager::Dialog qw (Message);
use PerlLib::Collection;
use PerlLib::MySQL;

use Data::Dumper;
use Text::CSV;

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
     (StorageFile => "$UNIVERSAL::systemdir/data/source/Sourceforge/.cso",
      Type => "CSO::System"));
  $self->MySystems->Contents({});
  $self->Loaded(0);
}

sub UpdateSource {
  my ($self,%args) = (shift,@_);
  Message(Message => "Updating source: Sourceforge");
  # use data from ossmole (flossmole) project
}

sub LoadSource {
  my ($self,%args) = (shift,@_);
  # my $c = `cat $UNIVERSAL::systemdir/data/source/Sourceforge/sfProjectDescription02-Dec-2005.txt`;
  my $c = `cat $UNIVERSAL::systemdir/data/source/Sourceforge/sfProjectDesc2008-Aug.txt`;
  my @current;
  my @e;
  my $mysql = PerlLib::MySQL->new(DBName => "cso");
  my $csv = Text::CSV->new
    ({sep_char => "\t"});
  foreach my $line (split /[\n\r]/, $c) {
    if ($line !~ /^\s*(\#|project_id)/ and $line =~ /./) {
      $line =~ s/\\n//g;
      $csv->parse($line);
      my @fields = $csv->fields();
      if (@fields and defined $fields[0]) {
	if ($fields[0] ne "proj_unixname") {
	  $mysql->Insert
	    (Table => "systems",
	     Values => [
			$fields[0],
			undef,
			$fields[1],
			undef,
			"SF(20080801)",
			undef,
		       ]);
	}
      }
    }
  }
}

1;
