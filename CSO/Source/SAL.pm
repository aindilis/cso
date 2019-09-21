package CSO::Source::SAL;

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
     (Type => "CSO::System"));
  $self->MySystems->Contents({});
  $self->Loaded(0);
}

sub UpdateSource {
  my ($self,%args) = (shift,@_);
  Message(Message => "Updating source: SAL");
}

sub LoadSource {
  my ($self,%args) = (shift,@_);
  my $s = CSO::System->new
    (Name => "",
     ShortDesc => "",
     LongDesc => "",
     Dependencies => "");
  # $self->MySystems->Add($s->Name => $s);
  $self->MySystems->Save;
  $self->Loaded(1);
}

sub GetSystems {
  my ($self,%args) = (shift,@_);
  # given the data that is currently available, create and return a
  # collection of systems
  return $self->MySystems;
}

1;
