package CSO::Capabilities;

# creates ontologies, etc, from capability information

# Formalizes  capabilities  into   PI  calculus  or  other  controlled
# English, creates database of capabilities

use Manager::Dialog qw(Message SubsetSelect);
use PerlLib::Collection;
use PerlLib::NLP::Corpus;
use PerlLib::NLP::IE;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw { MyCorpus MyIE Capabilities }

  ];

sub init {
  my ($self,%args) = @_;
}

sub GenerateCapabilitiesFromSystems {
  my ($self,%args) = @_;
  my $conf = $UNIVERSAL::cso->Config->CLIConfig;
  $self->MyCorpus
    (PerlLib::NLP::Corpus->new
     ());
  $self->MyCorpus->Documents->Contents({});
  foreach my $sys
    (@{$UNIVERSAL::cso->MySourceManager->Search
	 (Criteria => {Any => "."},
	  Sources => $conf->{-g})}) {
      my $doc = $self->MyCorpus->AddContents
	(ID => $sys->ID,
	 Contents => $sys->LongDesc);
    }
  $self->MyIE
    (PerlLib::NLP::IE->new
     (Corpus => $self->MyCorpus));

  $self->MyIE->ExtractObjectNames;
  print Dumper($self->MyIE->Data);
}

sub RecommendSystemsToSolveProblem {
  my ($self,%args) = @_;
  # you simply state  a problem, and cso returns  systems that it
  # thinks might help to solve that problem
}

1;
