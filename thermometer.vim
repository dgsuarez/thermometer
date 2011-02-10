" Vim global plugin for working with mercurial
" Author: Diego Guerra <https://github.com/dgsuarez>
" License: www.opensource.org/licenses/bsd-license.php

if exists("loaded_thermometer")
  finish
endif
let loaded_thermometer = 1

function s:Hgst()
  let tmpfile = tempname()
  exe "redir! > " . tmpfile
  silent echon system('hg st')
  redir END
  let old_efm = &errorformat
  set errorformat=%m\ %f
  execute "silent! cfile " . tmpfile
  let errorformat = old_efm
  botright copen
  call delete(tmpfile)
endfunction

command! -nargs=0 Hgst call s:Hgst()
