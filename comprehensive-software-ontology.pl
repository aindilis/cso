:- ensure_loaded('/var/lib/myfrdcsa/codebases/minor/free-life-planner/lib/util/util.pl').

:- prolog_consult('/var/lib/myfrdcsa/codebases/internal/cso/data-git/cso-multifile-and-dynamic-directives.pl').
:- prolog_ensure_loaded('/var/lib/myfrdcsa/codebases/internal/myfrdcsa/myfrdcsa-project-loader.pl').

:- load_myfrdcsa1p0_project_prolog_files(cso).
:- load_myfrdcsa1p1_project_prolog_files(cso).


%% %% this might be guessed at based on the inclusion of the name of
%% the system in the paper, and then manually filtered.  Could have
%% something similar, like "mentions System", etc.

%% researchPaperForSoftwareSystem().

:- ensure_loaded('/var/lib/myfrdcsa/codebases/internal/cso/comprehensive-software-ontology/cso.pl').


