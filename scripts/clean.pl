#!/usr/bin/perl -w

my $it =<<EOF;
datamart_sf_datasources.2008-Jul.sql.bz2
datamart_sf_forges.2008-Jul.sql.bz2
datamart_deb.2008-Aug.sql.bz2
datamart_sf_stats.2009-Jun.sql.bz2
datamart_top_datasources.2009-Jul.sql.bz2
datamart_top_forges.2009-Jul.sql.bz2
datamart_sf_other.2009-Dec.sql.bz2
datamart_lp.2010-Jun.sql.bz2
datamart_tg.2011-Mar.sql.bz2
datamart_al.2011-Nov.sql.bz2
datamart_fm_projects.2012-May.sql.bz2
datamart_fm_other.2012-May.sql.bz2
datamart_fm_project_trove.2012-May.sql.bz2
datamart_fm_trove_defs.2012-May.sql.bz2
datamart_fm_project_tags.2012-May.sql.bz2
datamart_lpd.2012-May.sql.bz2
datamart_gh.2012-Jul.sql.bz2
datamart_gc.2012-Jul.sql.bz2
datamart_ow_structure.2012-Aug.sql.bz2
datamart_ow.2012-Aug.sql.bz2
datamart_al_projects.2012-Aug.sql.bz2
datamart_al_structure.2012-Aug.sql.bz2
datamart_rf_structure.2012-Aug.sql.bz2
datamart_rf.2012-Aug.sql.bz2
datamart_fsf_structure.2012-Aug.sql.bz2
datamart_fsf.2012-Aug.sql.bz2
datamart_sv_structure.2012-Aug.sql.bz2
datamart_sv.2012-Aug.sql.bz2
datamart_tig_structure.2012-Aug.sql.bz2
datamart_tig.2012-Aug.sql.bz2
datamart_fc_structure.2012-Aug.sql.bz2
datamart_fc_projects.2012-Aug.sql.bz2
datamart_fc_other.2012-Aug.sql.bz2
datamart_fc_project_trove.2012-Aug.sql.bz2
datamart_fc_project_tags.2012-Aug.sql.bz2
datamart_ow_structure.2012-Sep.sql.bz2
datamart_ow.2012-Sep.sql.bz2
datamart_tig_structure.2012-Sep.sql.bz2
datamart_tig.2012-Sep.sql.bz2
datamart_al_projects.2012-Sep.sql.bz2
datamart_al_structure.2012-Sep.sql.bz2
datamart_fc_structure.2012-Sep.sql.bz2
datamart_fc_projects.2012-Sep.sql.bz2
datamart_fc_other.2012-Sep.sql.bz2
datamart_fc_project_trove.2012-Sep.sql.bz2
datamart_fc_project_tags.2012-Sep.sql.bz2
datamart_fsf_structure.2012-Sep.sql.bz2
datamart_fsf.2012-Sep.sql.bz2
datamart_sv_structure.2012-Sep.sql.bz2
datamart_sv.2012-Sep.sql.bz2
datamart_rf_structure.2012-Sep.sql.bz2
datamart_rf.2012-Sep.sql.bz2
EOF

my $matches = {};
foreach my $line (split /\n/, $it) {
  $matches->{$line} = 1;
  # print "\t$line\n";
}

foreach my $file (split /\n/, `ls -1 /var/lib/myfrdcsa/codebases/data/cso/flossmole/datamarts/`) {
  if (! exists $matches->{$file}) {
    print "$file\n";
  }
}
