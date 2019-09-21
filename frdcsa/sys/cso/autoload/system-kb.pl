relatedSystems([cso,automatedVulnerabilityTesting]).

% ;;;; Index all the independent attempts to develop AI and consort with
% ;;;; their authors, such as this guy
% ;; https://sourceforge.net/projects/ainow/?source=directory
% ;; https://sourceforge.net/u/bbagnall/profile/

% ;; Contact these people, go over all AI related repos, index them in
% ;; our system, track message state.

% ;; https://sourceforge.net/directory/language%3Aprolog/os%3Alinux/?page=8


%% CSO should keep a list of all the software that is implemented in Prolog.


%% have a way to list all known implementations of MOP (metaobject
%% protocol), all available ones, by licensing, etc

addFeatures(cso,'Have the ability to check git, svn etc repos for recent commits to a project to ensure it is being actively worked on.').

addFeatures(cso,'Create index of all git, svn repos etc, queryable from within FCMS/CSO/FLP.').

addFeatures(cso,'look at all of our git repositories, and get the parent directory that they are in, and then look at all the sibling repos to see if there are others that we should acquire').

hasDownloadMethod(cso,mozillaFirefox).
hasDownloadMethod(cso,googleChrome).
hasDownloadMethod(cso,'Download Them All').
hasDownloadMethod(cso,radar).
hasDownloadMethod(cso,radarWebSearch).
hasDownloadMethod(cso,wget).
