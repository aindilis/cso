package CSO::Source::MyFRDCSA;

use Manager::Dialog qw (Message);
use PerlLib::Collection;
use CSO::System;

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
     (StorageFile => "$UNIVERSAL::systemdir/data/source/MyFRDCSA/.cso",
      Type => "CSO::System"));
  $self->MySystems->Contents({});
  $self->Loaded(0);
}

sub UpdateSource {
  my ($self,%args) = (shift,@_);
  Message(Message => "Updating source: MyFRDCSA");
}

sub LoadSource {
  my ($self,%args) = (shift,@_);
  my $c = `cat $UNIVERSAL::systemdir/data/source/MyFRDCSA/projects`;
  my $projects = eval $c;
  foreach my $key (()) {
    my $s = CSO::System->new
      (Name => $key,
       Source => "MyFRDCSA");
    $self->MySystems->Add($s->Name => $s);
  }
  $self->MySystems->Save;
}

# sub ParseSubsystemDescriptionFile {
#   my ($self,%args) = (shift,@_);
#   # read in control file and write out nice stuff
#   if (-f $self->SubsystemDescriptionFile) {
#     # read in the control file and set values
#     $self->SubsystemDescriptionContents
#       (FWeb::FRDCSA->new
#        (SubsystemDescriptionFile => $self->SubsystemDescriptionFile));
#     $self->Generate;
#   } else {
#     print "Warning, project ". $self->Name ." lacks an FRDCSA.xml file.\n";
#     # check here to see whether we can still use this
#     my $command = "ls ".$self->SubsystemActualLocation."/*.deb";
#     my $result = `$command`;
#     chomp $result;
#     if ($result) {
#       $command = "dpkg-deb -f $result Description";
#       my $desc = `$command`;
#       $desc =~ s/\n/\<p>/;
#       $desc =~ s/^ \./\<p>/mg;
#       $self->SubsystemDescriptionContents
# 	(FWeb::FRDCSA->new
# 	 (Title => $self->Name,
# 	  MediumDesc => $self->Markup($desc,"")));
#     }
#     print $self->Name."\n";
#   }
# }

1;
