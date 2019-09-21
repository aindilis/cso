package CSO;

use BOSS::Config;
use Manager::Dialog qw(Message);
use MyFRDCSA;
use CSO::Capabilities;
use CSO::MySQL;
use CSO::SourceManager;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       => [ qw / Config MySourceManager MyCapabilities MyMySQL / ];

sub init {
  my ($self,%args) = @_;
  $specification = "
	-U [<sources>...]	Update sources
	-l [<sources>...]	Load sources
	-s [<sources>...]	Search sources
	-c [<sources>...]	Choose sources
	-a <regex>		Any
	-n <regex>		Name regex
	-d <regex>		Short description regex
	-D <regex>		Long description regex

	-g [<sources>...]	Generate capabilities model

	--mysql			Use MySQL
	--mysql-sync		Sync MySQL

	-w			Require user input before exiting

	-u [<host> <port>]	Run as a UniLang agent
";

  $UNIVERSAL::systemdir = ConcatDir(Dir("internal codebases"),"cso");
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
  if (exists $conf->{'--mysql'}) {
    $self->MyMySQL(CSO::MySQL->new);
  }
  $self->MySourceManager
    (CSO::SourceManager->new
     ());
}

sub Execute {
  my ($self,%args) = @_;
  my $conf = $self->Config->CLIConfig;
  if (exists $conf->{'-U'}) {
    $self->MySourceManager->UpdateSources
      (Sources => $conf->{'-U'});
  }
  if (exists $conf->{'-l'}) {
    $self->MySourceManager->LoadSources
      (Sources => $conf->{'-l'});
  }
  if (exists $conf->{'-s'}) {
    foreach my $sys
      (@{$self->MySourceManager->Search
	   (Sources => $conf->{-s})}) {
	print $sys->SPrint."\n";
      }
  }
  if (exists $conf->{'-c'}) {
    $self->MySourceManager->Choose
      (Sources => $conf->{-c});
  }
  if (exists $conf->{'--mysql-sync'}) {
    $self->MyMySQL(CSO::MySQL->new) unless $self->MyMySQL;
    $self->MyMySQL->SyncSources2SQL;
  }
  if (exists $conf->{'-g'}) {
    $self->MyCapabilities
      (CSO::Capabilities->new
       ());
    $self->MyCapabilities->GenerateCapabilitiesFromSystems;
  }
  if (exists $conf->{'-a'}) {
    $criteria->{Any} = $conf->{'-a'};
    my $ret = $self->MySourceManager->Search
      (Criteria => $criteria,
       Sources => $conf->{-s});
    my $contents = join("\n",map {$_->SPrint} @$ret);
    print $contents."\n";
  }
  if (exists $conf->{'-n'}) {
    $criteria->{Name} = $conf->{'-n'};
    my $ret = $self->MySourceManager->Search
      (Criteria => $criteria,
       Sources => $conf->{-s});
    my $contents = join("\n",map {$_->SPrint} @$ret);
    print $contents."\n";
  }
  if (exists $conf->{'-u'}) {
    # enter in to a listening loop
    while (1) {
      $UNIVERSAL::agent->Listen(TimeOut => 10);
    }
  }
  if (exists $conf->{'-w'}) {
    Message(Message => "Press any key to quit...");
    my $t = <STDIN>;
  }
}

sub ProcessMessage {
  my ($self,%args) = @_;
  my $m = $args{Message};
  my $it = $m->Contents;
  if ($it) {
    # process the args in very much the same fashion as the regular args
    # for now, just do something simple
    if ($it =~ /^search (.*)$/) {
      my $ret = $self->MySourceManager->Search
	(Search => $1,
	 Sources => $conf->{-s});
      my $contents = join("\n",map {$_->SPrint} @$ret);
      $UNIVERSAL::agent->Send
	(Handle => $UNIVERSAL::agent->Client,
	 Message => UniLang::Util::Message->new
	 (Sender => "CSO",
	  Receiver => "UniLang",
	  Date => undef,
	  Contents => $contents));
    } elsif ($it =~ /^(-a\s*(.*?))?\s*(-n\s*(.*?))?\s*(-d\s*(.*?))?\s*(-D\s*(.*?))?$/) {
      my $criteria = {};
      $criteria->{Any} = $2 if $1;
      $criteria->{Name} = $4 if $3;
      $criteria->{ShortDesc} = $6 if $5;
      $criteria->{LongDesc} = $8 if $7;
      my $ret = $self->MySourceManager->Search
	(Criteria => $criteria,
	 Sources => $conf->{-s});
      my $contents = join("\n",map {$_->SPrint} @$ret);
      $UNIVERSAL::agent->Send
	(Handle => $UNIVERSAL::agent->Client,
	 Message => UniLang::Util::Message->new
	 (Sender => "CSO",
	  Receiver => $m->Sender,
	  Date => undef,
	  Contents => $contents));
    } elsif ($it =~ /^system (.*)$/i) {
      # lookup this particular system and produce its contents
      my $ret = $self->MySourceManager->Search
	(Criteria => {Name => "^$1\$"},
	 Sources => []);
      foreach my $sys (@$ret) {
	$sys->SPrintFull;
      }
    } elsif ($it =~ /^(quit|exit)$/i) {
      $UNIVERSAL::agent->Deregister;
      exit(0);
    }
  }
}

1;
