hasVideo(grammaticalFramework,'https://www.youtube.com/watch?v=x1LFbDQhbso').
hasCapability(owlExporter,ontologyPopulationFromText).
%% get all the gate plugins

% % http://www.semanticsoftware.info/semantic-assistants-architecture
% % http://www.semanticsoftware.info/semantic-assistants#Download
% % http://www.semanticsoftware.info/multipax
% % http://www.semanticsoftware.info/zeeva

%% http://www.semanticsoftware.info/owlexporter

%% http://www.semanticsoftware.info/rhetector

%% http://www.semanticsoftware.info/lodtagger

%% from('http://sirius.clarity-lab.org/','Sirius has been renamed to Lucida. The new project page is at www.lucida.ai.').

%% sourceOfSoftware('http://mklab.iti.gr/').

%% sourceOfSoftware('http://www.lt4el.eu/index.php?content=tools').

%% acronym('EHCPRs','Extended Hierarchical Censored Production Rule (framework)').

isProprietary(mizarProofChecker).
isOpenSource(mizarMathematicalLibrary).

are(['Studies in Logic, Grammar and Rhetoric','Intelligent Computer Mathematics','Interactive Theorem Proving','Journal of Automated Reasoning','Journal of Formalized Reasoning'],'peer-reviewed journals of the mathematic formalization academic community').

%% Formalization is relatively labor-intensive, but not impossibly
%% difficult. Once one is versed in the system, it takes about one
%% week of full-time work to have a textbook page formally verified.

isa(knowledgeBaseConstruction,softwareCapability).
hasCapability(deepDive,knowledgeBaseConstruction).

%% forall(SoftwareSystem,implies(hasCapability(SoftwareSystem,knowledgeBaseConstruction),desires(andrewDougherty,packagedFor(SoftwareSystem,debianGnuLinux)))).

desiresCapability(prologQuery(authorsOfSoftwareSystem(deepdive,Authors))).

task(deploy(deepdive,docker)).

softwareMetasite(codePlex).
%% hasUrl(codePlex,'https://codeplex.com').
softwareMetasite(librariesDotIo).
hasUrl(librariesDotIo,urlFn('https://libraries.io')).

%% desires(frdcsaProject,obtain(frdcsaProject,System)) :-
%%	softwareMetasite(Metasite),
%%	mentions(Metasite,System),
%%	isa(System,softwareSystem).

hasAcronym(semanticRoleLabeling,srl).

hasCapability([swirl,illinoisSemanticRoleLabeler,shalmaneser,assert,senna,mateTools,semafor,curator,lth],semanticRoleLabeling).

softwareMetasiteURL('http://www.kenvanharen.com/2012/11/comparison-of-semantic-role-labelers.html').

isa(authorOfWebsiteFn(urlFn('https://www.blogger.com/profile/05988298721002241103')),possibleFRDCSACollaborator).

softwareMetasiteURL('http://www.cs.miami.edu/~tptp/CASC/J8/Entrants.html').
softwareMetasiteURL('https://en.wikipedia.org/wiki/Constraint_programming').
softwareMetasiteURL('http://icaps-conference.org/ipc2008/deterministic/Planners.html').
softwareMetasiteURL('http://wiki.opensemanticframework.org/index.php/Ontology_Tools').
softwareMetasiteURL('http://users.cecs.anu.edu.au/~ssanner/IPPC_2011').

hasCapability(ltsmin,modelCheckingFor('ctl*')).
hasCapability(arc,modelCheckingFor('ctl*')).

isa(cudd,aiSoftware).
hasRelatedWebsite(cudd,'http://vlsi.colorado.edu/~fabio/').

hasExtractionTemplate('<SYSTEM> is a <DESCRIPTION>').
hasExtractionTemplate('<SYSTEM> is written in <DESCRIPTION>').
