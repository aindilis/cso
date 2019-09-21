#!/usr/bin/perl -w

# this appears to be a system for looking up systems that satisfy
# dependencies

use Manager::Dialog qw (SubsetSelect ApproveCommands);

use Data::Dumper;
use DBI;

my $contentsfile = $ARGV[0];
my %freq;
my $num = 0;
my @results;

my $dbh = DBI->connect
  ("DBI:mysql:database=" .
   "cso".
   ";host=localhost",
   "root", "",
   {
    'RaiseError' => 1});

sub MySQLDo {
  my (%args) = @_;
  my $statement = $args{Statement};
  if ($statement =~ /^select/i) {
    $sth = $dbh->prepare($statement);
    $sth->execute();
    return $sth->fetchall_hashref($args{KeyField});
  } else {
    $dbh->do($statement);
  }
}

GenerateLanguageModel();
ChooseSystemProvidingRequirement();

print Dumper(\@results);
ApproveCommands
  (Commands => ["sudo apt-get install ".join(" ",@results)],
   Method => "parallel");


sub GenerateLanguageModel {
  if (0) {#-e "freq.db") {
    (%freq,$num) = eval `cat freq.db`;
    print "NUM:$num\n";
  } else {
    $results = MySQLDo
      (Statement => "select ID, ShortDesc, LongDesc from systems",
       KeyField => 'ID');
    foreach my $sysname (keys %$results) {
      my $synopsis = ($results->{$sysname}->{ShortDesc} || "").
	($results->{$sysname}->{LongDesc} || "");
      foreach my $word (split /\W+/, $synopsis) {
	if (defined $freq{$word}) {
	  $freq{$word} += 1;
	} else {
	  $freq{$word} = 1;
	}
	++$num;
      }
    }
    my $OUT;
    open(OUT,">freq.db") or die "ouch!";
    print OUT Dumper($num,%freq);
    close(OUT);
  }
}

sub ChooseSystemProvidingRequirement {
  foreach my $line (split /\n/,`cat $contentsfile`) {
    my %score;
    chomp $line;
    my @keywords = split /\W+/, $line;
    foreach my $keyword (@keywords) {
      if (length $keyword > 3) {
	$results = MySQLDo
	  (Statement => "select ID, ShortDesc from systems where ShortDesc like '\%$keyword\%'",
	   KeyField => 'ID');
	foreach my $sysname (keys %$results) {
	  my $result = $results->{$sysname}->{ID}." :: ".$results->{$sysname}->{ShortDesc};
	  if ($freq{$keyword}) {
	    $score{$result} += ($num / $freq{$keyword});
	  }
	}
      }
    }
    my @top = sort {$score{$a} <=> $score{$b}} keys %score;
    #print "\n\n$line\n".Dumper(@keywords).Dumper(reverse map {[$_,$score{$_}]} splice (@top,-10));
    print "\n\n<$line>\n";
    my $set;
    if (@top > 30) {
      $set = [reverse splice (@top,-30)]
    } else {
      $set = [reverse @top];
    }
    foreach my $res (SubsetSelect
		     (Set => $set,
		      Selection => {})) {
      $res =~ s/ - .*//;
      push @results, $res;
    }
  }
}
