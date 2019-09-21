package CSO::MySQL;

# actually this should be part of the PerlLib source manager system

# perhaps time to do some fresh rewrites of these systems

use DBI;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / DBName DBH /

  ];

sub init {
  my ($self,%args) = @_;
  $args{Password} ||= `cat /etc/myfrdcsa/config/perllib`;
  chomp $args{Password};
  $self->DBName($args{DBName} ||
	       "CSO");
  $self->DBH
    (DBI->connect
     ("DBI:mysql:database=" .
      "cso".
      ";host=localhost",
      "root", $args{Password},
      {
       'RaiseError' => 1}));
}

sub SyncSources2SQL {
  my ($self,%args) = @_;
  # $self->CreateTables();
  # iterate over the systems
  foreach my $sys (sort @{$UNIVERSAL::cso->MySourceManager->SearchSources
			    (Criteria => {Any => "."},
			     Sources => undef)}) {
    my @i;
    foreach my $f (qw(ID Name FullName ShortDesc LongDesc Source)) {
      push @i, $self->DBH->quote($sys->$f);
    }
    $self->DBH->do("insert into systems values (".join(", ",@i).");");
  }
}

sub CreateTables {
  my ($self,%args) = @_;
  $self->MySQLDo(Statement => "create database cso");
  $self->MySQLDo(Statement => "drop table systems");
  $self->MySQLDo(Statement => "create table systems (ID tinytext, Name tinytext, FullName tinytext, ShortDesc mediumtext, LongDesc longtext, Source tinytext);");
}

sub Search {
  my ($self,%args) = @_;
  my @res;
  if ($args{Criteria}) {
    my $query;
    my $sourcequery;
    my @fields;
    my $search;
    if ($args{Criteria}->{Any}) {
      @fields = qw(ID Name ShortDesc LongDesc);
      $search = $args{Criteria}->{Any};
    } elsif ($args{Criteria}->{Name}) {
      @fields = qw(Name);
      $search = $args{Criteria}->{Name};
    } elsif ($args{Criteria}->{ShortDesc}) {
      @fields = qw(ShortDesc);
      $search = $args{Criteria}->{ShortDesc};
    } elsif ($args{Criteria}->{LongDesc}) {
      @fields = qw(LongDesc);
      $search = $args{Criteria}->{LongDesc};
    }
#     $query .= join
#       (" or ", @fields)." like '\%$search\%'";
    $query .= "(".join
      (" or ", map "$_ like '\%$search\%'", @fields).")";
    if ($args{Sources} and @{$args{Sources}}) {
      $sourcequery = join(" or ",map "source='$_'", @{$args{Sources}}). " and";
    } else {
      $sourcequery = "";
    }
    # my $clause = "(source=AptCache or source=LSM or source=CPAN or source='FM(200701)' or source='SF(20061201)')";
    my $statement = "select * from systems where $sourcequery $query;";
    #     print Dumper($statement);
    print $statement."\n";
    my $ref = $self->MySQLDo(Statement => $statement,
			     KeyField => 'ID');
    foreach my $sysname (keys %$ref) {
      push @res, CSO::System->new
	(ID => $ref->{$sysname}->{ID},
	 Name => $ref->{$sysname}->{Name},
	 ShortDesc => $ref->{$sysname}->{ShortDesc},
	 LongDesc => $ref->{$sysname}->{LongDesc},
	 Source => $ref->{$sysname}->{Source});
    }
  }
  return \@res;
}

sub MySQLDo {
  my ($self,%args) = @_;
  my $statement = $args{Statement};
  if ($statement =~ /^select/i) {
    $sth = $self->DBH->prepare($statement);
    $sth->execute();
    return $sth->fetchall_hashref($args{KeyField});
  } else {
    $self->DBH->do($statement);
  }
}

1;
