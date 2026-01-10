vim9script

import autoload '../autoload/qf.vim'

nnoremap <buffer> o <ScriptCmd>qf.View()<CR>
nnoremap <buffer> t <ScriptCmd>qf.View(true)<CR>
nnoremap <buffer> q <ScriptCmd>wincmd c<CR>
nnoremap <buffer> J <ScriptCmd>qf.Next()<CR>
nnoremap <buffer> K <ScriptCmd>qf.Prev()<CR>
nnoremap <buffer> <Left>  <ScriptCmd>qf.Newer()<CR>
nnoremap <buffer> <Right> <ScriptCmd>qf.Older()<CR>

if getqflist({'title': 1}).title =~# "^:Dispatch"
	nmap <buffer> <C-C> <Cmd>AbortDispatch<CR>
elseif getqflist({'title': 1}).title =~# "^:AsyncRun"
	nmap <buffer> <C-C> <Cmd>AsyncStop<CR>
endif
