package CSO::Source::Freshmeat;

use Manager::Dialog qw (Message);
use PerlLib::Collection;
use CSO::System;

use Data::Dumper;
use XML::Twig;

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
     (StorageFile => $args{StorageFile} || "$UNIVERSAL::systemdir/data/source/Freshmeat/.cso",
      Type => "CSO::System"));
  $self->MySystems->Contents({});
  $self->Loaded(0);
}

sub UpdateSource {
  my ($self,%args) = (shift,@_);
  Message(Message => "Updating source: Freshmeat");
  system "wget -N -P $UNIVERSAL::systemdir/data/source/Freshmeat http://freshmeat.net/backend/fm-projects.rdf.bz2";
  system "wget -N -P $UNIVERSAL::systemdir/data/source/Freshmeat http://freshmeat.net/backend/fm-trove.rdf";
}

sub LoadSource {
  my ($self,%args) = (shift,@_);
  my $filename = "$UNIVERSAL::systemdir/data/source/Freshmeat/fm-projects.rdf";
  my $twig=XML::Twig->new
    (
     twig_handlers =>
     {
      project   => sub { my $h = {};
			 $h->{Name} = $_[1]->first_child
			   (projectname_short)->text;
			 $h->{FullName} = $_[1]->first_child
			   (projectname_full)->text;
			 $h->{ShortDesc} = $_[1]->first_child
			   (desc_short)->text;
			 $h->{LongDesc} = $_[1]->first_child
			   (desc_full)->text;
			 my $s = CSO::System->new
			   (Name => $h->{Name},
			    ShortDesc => $h->{ShortDesc},
			    LongDesc => $h->{LongDesc},
			    Source => "Freshmeat");
			 $self->MySystems->Add($s->Name => $s);
		       },
     },
     pretty_print => 'indented',
     empty_tags   => 'html',
    );
  $twig->parsefile($filename);
  $self->MySystems->Save;
}

sub GetSystems {
  my ($self,%args) = (shift,@_);
  # given the data that is currently available, create and return a
  # collection of systems
  return $self->MySystems;
}

1;
