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

function s:HgSetupStatus()
  if exists("s:statusSet")
    return
  endif
  let s:statusSet = 1
  autocmd BufWritePost          * call s:HgResetStatusForFiles()
  autocmd FileChangedShellPost  * call s:HgResetStatusForFiles()
endfunction

function s:HgGetStatusForFile()
  call s:HgSetupStatus()
  let status = system('hg st ' . bufname('%'))
  if v:shell_error != 0
    return "-"
  endif
  if (strlen(status) == 0)
    return ""
  endif
  return strpart(status, 0, 1)
endfunction

function g:HgStatusForFile()
  if strlen(bufname('%')) == 0
    return ""
  endif
  if ! exists('s:hgstatuses')
    let s:hgstatuses = {}
  endif
  if ! has_key(s:hgstatuses, bufname('%'))
    let s:hgstatuses[ bufname('%') ] = s:HgGetStatusForFile()
  endif
  return s:hgstatuses[ bufname('%') ]
endfunction

function s:HgResetStatusForFiles()
  let s:hgstatuses = {}
endfunction


function s:HgDiff(...)
  let tmpfile = tempname() . "." . (split(bufname("%"), '\.')[-1])  
  let order = "hg cat"
  let order = a:0 > 0 ? (order . " -r " . a:1) : order
  let order = order . " " . bufname('%')
  exe "redir! > " . tmpfile
  silent echon system(order)
  redir END
  execute "vert diffsplit " . tmpfile
  call delete(tmpfile)
endfunction

command! -nargs=0 Hgst call s:Hgst()
command! -nargs=0 Hgstreload call s:HgResetStatusForFiles()
command! -nargs=? Hgdiff call s:HgDiff(<f-args>)

