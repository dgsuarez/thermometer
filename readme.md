Readme
======

Thermometer is a vim plugin for mercurial users. Right now is in alpha state.
Available commands are:

* Hgst to open a quickfix window with changes to the repository
* Hgstreload to reset status data used in statusline function
* Hgdiff to diff the current buffer with its last version on the repository, or with a particular revision if a revision number is provided 
* Hglog to show the repository's log, can receive an optional parameter to limit the number of revisions shown

Also there is g:HgStatusForFile() to be used in statuslines
