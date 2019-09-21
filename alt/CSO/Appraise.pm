package CSO::Appraise;

# give   some  common   metrics   on  a   project,   related  to   the
# BOSS::Metric/statistics stuff

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       => [ qw / Config CodeComplexity   / ];

sub init {
  my ($self,%args) = (shift,@_);
}

sub Execute {
  my $self = shift;
}

1;
