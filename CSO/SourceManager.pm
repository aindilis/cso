package CSO::SourceManager;

use Manager::Dialog qw(Message SubsetSelect);
use PerlLib::Collection;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw { ListOfSources MySources }

  ];

sub init {
  my ($self,%args) = (shift,@_);
  Message(Message => "Initializing sources...");
  my $dir = "$UNIVERSAL::systemdir/CSO/Source";
  my @names = map {$_ =~ s/.pm$//; $_} grep(/\.pm$/,split /\n/,`ls $dir`);
  # my @names = qw(AptCache);
  $self->ListOfSources(\@names);
  $self->MySources
    (PerlLib::Collection->new
     (Type => "CSO::Source"));
  $self->MySources->Contents({});
  foreach my $name (@{$self->ListOfSources}) {
    Message(Message => "Initializing CSO/Source/$name.pm...");
    require "$dir/$name.pm";
    my $s = "CSO::Source::$name"->new();
    $self->MySources->Add
      ($name => $s);
  }
}

sub UpdateSources {
  my ($self,%args) = (shift,@_);
  Message(Message => "Updating sources...");
  my @keys;
  if (defined $args{Sources} and ref $args{Sources} eq "ARRAY") {
    @keys = @{$args{Sources}};
  }
  if (!@keys) {
    @keys = $self->MySources->Keys;
  }
  foreach my $key (@keys) {
    Message(Message => "Updating $key...");
    $self->MySources->Contents->{$key}->UpdateSource;
  }
}

sub LoadSources {
  my ($self,%args) = (shift,@_);
  Message(Message => "Loading sources...");
  my @keys;
  if (defined $args{Sources} and ref $args{Sources} eq "ARRAY") {
    @keys = @{$args{Sources}};
  }
  if (!@keys) {
    @keys = $self->MySources->Keys;
  }
  foreach my $key (@keys) {
    Message(Message => "Loading $key...");
    $self->MySources->Contents->{$key}->LoadSource;
  }
}

sub Search {
  my ($self,%args) = (shift,@_);
  my @ret;
  foreach my $sys (@{$self->SearchSources
			    (Criteria => $args{Criteria} || $self->GetSearchCriteria,
			     Search => $args{Search},
			     Sources => $args{Sources})}) {
    push @ret, $sys;
  }
  @ret = sort {$a->ID cmp $b->ID} @ret;
  return \@ret;
}

sub Choose {
  my ($self,%args) = (shift,@_);
  $systemmapping = {};
  foreach my $sys
    (sort @{$self->SearchSources
	      (Criteria => $self->GetSearchCriteria,
	       Sources => $args{Sources})}) {
      $systemmapping->{$sys->SPrint} = $sys;
    }
  my @chosen = SubsetSelect
    (Set => \@set,
     Selection => {});
  my @ret;
  foreach my $name (@chosen) {
    push @ret, $systemmapping->{$name};
  }
  return \@ret;
}

sub SearchSources {
  my ($self,%args) = (shift,@_);
  Message(Message => "Searching sources...");
  my @keys;
  if (defined $args{Sources} and ref $args{Sources} eq "ARRAY") {
    @keys = @{$args{Sources}};
  }
  if (!@keys) {
    @keys = $self->MySources->Keys;
  }
  my @matches;
  my $conf = $UNIVERSAL::cso->Config->CLIConfig;
  if ($conf->{"--mysql"}) {
    @matches = @{$UNIVERSAL::cso->MyMySQL->Search
		   (%args)};
  } else {
    foreach my $key (@keys) {
      my $source = $self->MySources->Contents->{$key};
      if (! $source->Loaded) {
	Message(Message => "Loading $key...");
	$source->MySystems->Load;
	Message(Message => "Loaded ".$source->MySystems->Count." systems.");
	$source->Loaded(1);
      }
      if (! $source->MySystems->IsEmpty) {
	Message(Message => "Searching $key...");
	foreach my $system ($source->MySystems->Values) {
	  if ($system->Matches(Criteria => $args{Criteria})) {
	    push @matches, $system;
	  }
	}
      }
    }
  }
  return \@matches;
}

sub GetSearchCriteria {
  my ($self,%args) = (shift,@_);
  my %criteria;
  my $conf = $UNIVERSAL::cso->Config->CLIConfig;
  if (exists $conf->{-a}) {
    $criteria{Any} = $conf->{-a};
  }
  if (exists $conf->{-n}) {
    $criteria{Name} = $conf->{-n};
  }
  if (exists $conf->{-d}) {
    $criteria{ShortDesc} = $conf->{-d};
  }
  if (exists $conf->{-D}) {
    $criteria{LongDesc} = $conf->{-D};
  }
  if (exists $args{Search}) {
    $criteria{Name} = $args{Search};
  }
  if (! %criteria) {
    foreach my $field 
      # (qw (Name ShortDesc LongDesc Tags Dependencies Categories Source)) {
      (qw (Name ShortDesc)) {
	Message(Message => "$field?: ");
	my $res = <STDIN>;
	chomp $res;
	if ($res) {
	  $criteria{$field} = $res;
	}
      }
  }
  return \%criteria;
}

1;
