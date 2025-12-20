if has("gui_running")
	finish
endif

" Open modifyOtherKeys
let &t_TI = "\<Esc>[>4;2m"
let &t_TE = "\<Esc>[>4;m"

" cursor
let &t_EI = "\e[2 q"
let &t_SI = "\e[5 q"
let &t_SR = "\e[3 q"

set <M-H>=H
set <M-J>=J
set <M-K>=K
set <M-L>=L

if empty($TMUX)
	noremap <M-H> <scriptcmd>wincmd h<CR>
	noremap <M-J> <scriptcmd>wincmd j<CR>
	noremap <M-K> <scriptcmd>wincmd k<CR>
	noremap <M-L> <scriptcmd>wincmd l<CR>
	inoremap <M-H> <scriptcmd>wincmd h<CR>
	inoremap <M-J> <scriptcmd>wincmd j<CR>
	inoremap <M-K> <scriptcmd>wincmd k<CR>
	inoremap <M-L> <scriptcmd>wincmd l<CR>
	tnoremap <M-H> <scriptcmd>wincmd h<CR>
	tnoremap <M-J> <scriptcmd>wincmd j<CR>
	tnoremap <M-K> <scriptcmd>wincmd k<CR>
	tnoremap <M-L> <scriptcmd>wincmd l<CR>
endif
