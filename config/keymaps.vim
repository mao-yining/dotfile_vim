vim9script

noremap j gj
noremap k gk
inoremap <up> <c-o>gk
inoremap <down> <c-o>gj

# vim-buffer {{{
nnoremap <silent>H     <cmd>call <sid>ChangeBuffer('p')<cr>
nnoremap <silent>L     <cmd>call <sid>ChangeBuffer('n')<cr>
nnoremap <expr><cr> &bt == "" ? "<cmd>w<cr>" : &bt == 'terminal' ? "i\<enter>" : getwininfo(win_getid())[0]["quickfix"] != 0 ? "\<cr>:cclose<cr>" : getwininfo(win_getid())[0]["loclist"] != 0 ? "\<cr>:lclose<cr>" : "\<cr>"

# buffer delete {{{
nnoremap <silent>=b <cmd>enew<cr>
nnoremap <silent>\b <cmd>call CloseBuf()<cr>
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
nnoremap <leader>S <cmd>set nossl<cr><cmd>source $MYVIMRC<cr><cmd>set ssl<cr>

# 插入移动
inoremap <c-e> <end>
inoremap <c-a> <c-o>^
inoremap <c-d> <del>
vnoremap <c-d> <del>
inoremap <c-f> <c-o>w
inoremap <c-v> <c-o>D

# vimdiff tool
cab <expr>Diff "Diff ".expand('%:p:h')."/"
command! -nargs=1 -bang -complete=file Diff exec ":vert diffsplit ".<q-args>
command! -nargs=0 Remote <cmd>diffg RE
command! -nargs=0 Base   <cmd>diffg BA
command! -nargs=0 Local  <cmd>diffg LO

nnoremap <c-s> <cmd>w<cr>

# change window width
nnoremap <c-up> <c-w>+
nnoremap <c-down> <c-w>-
nnoremap <c-left> <c-w><
nnoremap <c-right> <c-w>>

# change window in normal
nmap <leader>w <c-w>
nnoremap <c-k> <c-w>k
nnoremap <c-j> <c-w>j
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l
nnoremap <m-k> <c-w>k
nnoremap <m-j> <c-w>j
nnoremap <m-h> <c-w>h
nnoremap <m-l> <c-w>l

nnoremap <silent><nowait>=q <cmd>copen<cr>
nnoremap <silent><nowait>\q <cmd>cclose<cr>
nnoremap <silent><nowait>=l <cmd>lopen<cr>
nnoremap <silent><nowait>\l <cmd>lclose<cr>
# show indent line
nnoremap <silent><nowait>=i <cmd>set list lcs=tab:¦\<space> <cr>
nnoremap <silent><nowait>\i <cmd>set nolist<cr>

# set spell
nnoremap <silent><nowait>=s <cmd>setlocal spell<cr>
nnoremap <silent><nowait>\s <cmd>setlocal nospell<cr>
# z= is list of change

# set wrap
nnoremap <silent><nowait>=r <cmd>setlocal wrap<cr><cmd>noremap<buffer> j gj<cr><cmd>noremap<buffer> k gk<cr>
nnoremap <silent><nowait>\r <cmd>setlocal nowrap<cr><cmd>unmap<buffer> j<cr><cmd>unmap<buffer> k<cr>

# set line number
nnoremap <silent><nowait>=n <cmd>setlocal norelativenumber<cr>
nnoremap <silent><nowait>\n <cmd>setlocal relativenumber<bar>setlocal number<cr>

# close/open number
nnoremap <silent><nowait>=N <cmd>setlocal norelativenumber<cr><cmd>setlocal nonumber<cr>:set nolist<cr>
nnoremap <silent><nowait>\N <cmd>setlocal relativenumber<cr><cmd>setlocal number<cr>:set list lcs=tab:¦\<space> <cr>

# set fold auto,use zE unset all fold,zf create fold
nnoremap <silent><nowait>=z <cmd>setlocal fdm=indent<cr><cmd>setlocal fen<cr>
nnoremap <silent><nowait>\z <cmd>setlocal fdm=manual<cr><cmd>setlocal nofen<cr>
nnoremap <silent><nowait>=o zO
nnoremap <silent><nowait>\o zC
nnoremap <silent><nowait><expr><bs> foldlevel('.')>0?"zc":"\<bs>"

# " tab ctrl
nnoremap <silent><nowait>=<tab> <cmd>tabnew<cr>
nnoremap <silent><nowait>\<tab> <cmd>tabc<cr>
nnoremap <silent><nowait>[<tab> <cmd>tabp<cr>
nnoremap <silent><nowait>]<tab> <cmd>tabn<cr>

noremap <silent><m-1> <cmd>tabn 1<cr>
noremap <silent><m-2> <cmd>tabn 2<cr>
noremap <silent><m-3> <cmd>tabn 3<cr>
noremap <silent><m-4> <cmd>tabn 4<cr>
noremap <silent><m-5> <cmd>tabn 5<cr>
noremap <silent><m-6> <cmd>tabn 6<cr>
noremap <silent><m-7> <cmd>tabn 7<cr>
noremap <silent><m-8> <cmd>tabn 8<cr>
noremap <silent><m-9> <cmd>tabn 9<cr>
noremap <silent><m-0> <cmd>tabn 10<cr>
inoremap <silent><m-1> <ESC><cmd>tabn 1<cr>
inoremap <silent><m-2> <ESC><cmd>tabn 2<cr>
inoremap <silent><m-3> <ESC><cmd>tabn 3<cr>
inoremap <silent><m-4> <ESC><cmd>tabn 4<cr>
inoremap <silent><m-5> <ESC><cmd>tabn 5<cr>
inoremap <silent><m-6> <ESC><cmd>tabn 6<cr>
inoremap <silent><m-7> <ESC><cmd>tabn 7<cr>
inoremap <silent><m-8> <ESC><cmd>tabn 8<cr>
inoremap <silent><m-9> <ESC><cmd>tabn 9<cr>
inoremap <silent><m-0> <ESC><cmd>tabn 10<cr>

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
noremap <silent><m-left> <cmd>call Tab_MoveLeft()<cr>
noremap <silent><m-right> <cmd>call Tab_MoveRight()<cr>

# set search noh
nnoremap <silent><nowait>\h <cmd>noh<cr>
nnoremap <silent><nowait>=h <cmd>set hlsearch<cr>

# delete <space> in end of line
nnoremap <silent><nowait>d<space> <cmd>%s/ *$//g<cr>:noh<cr><c-o>
nnoremap <nowait>g<space> <cmd>syntax match DiffDelete # *$"<cr>

# delete empty line
nnoremap <silent><nowait>dl <cmd>g/^\s*$/d<cr>

# select search / substitute
xmap g/ "sy/\V<c-r>=@s<cr>
xmap gs y:%s/<c-r>0/

# run macro in visual model
xnoremap @ :normal @

# repeat for macro
nnoremap <silent><c-q> @@

# indent buffer
onoremap <silent>ae :<c-u>normal! ggVG<cr>
xnoremap <silent>ae :<c-u>normal! ggVG<cr>

# object line
onoremap <silent>il :<c-u>normal! ^v$BE<cr>
xnoremap <silent>il :<c-u>normal! ^v$<cr><left>
onoremap <silent>al :<c-u>normal! 0v$<cr>
xnoremap <silent>al :<c-u>normal! 0v$<cr>

# sudo to write file
cab w!! w !sudo tee % >/dev/null

# quick to change dir
cab cdn cd <c-r>=expand('%:p:h')<cr>
cab cdr cd <c-r>=FindRoot()<cr>
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
