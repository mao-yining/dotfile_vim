vim9script

noremap j gj
noremap k gk
inoremap <Up> <C-O>gk
inoremap <Down> <C-O>gj

# vim-buffer {{{
nnoremap <silent>H     <Cmd>call <sid>ChangeBuffer('p')<CR>
nnoremap <silent>L     <Cmd>call <sid>ChangeBuffer('n')<CR>
nnoremap <expr><CR> &bt == "" ? "<Cmd>w<CR>" : &bt == 'terminal' ? "i\<enter>" : getwininfo(win_getid())[0]["quickfix"] != 0 ? "\<CR>:cclose<CR>" : getwininfo(win_getid())[0]["loclist"] != 0 ? "\<CR>:lclose<CR>" : "\<CR>"

# buffer delete {{{
nnoremap <silent>=b <Cmd>enew<CR>
nnoremap <silent>\b <Cmd>call CloseBuf()<CR>
def ChangeBuffer(direct: string)
	if &bt != '' || &ft == 'netrw'|echoerr "buftype is " ..  &bt .. " cannot be change"|return|endif
	if direct == 'n'|bn
	else|bp|endif
	while &bt != ''
		if direct == 'n'|bn
		else|bp|endif
	endwhile
enddef
def g:CloseBuf()
	if &bt != '' || &ft == 'netrw'|bd|return|endif
	var buf_now = bufnr()
	var buf_jump_list = getjumplist()[0]
	var buf_jump_now = getjumplist()[1] - 1
	while buf_jump_now >= 0
		var last_nr = buf_jump_list[buf_jump_now]["bufnr"]
		var last_line = buf_jump_list[buf_jump_now]["lnum"]
		if buf_now != last_nr && bufloaded(last_nr) && getbufvar(last_nr, "&bt") == ''
			execute ":buffer " .. last_nr
			execute ":bd " .. buf_now
			return
		else
			buf_jump_now -= 1
		endif
	endwhile
	bp|while &bt != ''|bp|endwhile
	execute "bd " .. buf_now
enddef
# }}}
# }}}

# reload .vimrc
nnoremap <Leader>S <Cmd>set nossl<CR><Cmd>source $MYVIMRC<CR><Cmd>set ssl<CR>

# 插入移动
inoremap <C-e> <end>
inoremap <C-a> <C-o>^
inoremap <C-d> <del>
vnoremap <C-d> <del>
inoremap <C-f> <C-o>w
inoremap <C-v> <C-o>D

# vimdiff tool
cab <expr>Diff "Diff ".expand('%:p:h')."/"
command! -nargs=1 -bang -complete=file Diff exec ":vert diffsplit ".<q-args>
command! -nargs=0 Remote <Cmd>diffg RE
command! -nargs=0 Base   <Cmd>diffg BA
command! -nargs=0 Local  <Cmd>diffg LO

nnoremap <C-s> <Cmd>w<CR>

# change window width
nnoremap <C-up> <C-w>+
nnoremap <C-down> <C-w>-
nnoremap <C-left> <C-w><
nnoremap <C-right> <C-w>>

# change window in normal
nmap <Leader>w <C-w>
nnoremap <C-k> <C-w>k
nnoremap <C-j> <C-w>j
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l
nnoremap <M-k> <C-w>k
nnoremap <M-j> <C-w>j
nnoremap <M-h> <C-w>h
nnoremap <M-l> <C-w>l

nnoremap <silent><nowait>=q <Cmd>copen<CR>
nnoremap <silent><nowait>\q <Cmd>cclose<CR>
nnoremap <silent><nowait>=l <Cmd>lopen<CR>
nnoremap <silent><nowait>\l <Cmd>lclose<CR>
# show indent line
nnoremap <silent><nowait>=i <Cmd>set list lcs=tab:¦\<Space> <CR>
nnoremap <silent><nowait>\i <Cmd>set nolist<CR>

# set spell
nnoremap <silent><nowait>=s <Cmd>setlocal spell<CR>
nnoremap <silent><nowait>\s <Cmd>setlocal nospell<CR>

# set wrap
nnoremap <silent><nowait>=r <Cmd>setlocal wrap<CR><Cmd>noremap<buffer> j gj<CR><Cmd>noremap<buffer> k gk<CR>
nnoremap <silent><nowait>\r <Cmd>setlocal nowrap<CR><Cmd>unmap<buffer> j<CR><Cmd>unmap<buffer> k<CR>

# set line number
nnoremap <silent><nowait>=n <Cmd>setlocal norelativenumber<CR>
nnoremap <silent><nowait>\n <Cmd>setlocal relativenumber<Bar>setlocal number<CR>

# close/open number
nnoremap <silent><nowait>=N <Cmd>setlocal norelativenumber<CR><Cmd>setlocal nonumber<CR>
nnoremap <silent><nowait>\N <Cmd>setlocal relativenumber<CR><Cmd>setlocal number<CR>

# set fold auto,use zE unset all fold,zf create fold
nnoremap <silent><nowait>=z <Cmd>setlocal fdm=indent<CR><Cmd>setlocal fen<CR>
nnoremap <silent><nowait>\z <Cmd>setlocal fdm=manual<CR><Cmd>setlocal nofen<CR>
nnoremap <silent><nowait>=o zO
nnoremap <silent><nowait>\o zC
nnoremap <silent><nowait><expr><BS> foldlevel('.') > 0 ? "zc" : "\<BS>"

# " tab ctrl
nnoremap <silent><nowait>=<tab> <Cmd>tabnew<CR>
nnoremap <silent><nowait>\<tab> <Cmd>tabc<CR>
nnoremap <silent><nowait>[<tab> <Cmd>tabp<CR>
nnoremap <silent><nowait>]<tab> <Cmd>tabn<CR>

noremap <silent><M-1> <Cmd>tabn 1<CR>
noremap <silent><M-2> <Cmd>tabn 2<CR>
noremap <silent><M-3> <Cmd>tabn 3<CR>
noremap <silent><M-4> <Cmd>tabn 4<CR>
noremap <silent><M-5> <Cmd>tabn 5<CR>
noremap <silent><M-6> <Cmd>tabn 6<CR>
noremap <silent><M-7> <Cmd>tabn 7<CR>
noremap <silent><M-8> <Cmd>tabn 8<CR>
noremap <silent><M-9> <Cmd>tabn 9<CR>
noremap <silent><M-0> <Cmd>tabn 10<CR>
inoremap <silent><M-1> <ESC><Cmd>tabn 1<CR>
inoremap <silent><M-2> <ESC><Cmd>tabn 2<CR>
inoremap <silent><M-3> <ESC><Cmd>tabn 3<CR>
inoremap <silent><M-4> <ESC><Cmd>tabn 4<CR>
inoremap <silent><M-5> <ESC><Cmd>tabn 5<CR>
inoremap <silent><M-6> <ESC><Cmd>tabn 6<CR>
inoremap <silent><M-7> <ESC><Cmd>tabn 7<CR>
inoremap <silent><M-8> <ESC><Cmd>tabn 8<CR>
inoremap <silent><M-9> <ESC><Cmd>tabn 9<CR>
inoremap <silent><M-0> <ESC><Cmd>tabn 10<CR>

def Tab_MoveLeft()
	var tabnr = tabpagenr() - 2
	if tabnr >= 0
		exec 'tabmove ' .. tabnr
	endif
enddef
def Tab_MoveRight()
	var tabnr = tabpagenr() + 1
	if tabnr <= tabpagenr('$')
		exec 'tabmove ' .. tabnr
	endif
enddef
noremap <silent><M-left> <Cmd>call Tab_MoveLeft()<CR>
noremap <silent><M-right> <Cmd>call Tab_MoveRight()<CR>

# set search noh
nnoremap <silent><nowait>\h <Cmd>noh<CR>
nnoremap <silent><nowait>=h <Cmd>set hlsearch<CR>

# delete <Space> in end of line
nnoremap <silent><nowait>d<Space> <Cmd>%s/ *$//g<CR>:noh<CR><C-o>
nnoremap <nowait>g<Space> <Cmd>syntax match DiffDelete # *$"<CR>

# delete empty line
nnoremap <silent><nowait>dl <Cmd>g/^\s*$/d<CR>

# select search / substitute
xmap g/ "sy/<C-R>s
xmap gs "sy:%s/<C-R>s/

# run macro in visual model
xnoremap @ :normal @

# repeat for macro
nnoremap <silent><C-Q> @@

# indent buffer
onoremap <silent>A :<C-U>normal! ggVG<CR>
xnoremap <silent>A :<C-U>normal! ggVG<CR>

# object line
onoremap <silent>il :<C-U>normal! ^v$BE<CR>
xnoremap <silent>il :<C-U>normal! ^v$<CR><Left>
onoremap <silent>al :<C-U>normal! 0v$<CR>
xnoremap <silent>al :<C-U>normal! 0v$<CR>

# sudo to write file
cab w!! w !sudo tee % >/dev/null

# quick to change dir
cab cdn cd <C-R>=expand('%:p:h')<CR>
cab cdr cd <C-R>=FindRoot()<CR>
def g:FindRoot(): string
	var gitdir = finddir(".git", getcwd() .. ';')
	if !empty(gitdir)
		if gitdir == ".git"
			gitdir = getcwd()
		else
			gitdir = strpart(gitdir, 0, strridx(gitdir, "/"))
		endif
		return gitdir
	endif
	return ""
enddef

# enhance gf
nnoremap gf gF
vnoremap gf gF

