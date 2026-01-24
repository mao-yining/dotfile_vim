vim9script

import autoload '../autoload/qf.vim'
set quickfixtextfunc=qf.QuickFixText

nmap <Home> <ScriptCmd>qf.Prev()<CR>
nmap <End>  <ScriptCmd>qf.Next()<CR>
nmap <leader>q <ScriptCmd>qf.ToggleQF()<CR>
nmap <leader>l <ScriptCmd>qf.ToggleLocationList()<CR>

const quickfix_cmd_pattern = [ 'make', 'grep', 'grepadd', 'vimgrep',
	'vimgrepadd', 'cfile', 'cgetfile', 'caddfile', 'cexpr', 'cgetexpr',
	'caddexpr', 'cbuffer', 'cgetbuffer', 'caddbuffer' ]->join(',')

const loc_list_cmd_pattern = [ 'lfile', 'lgetfile', 'laddfile', 'lexpr',
	'lgetexpr', 'laddexpr', 'lbuffer', 'lgetbuffer', 'laddbuffer' ]->join(',')

augroup qf
	autocmd!

	# automatically open the location/quickfix window after :make, :grep,
	# :lvimgrep and friends if there are valid locations/errors
	execute($'autocmd QuickFixCmdPost {quickfix_cmd_pattern} copen')
	execute($'autocmd QuickFixCmdPost {loc_list_cmd_pattern} lopen')

	if has("win32") && $LANG == "zh_CN"
		autocmd QuickfixCmdPost make getqflist()->foreach((_, l: dict<any>) => l.text->iconv("cp936", "utf-8"))->setqflist()
	endif

	# special case for :helpgrep and :lhelpgrep since the help window may not
	# be opened yet when QuickFixCmdPost triggers
	if exists('*timer_start')
		autocmd QuickFixCmdPost  helpgrep ++nested timer_start(10, (_) => execute("copen"))
		autocmd QuickFixCmdPost lhelpgrep ++nested timer_start(10, (_) => execute("lopen"))
	else
		autocmd QuickFixCmdPost helpgrep ++nested copen
	endif

	# special case for $ vim -q
	autocmd VimEnter * ++nested if count(v:argv, '-q') | copen | endif

	autocmd QuitPre * ++nested if &filetype != 'qf' | silent! lclose | endif
augroup END

