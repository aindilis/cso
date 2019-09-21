package CSO::Source::CPAN;

use Manager::Dialog qw (Message);
use PerlLib::Collection;
use CSO::System;

# use CPAN;
use Data::Dumper;

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
     (StorageFile => "$UNIVERSAL::systemdir/data/source/CPAN/.cso",
      Type => "CSO::System"));
  $self->MySystems->Contents({});
  $self->Loaded(0);
}

sub UpdateSource {
  my ($self,%args) = (shift,@_);
  Message(Message => "Updating source: CPAN");
}

sub LoadSource {
  my ($self,%args) = (shift,@_);
  #   for my $module (CPAN::Shell->expand("Module","/./")) {
  #     if (defined $module->description) {
  #       my $s = CSO::System->new
  # 	(Name => $module->id,
  # 	 ShortDesc => $module->description,
  # 	 Source => "CPAN");
  #       $self->MySystems->Add($s->Name => $s);
  #     }
  #   }
  #   $self->MySystems->Save;
}

1;
