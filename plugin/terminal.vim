vim9script

import autoload 'terminal.vim'

command! -nargs=? Term terminal.Run(<q-args> ?? &shell, <q-mods> ?? window#BotRight())

def TermMappings()
	setlocal nonumber
	setlocal norelativenumber
	nnoremap <buffer> q <Cmd>bdelete<CR>
	nnoremap <buffer> o <ScriptCmd>terminal.OpenError(true)<CR>
	if expand("<amatch>") =~# "^!rg "
		nnoremap <buffer> <CR> <ScriptCmd>terminal.OpenError()<CR>
	endif
	nmap <buffer> <2-LeftMouse> o
	nnoremap <buffer> J <ScriptCmd>terminal.NextError()<CR>
	nnoremap <buffer> K <ScriptCmd>terminal.PrevError()<CR>
	nnoremap <buffer> <C-R> <ScriptCmd>terminal.ReRun()<CR>
	nnoremap <buffer> <F5> <ScriptCmd>terminal.ReRun()<CR>
enddef

augroup Terminal
	au!
	au TerminalWinOpen * TermMappings()
	au TerminalOpen * ++nested exe $"au BufWinEnter {expand("<afile>")->escape('#%[ ')} ++once TermMappings()"
augroup END
