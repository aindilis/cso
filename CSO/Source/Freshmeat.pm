package CSO::Source::Freshmeat;

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
     (StorageFile => "$UNIVERSAL::systemdir/data/source/Freshmeat/.cso",
      Type => "CSO::System"));
  $self->MySystems->Contents({});
  $self->Loaded(0);
}

sub UpdateSource {
  my ($self,%args) = (shift,@_);
  Message(Message => "Updating source: Freshmeat");
  # we are going to have spider the damn thing
  # here is how do it, using the tor anonymizing web browser
  # my $mech = 
  # http://sourceforge.net/export/rss2_projsummary.php?group_id=89366
}

sub LoadSource {
  my ($self,%args) = (shift,@_);
  my $c = `cat $UNIVERSAL::systemdir/data/source/Freshmeat/fmProjectDescriptions2007-Nov.txt`;
  my @current;
  my @e;
  my $mysql = PerlLib::MySQL->new(DBName => "cso");
  my $csv = Text::CSV->new
    ({sep_char => "\t"});
  foreach my $line (split /[\n\r]/, $c) {
    if ($line !~ /^\s*(\#|project_id)/) {
      $line =~ s/\\n//g;
      $csv->parse($line);
      my @fields = $csv->fields();
      if (@fields and defined $fields[0]) {
	if ($fields[0] ne "proj_unixname") {
	  if (1) {
	    $mysql->Insert
	      (Table => "systems",
	       Values => [
			  $fields[1],
			  $fields[2],
			  $fields[3],
			  $fields[4],
			  "FM(20071101)",
			  undef,
			 ]);
	  } else {
	    print Dumper ({
			   Values => [
				      $fields[1],
				      $fields[2],
				      $fields[3],
				      $fields[4],
				      "FM(20071101)",
				      undef,
				     ]
			  });
	  }
	}
      }
    }
  }
}

1;
