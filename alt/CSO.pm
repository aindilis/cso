package CSO;

use BOSS::Config;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       => [ qw / Config / ];

sub init {
  my ($self,%args) = (shift,@_);
  $specification = "
	-i <url>		Index a url
";
  $self->Config(BOSS::Config->new
		(Spec => $specification,
		 ConfFile => ""));
  my $conf = $self->Config->CLIConfig;
  if (exists $conf->{'-u'}) {
    $UNIVERSAL::agent->Register
      (Host => defined $conf->{-u}->{'<host>'} ?
       $conf->{-u}->{'<host>'} : "localhost",
       Port => defined $conf->{-u}->{'<port>'} ?
       $conf->{-u}->{'<port>'} : "9000");
  }
}

sub Execute {
  my $self = shift;
  my $conf = $self->Config->CLIConfig;
  if (exists $conf->{'-i'}) {
    
  }
}

1;
