Readme
======

Thermometer is a vim plugin for mercurial users.

Available commands are:

* `Hgstatus` to open a quickfix window with changes to the repository
* `Hgreset` to reset status & rev data
* `Hgdiff` to diff the current buffer with its last version on the repository, or with a particular revision if a revision number is provided. Hgdiffoff will close the diff and return to normal mode.
* `Hglog` to show a file's log, or, if no file is being edited, the full log. Can receive an optional parameter to limit the number of commits shown.
* `Hgblame` to show blame information for each line.
* `Hgsummary` to show a summary of the working dir

The plugin also provides functions to be used in statuslines, e.g. in your vimrc:

    set statusline+=%{g:HgStatusLine()}

For more information take a look at the documentation.
