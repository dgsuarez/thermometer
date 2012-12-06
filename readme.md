Readme
======

Thermometer is a vim plugin for mercurial users.

Available commands are:

* `Hgst` to open a quickfix window with changes to the repository
* `Hgstreload` to reset status data used in statusline function
* `Hgdiff` to diff the current buffer with its last version on the repository, or with a particular revision if a revision number is provided. Hgdiffoff will close the diff and return to normal mode.
* `Hglog` to show a file's log, or, if no file is being edited the full log. Can receive an optional parameter to limit the number of commits shown.
* `Hgblame` to show blame information for each line.

The plugin also provides the function `g:HgStatusForFile()` to be used in statuslines, e.g. in your vimrc:

    set statusline+=%{g:HgStatusLine()}
