package CSO::System;

use Manager::Dialog qw(Message);
use PerlLib::Collection;

use Data::Dumper;

# base class for any source software system we are interested in

# Package Priority Section Installed-Size Maintainer Architecture
# Source Version Depends Filename Size MD5sum Description Tag

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw { ID Name FullName ShortDesc LongDesc Tags Dependencies Categories Capabilities URL Source }

  ];

sub init {
  my ($self,%args) = (shift,@_);
  $self->Name($args{Name});
  $self->FullName($args{FullName});
  $self->ShortDesc($args{ShortDesc});
  $self->LongDesc($args{LongDesc});
  $self->Tags($args{Tags});
  $self->Dependencies($args{Dependencies});
  $self->Categories($args{Categories});
  $self->Capabilities($args{Capabilities});
  $self->URL($args{URL});
  $self->Source($args{Source});
  $self->ID($self->Source.": ".$self->Name);
}

sub Matches {
  my ($self,%args) = (shift,@_);
  if ($args{Criteria}->{Any}) {
    foreach my $key (qw(Name ShortDesc LongDesc)) {
      if ($self->$key) {
	if ($self->$key =~ /$args{Criteria}->{Any}/) {
	  return 1;
	}
      }
    }
  } else {
    foreach my $key (keys %{$args{Criteria}}) {
      if ($self->$key) {
	if ($self->$key =~ /$args{Criteria}->{$key}/) {
	  return 1;
	}
      }
    }
  }
}

sub SPrint {
  my ($self,%args) = (shift,@_);
  # return sprintf ("%s - %s",$self->ID,$self->ShortDesc || "");
  my $short = $self->ShortDesc;
  $short =~ s/[\n\r]/ /g;
  return sprintf
    ("%-12s : %-30s - %-60s",
     substr($self->Source,0,10),
     substr($self->Name,0,30),
     $short || "");
}

sub SPrintFull {
  my ($self,%args) = (shift,@_);
  return "Name: ".($self->Name || "")."\n".
    "FullName: ".($self->FullName || "")."\n".
      "ShortDesc: ".($self->ShortDesc || "")."\n".
	"LongDesc: ".($self->LongDesc || "")."\n".
	  "URL: ".($self->URL || "")."\n".
	    "Source: ".($self->Source || "")."\n";
}

1;
