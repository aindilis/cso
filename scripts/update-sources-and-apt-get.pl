#!/usr/bin/perl -w

# program  to update  sources, followed  by  an apt-get  update -  but
# monitoring the  output to  get all items  which died,  then removing
# those and running again, kind of thing

# STATUS : UNUSABLE

system "update-sources.pl";

$aptgetstdoutlog = "stdout.log";
$aptgetstderrlog = "stderr.log";

# chroot and all that jazz in your debmade up environment
system "apt-get update > $aptgetstdoutlog 2> $aptgetstderrlog";

ParseIncorrectSources();

system "apt-get update";
