noremap j gj
noremap k gk
nnoremap <esc> <cmd>nohlsearch<cr><esc>

" vim-buffer {{{
nnoremap <silent>H     <cmd>call <sid>ChangeBuffer('p')<cr>
nnoremap <silent>L     <cmd>call <sid>ChangeBuffer('n')<cr>
nnoremap <silent><expr><c-m> &bt==''?":w<cr>":&bt=='terminal'?"i\<enter>":
			\ getwininfo(win_getid())[0]["quickfix"]!=0?"\<cr>:cclose<cr>":
			\ getwininfo(win_getid())[0]["loclist"]!=0?"\<cr>:lclose<cr>":"\<cr>"

" buffer delete {{{
nnoremap <silent><leader>bd <cmd>call <sid>CloseBuf()<cr>
func! s:ChangeBuffer(direct) abort
	if &bt!=''||&ft=='netrw'|echoerr "buftype is ".&bt." cannot be change"|return|endif
	if a:direct=='n'|bn
	else|bp|endif
	while &bt!=''
		if a:direct=='n'|bn
		else|bp|endif
	endwhile
endfunc
func! s:CloseBuf()
	if &bt!=''||&ft=='netrw'|bd|return|endif
	let buf_now=bufnr()
	let buf_jump_list=getjumplist()[0]|let buf_jump_now=getjumplist()[1]-1
	while buf_jump_now>=0
		let last_nr=buf_jump_list[buf_jump_now]["bufnr"]
		let last_line=buf_jump_list[buf_jump_now]["lnum"]
		if buf_now!=last_nr&&bufloaded(last_nr)&&getbufvar(last_nr,"&bt")==''
			execute ":buffer ".last_nr|execute ":bd ".buf_now|return
		else|let buf_jump_now-=1
		endif
	endwhile
	bp|while &bt!=''|bp|endwhile
	execute "bd ".buf_now
endfunc
" }}}
" }}}

" reload .vimrc
" nnoremap <leader>S <cmd>source $MYVIMRC<cr>

" 插入模式下的光标移动
imap <c-j> <down>
imap <c-k> <up>
imap <c-l> <right>
imap <c-h> <left>

" 插入移动
inoremap <c-e> <end>
inoremap <c-a> <c-o>^
inoremap <c-d> <del>
vnoremap <c-d> <del>
inoremap <c-f> <c-o>w
inoremap <c-v> <c-o>D
inoremap <expr><c-b> <sid>CtrlB()
func! s:CtrlB()
	if pumvisible()|return "\<c-n>"
	elseif getline('.')[col('.')-2]==nr2char(9)
		let s:pos=col('.')|let s:result=""
		while s:pos!=0|let s:result=s:result."\<bs>"|let s:pos-=1|endwhile
		return s:result
	else
		return "\<c-o>b"
	endif
endfunc

" load the file last edit pos
let g:map_recent_close={}
func! s:GetRecentClose()
	let s:list=[]
	for [key,value] in items(g:map_recent_close)
		let value['filename']=key
		call insert(s:list,value)
	endfor
	let s:func={m1,m2 -> m1['time']>m2['time']?-1:1}
	call sort(s:list,s:func)
	call setqflist(s:list,'r')
	copen
endfunc
nnoremap <silent><nowait><space>q <cmd>call <sid>GetRecentClose()<cr>

" term console
tnoremap <c-\> <c-\><c-n>
tnoremap <m-H> <c-_>h
tnoremap <m-L> <c-_>l
tnoremap <m-J> <c-_>j
tnoremap <m-K> <c-_>k

" vimdiff tool
cab <expr>Diff "Diff ".expand('%:p:h')."/"
command! -nargs=1 -bang -complete=file Diff exec ":vert diffsplit ".<q-args>
command! -nargs=0 Remote <cmd>diffg RE
command! -nargs=0 Base   <cmd>diffg BA
command! -nargs=0 Local  <cmd>diffg LO

nnoremap <c-s> <cmd>w<cr>

" change window width
nnoremap <c-up> <c-w>+
nnoremap <c-down> <c-w>-
nnoremap <c-left> <c-w><
nnoremap <c-right> <c-w>>

" change window in normal
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
" show indent line
nnoremap <silent><nowait>=i <cmd>set list lcs=tab:¦\<space> <cr>
nnoremap <silent><nowait>\i <cmd>set nolist<cr>

" set spell
nnoremap <silent><nowait>=s <cmd>setlocal spell<cr>
nnoremap <silent><nowait>\s <cmd>setlocal nospell<cr>
" z= is list of change

" set wrap
nnoremap <silent><nowait>=r <cmd>setlocal wrap<cr><cmd>noremap<buffer> j gj<cr><cmd>noremap<buffer> k gk<cr>
nnoremap <silent><nowait>\r <cmd>setlocal nowrap<cr><cmd>unmap<buffer> j<cr><cmd>unmap<buffer> k<cr>

" set line number
nnoremap <silent><nowait>=n <cmd>setlocal norelativenumber<cr>
nnoremap <silent><nowait>\n <cmd>setlocal relativenumber<bar>setlocal number<cr>

" close/open number
nnoremap <silent><nowait>=N <cmd>setlocal norelativenumber<cr><cmd>setlocal nonumber<cr>:set nolist<cr>
nnoremap <silent><nowait>\N <cmd>setlocal relativenumber<cr><cmd>setlocal number<cr>:set list lcs=tab:¦\<space> <cr>

" set fold auto,use zE unset all fold,zf create fold
nnoremap <silent><nowait>=z <cmd>setlocal fdm=indent<cr><cmd>setlocal fen<cr>
nnoremap <silent><nowait>\z <cmd>setlocal fdm=manual<cr><cmd>setlocal nofen<cr>
nnoremap <silent><nowait>=o zO
nnoremap <silent><nowait>\o zC
nnoremap <silent><nowait><expr><bs> foldlevel('.')>0?"zc":"\<bs>"

" " tab ctrl
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

" 左移 tab
function! Tab_MoveLeft()
	let l:tabnr = tabpagenr() - 2
	if l:tabnr >= 0
		exec 'tabmove '.l:tabnr
	endif
endfunc

" 右移 tab
function! Tab_MoveRight()
	let l:tabnr = tabpagenr() + 1
	if l:tabnr <= tabpagenr('$')
		exec 'tabmove '.l:tabnr
	endif
endfunc

noremap <silent><m-left> :call Tab_MoveLeft()<cr>
noremap <silent><m-right> :call Tab_MoveRight()<cr>

" set search noh
nnoremap <silent><nowait>\h <cmd>noh<cr>
nnoremap <silent><nowait>=h <cmd>set hlsearch<cr>


" delete <space> in end of line
nnoremap <silent><nowait>d<space> <cmd>%s/ *$//g<cr>:noh<cr><c-o>
nnoremap <nowait>g<space> <cmd>syntax match DiffDelete " *$"<cr>

" delete empty line
nnoremap <silent><nowait>dl <cmd>g/^\s*$/d<cr>

" select search
xmap g/ "sy/\V<c-r>=@s<cr>

" run macro in visual model
xnoremap @ :normal @

" repeat for macro
nnoremap <silent><c-q> @@

" use select area to replace
xnoremap s  :<c-u>execute "normal! gv\"sy"<cr>:%s/\V<c-r>=@s<cr>/<c-r>=@s<cr>/gn<left><left><left>
nnoremap gs :%s/<c-r>=@/<cr>//gn<left><left><left>
xnoremap gs :<c-u>execute "normal! gv\"sy"<cr>:call <sid>ReplaceGlobal(@s)<cr>
func s:ReplaceGlobal(str) abort
	let escape_char='.'
	let str=escape(a:str,escape_char)|let replace=escape(input("replace ".a:str." to:"),escape_char)
	if replace==""|return|endif
	let sed='sed'|if has('macunix')|let sed='gsed'|endif
	echo system('find . -path "./.git" -prune -o -type f -exec '.sed.' -i "s|'.a:str.'|'.replace.'|g" {} +')
	" reload file
	exec ":edit ".expand('%')
endfunc

" textobj {{{
" indent buffer
nnoremap <silent><nowait> =e gg=G
onoremap <silent>ae :<c-u>normal! ggVG<cr>
xnoremap <silent>ae :<c-u>normal! ggVG<cr>

" object line
onoremap <silent>il :<c-u>normal! ^v$BE<cr>
xnoremap <silent>il :<c-u>normal! ^v$<cr><left>
onoremap <silent>al :<c-u>normal! 0v$<cr>
xnoremap <silent>al :<c-u>normal! 0v$<cr>

" object argc
onoremap <silent>aa :<c-u>call <sid>GetArgs('a')<cr>
onoremap <silent>ia :<c-u>call <sid>GetArgs('i')<cr>
xnoremap <silent>aa :<c-u>call <sid>GetArgs('a')<cr>
xnoremap <silent>ia :<c-u>call <sid>GetArgs('i')<cr>
func! s:GetArgs(model)
	let model=a:model
	let line=line('.')|let col=col('.')|let i=col-1|let now=getline('.')
	let begin=-1|let end=-1|let pos0=-1|let pos1=-1
	let buket=0|let flag=0
	while i>0
		let temp=now[i]|let flag=0
		if temp==')'|let buket+=1|endif
		if temp=='('|let buket-=1|let flag=1|endif
		if (buket>0)||(buket==0&&flag)|let i-=1|continue|endif
		if temp=='('|| temp==','|let begin=temp|let pos0=i|break|endif
		let i-=1
	endwhile
	let i=col|let buket=0|let flag=0
	while i<col('$')
		let temp=now[i]|let flag=0
		if temp=='('|let buket+=1|endif
		if temp==')'|let buket-=1|let flag=1|endif
		if (buket>0)||(buket==0&&flag)|let i+=1|continue|endif
		if temp==')'|| temp==','|let end=temp|let pos1=i|break|endif
		let i+=1
	endwhile
	if model=='i'
		let pos0+=1|let pos1-=1
	else
		if begin=='('|let pos0+=1|else|let pos1-=1|endif
	endif
	call cursor([line,pos0+1])
	let pos1-=pos0|echom end
	execute "normal! v".pos1."l"
endfunc
" }}}

" sudo to write file
cab w!! w !sudo tee % >/dev/null

" quick to change dir
cab cdn cd <c-r>=expand('%:p:h')<cr>
cab cdr cd <c-r>=<sid>FindRoot()<cr>
func! s:FindRoot()
	let s:gitdir = finddir(".git", getcwd() .';')
	if !empty(s:gitdir)
		if s:gitdir==".git"|let s:gitdir=getcwd()
		else|let s:gitdir=strpart(s:gitdir,0,strridx(s:gitdir,"/"))
		endif
		return s:gitdir
	endif
	return ""
endfunc

" cmd emacs model
cnoremap <c-a> <home>
cnoremap <c-e> <end>
cnoremap <c-d> <del>
cnoremap <c-h> <left>
cnoremap <c-l> <right>
cnoremap <c-b> <s-left>
cnoremap <c-f> <s-right>

" set cursor middle
nnoremap <c-o> <c-o>zz
nnoremap <c-i> <c-i>zz

" " set tab next snippet
" smap <tab>   <c-j>
" smap <s-tab> <c-k>

" enhance gf
nnoremap gf gF
vnoremap gf gF

" select move
xnoremap <silent><up>    <cmd>move '<-2<cr>gv
xnoremap <silent><down>  <cmd>move '>+1<cr>gv
xnoremap <silent><right> y<c-w>lo<c-[>Vpgv
xnoremap <silent><left>  y<c-w>ho<c-[>Vpgv
xnoremap <silent><c-j>   <cmd>move '>+1<cr>gv
xnoremap <silent><c-k>   <cmd>move '<-2<cr>gv
xnoremap <silent><c-l>   y<c-w>lo<c-[>Vpgv
xnoremap <silent><c-h>   y<c-w>ho<c-[>Vpgv
" slash {{{
func! s:SlashCb()
	if g:slash_able
		set nohlsearch|autocmd! slash
	else
		set hlsearch|let g:slash_able=1
	endif
endf
func! s:Slash(oper)
	augroup slash
		autocmd!
		autocmd CursorMoved,CursorMovedI * call <sid>SlashCb()
	augroup END
	let g:slash_able=0
	return a:oper."zz"
endf
" }}}
nnoremap <silent><expr>n <sid>Slash('n')
nnoremap <silent><expr>N <sid>Slash('N')

