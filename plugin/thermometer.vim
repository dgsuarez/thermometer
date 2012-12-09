" Vim global plugin for working with mercurial
" Author: Diego Guerra <https://github.com/dgsuarez>
" License: www.opensource.org/licenses/bsd-license.php

if exists("loaded_thermometer")
  finish
endif
let loaded_thermometer = 1

function s:Hgst()
  let res = system('hg st')
  let old_efm = &errorformat
  set errorformat=%m\ %f
  execute "silent! lgetexpr res" 
  let &errorformat = old_efm
  botright lopen
endfunction

function s:HgSetupCaches()
  if exists("s:cachesSet")
    return
  endif
  let s:cachesSet = 1
  let s:hgstatuses = {}
  autocmd BufWritePost          * call s:HgResetCaches()
  autocmd FileChangedShellPost  * call s:HgResetCaches()
endfunction

function s:HgGetStatusForFile()
  let status = system('hg st ' . bufname('%'))
  if v:shell_error != 0
    return -1
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
  if ! has_key(s:hgstatuses, bufname('%'))
    let s:hgstatuses[ bufname('%') ] = s:HgGetStatusForFile()
  endif
  return s:hgstatuses[ bufname('%') ]
endfunction

function s:HgResetCaches()
  unlet s:hgworkinginfo
  let s:hgstatuses = {}
endfunction

function s:GetHgRevInfo()
  if ! exists('g:HgRevInfoTemplate')
    let g:HgRevInfoTemplate = "({branch})"
  endif
  if g:HgRevInfoTemplate == ""
    return ""
  endif
  let revinfo = system('hg log -r . --template "' . g:HgRevInfoTemplate .  '"')
  if v:shell_error != 0
    return -1
  endif
  return revinfo
endfunction

function g:HgRevInfo()
  if ! exists('s:hgworkinginfo')
    let s:hgworkinginfo = s:GetHgRevInfo()
  endif
  return s:hgworkinginfo
endfunction

function g:HgStatusLine()
  let status = g:HgStatusForFile()
  let rev_info = g:HgRevInfo()
  if status == -1 || rev_info == -1
    return ""
  endif
  if status == ""
    return "[Hg ". rev_info ."]"
  endif
  return "[Hg " . status . " " . rev_info . "]"
endfunction

function s:HgDiff(...)
  if !exists("s:orig_diffs")
    let s:orig_diffs = {}
    let s:tmp_diffs = {}
    let s:tmp_diffs_names = {}
  endif
  let tmpfile = tempname() . "." . (split(bufname("%"), '\.')[-1])  
  let current_file = bufname('%')
  let current_file_nr = bufnr('%')
  let order = "hg cat"
  let order = a:0 > 0 ? (order . " -r " . a:1) : order
  let order = order . " " . current_file
  exe "redir! > " . tmpfile
  silent echon system(order)
  redir END
  execute "vert diffsplit " . tmpfile

  let tmpfile_nr = bufnr('%')
  let s:orig_diffs[current_file_nr] = tmpfile_nr
  let s:tmp_diffs[tmpfile_nr]       = current_file_nr
  let s:tmp_diffs_names[tmpfile_nr] = tmpfile
endfunction

function s:HgDiffoffBuffer()
  if !exists("s:orig_diffs")
    return
  endif
  let current = bufnr('%')
  if has_key(s:orig_diffs, current)
    let diff = s:orig_diffs[current]
    call s:HgDiffOff(current, diff)
  endif
  if has_key(s:tmp_diffs, current)
    let real = s:tmp_diffs[current]
    call s:HgDiffOff(real, current)
  endif
endfunction

function s:HgDiffOff(real, diff)
  execute 'bwipeout ' . a:diff
  execute 'buffer ' . a:real
  execute "diffoff"
  call remove(s:orig_diffs, a:real)
  call remove(s:tmp_diffs, a:diff)
  call delete(s:tmp_diffs_names[a:diff])

endfunction

function s:RunInSplit(order)
  let current_file = bufname('%')
  if bufname("%") != ""
    execute "new"
  endif
  setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap
  execute "0read !" . a:order
  setlocal nomodifiable
  execute "normal! gg<CR>"
endfunction

function s:HgLog(...)
  let current_file = bufname('%')
  let order = "hg log " . current_file
  let order = a:0 > 0 ? (order . " -l " . a:1) : order
  call s:RunInSplit(order)
endfunction

function s:HgBlame(l1, ...)
  let order = "hg blame -u -n -d -q"
  let order = a:0 > 0 ? (order . " -r " . a:1) : order
  let order = order . " " . bufname('%')
  call s:RunInSplit(order)
  execute ":" . a:l1
endfunction

function s:HgSummary(...)
  let order = "hg summary --remote"
  call s:RunInSplit(order)
endfunction

call s:HgSetupCaches()
command! -nargs=0 Hgst call s:Hgst()
command! -nargs=0 Hgstreload call s:HgResetCaches()
command! -nargs=0 Hgreset call s:HgResetCaches()
command! -nargs=? Hgdiff call s:HgDiff(<f-args>)
command! -nargs=0 Hgdiffoff call s:HgDiffoffBuffer(<f-args>)
command! -nargs=? Hglog call s:HgLog(<f-args>)
command! -nargs=? -range=% Hgblame call s:HgBlame(<line1>, <f-args>)
command! -nargs=0 Hgsummary call s:HgSummary()

