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

   qw { ID Name FullName ShortDesc LongDesc Tags Dependencies Categories URL Source }

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
  $self->URL($args{URL});
  $self->Source($args{Source});
  $self->ID($self->Source.": ".$self->Name);
}

sub SPrint {
  my ($self,%args) = (shift,@_);
  return sprintf ("%s - %s",$self->ID,$self->ShortDesc || "");
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
