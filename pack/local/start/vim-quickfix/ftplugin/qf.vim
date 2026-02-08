vim9script

if get(b:, "did_ftplugin", false)
  finish
endif
b:did_ftplugin = true

setl nowrap
setl norelativenumber
setl number
setl nobuflisted

if exists("b:undo_ftplugin")
    b:undo_ftplugin ..= "| setl wrap< rnu< nu< bl<"
else
    b:undo_ftplugin = "setl wrap< rnu< nu< bl<"
endif

import autoload '../autoload/qf.vim'

nnoremap <buffer> o <ScriptCmd>qf.View()<CR>
nnoremap <buffer> t <ScriptCmd>qf.View(true)<CR>
nnoremap <buffer> q <ScriptCmd>wincmd c<CR>
nnoremap <buffer> J <ScriptCmd>qf.Next()<CR>
nnoremap <buffer> K <ScriptCmd>qf.Prev()<CR>
nnoremap <buffer> <Left>  <ScriptCmd>qf.Older()<CR>
nnoremap <buffer> <Right> <ScriptCmd>qf.Newer()<CR>
b:undo_ftplugin ..= "| execute 'nunmap <buffer> o'"
	.. "| execute 'nunmap <buffer> t'"
	.. "| execute 'nunmap <buffer> q'"
	.. "| execute 'nunmap <buffer> J'"
	.. "| execute 'nunmap <buffer> K'"
	.. "| execute 'nunmap <buffer> <Left>'"
	.. "| execute 'nunmap <buffer> <Right>'"

const title = getqflist({'title': 1}).title
if title =~# "^:Dispatch"
	nmap <buffer> <C-C> <Cmd>AbortDispatch<CR>
	b:undo_ftplugin ..= "| execute 'nunmap <buffer> <C-C>'"
elseif title =~# "^:AsyncRun"
	nmap <buffer> <C-C> <Cmd>AsyncStop<CR>
	b:undo_ftplugin ..= "| execute 'nunmap <buffer> <C-C>'"
endif
