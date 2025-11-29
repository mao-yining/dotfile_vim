vim9script

def Find(how: string = "", path: string = ""): string
    var mods = ""
    if how == "s" && winwidth(winnr()) * 0.3 > winheight(winnr())
        mods = "vert "
    endif
    if empty(path)
        silent g:SetProjectRoot()
    else
        silent g:Lcd(path)
    endif
    return $":{mods}{how}find "
enddef
def Buffer(how: string = ""): string
    var mods = ""
    if how == "s" && winwidth(winnr()) * 0.3 > winheight(winnr())
        mods = "vert "
    endif
    return $":{mods}{how}b "
enddef
nnoremap <expr> <Leader><Leader> Find()
nnoremap <expr> <Leader><LocalLeader> Find("tab")
nnoremap <expr> <LocalLeader><Leader> Find("", expand("%"))
nnoremap <expr> <Leader>b Buffer()
nnoremap <expr> <Leader>t ":AsyncTask "
nnoremap <expr> <Leader>h ":help "
nnoremap <expr> <Leader>r ":Recent "
# nnoremap <expr> <Leader>fp ":Project "
nnoremap <expr> <Leader>ft ":set ft= "
nnoremap <expr> <Leader>fs ":SLoad "
nnoremap <expr> <Leader>fc ":colorscheme "
nnoremap <expr> <Leader>fu ":Unicode "

import autoload 'text.vim'

nnoremap <silent> <Leader><CR> <scriptcmd>text.Toggle()<CR>

# simple text objects
# -------------------
# i_ i. i: i, i; i| i/ i\ i* i+ i- i# i<tab>
# a_ a. a: a, a; a| a/ a\ a* a+ a- a# a<tab>
for char in [ '_', '.', ':', ',', ';', '<bar>', '/', '<bslash>', '*', '+', '-', '#', '<tab>' ]
    execute $"xnoremap <silent> i{char} <esc><scriptcmd>text.Obj('{char}', 1)<CR>"
    execute $"xnoremap <silent> a{char} <esc><scriptcmd>text.Obj('{char}', 0)<CR>"
    execute $"onoremap <silent> i{char} :normal vi{char}<CR>"
    execute $"onoremap <silent> a{char} :normal va{char}<CR>"
endfor

# indent text object
onoremap <silent>ii <scriptcmd>text.ObjIndent(v:true)<CR>
onoremap <silent>ai <scriptcmd>text.ObjIndent(v:false)<CR>
xnoremap <silent>ii <esc><scriptcmd>text.ObjIndent(v:true)<CR>
xnoremap <silent>ai <esc><scriptcmd>text.ObjIndent(v:false)<CR>

xnoremap <silent> in <esc><scriptcmd>text.ObjNumber()<CR>
onoremap <silent> in :<C-u>normal vin<CR>

# date text object
xnoremap <silent> id <esc><scriptcmd>text.ObjDate(1)<CR>
onoremap <silent> id :<C-u>normal vid<CR>
xnoremap <silent> ad <esc><scriptcmd>text.ObjDate(0)<CR>
onoremap <silent> ad :<C-u>normal vad<CR>

# line text object
xnoremap <silent> il <esc><scriptcmd>text.ObjLine(1)<CR>
onoremap <silent> il :<C-u>normal vil<CR>
xnoremap <silent> al <esc><scriptcmd>text.ObjLine(0)<CR>
onoremap <silent> al :<C-u>normal val<CR>

# CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
# so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

nnoremap <Leader># <ScriptCmd>text.Underline('#')<CR>
nnoremap <Leader>* <ScriptCmd>text.Underline('*')<CR>
nnoremap <Leader>= <ScriptCmd>text.Underline('=')<CR>
nnoremap <Leader>- <ScriptCmd>text.Underline('-')<CR>
nnoremap <Leader>~ <ScriptCmd>text.Underline('~')<CR>
nnoremap <Leader>^ <ScriptCmd>text.Underline('^')<CR>
nnoremap <Leader>+ <ScriptCmd>text.Underline('+')<CR>
nnoremap <Leader>" <ScriptCmd>text.Underline('"')<CR>
nnoremap <Leader>` <ScriptCmd>text.Underline('`')<CR>
nnoremap <Leader>. <ScriptCmd>text.Underline('.')<CR>

nnoremap <Leader>% :<C-U>%s/\<<C-r>=expand("<cword>")<CR>\>/
xnoremap <Leader>% "sy:%s/\V<C-R>s/
# literal search
nnoremap <Leader>/ <ScriptCmd>exe $"Search {input("Search: ")}"<CR>

# move lines
xnoremap <M-j> :sil! m '>+1<CR>gv
xnoremap <M-k> :sil! m '<-2<CR>gv

nnoremap <silent><expr> <CR> &buftype ==# "quickfix" ? "\r" : ":\025confirm " .. (&buftype !=# "terminal" ? (v:count ? "write" : "update") : &modified <Bar><Bar> exists("*jobwait") && jobwait([&channel], 0)[0] == -1 ? "normal! i" : "bdelete!") .. "\r"

nmap =b <Cmd>enew<CR>
nmap \b <ScriptCmd>CloseBuf()<CR>
def CloseBuf()
	if &bt != null_string || &ft == "netrw"|bd|return|endif
	var buf_now = bufnr()
	var buf_jump_list = getjumplist()[0]
	var buf_jump_now = getjumplist()[1] - 1
	while buf_jump_now >= 0
		var last_nr = buf_jump_list[buf_jump_now]["bufnr"]
		var last_line = buf_jump_list[buf_jump_now]["lnum"]
		if buf_now != last_nr && bufloaded(last_nr) && getbufvar(last_nr, "&bt") == null_string
			execute ":buffer " .. last_nr
			execute ":bd " .. buf_now
			return
		else
			buf_jump_now -= 1
		endif
	endwhile
	bp|while &bt != null_string|bp|endwhile
	execute "bd " .. buf_now
enddef

# source vimscript (operator)
def SourceVim(...args: list<any>): string
	if len(args) == 0
		&opfunc = matchstr(expand('<stack>'), '[^. ]*\ze[')
		return 'g@'
	endif
	if getline(nextnonblank(1) ?? 1) =~ '^\s*vim9script\s*$'
		vim9cmd :'[,']source
	else
		:'[,']source
	endif
	return ''
enddef
nnoremap <silent> <expr> <Leader>S SourceVim()
xnoremap <silent> <expr> <Leader>S SourceVim()

# change window width
map <C-Up> <C-W>+
map <C-Down> <C-W>-
map <C-Left> <C-W><
map <C-Right> <C-W>>

# change window in normal
nmap <Leader>w <C-w>
noremap <M-H> <C-W>h
noremap <M-L> <C-W>l
noremap <M-J> <C-W>j
noremap <M-K> <C-W>k
inoremap <M-H> <Esc><C-W>h
inoremap <M-L> <Esc><C-W>l
inoremap <M-J> <Esc><C-W>j
inoremap <M-K> <Esc><C-W>k
tnoremap <M-H> <C-W>h
tnoremap <M-L> <C-W>l
tnoremap <M-J> <C-W>j
tnoremap <M-K> <C-W>k
tnoremap <C-S-V> <C-W>"+
tnoremap <C-\> <C-\><C-N>

nmap L gt
nmap H gT
nmap =<Tab> <Cmd>tabnew<CR>

for i in range(10)
	execute($"map <M-{i}> <Cmd> tabn {i == 0 ? 10 : i}<CR>")
endfor

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
map <M-Left> <ScriptCmd>Tab_MoveLeft()<CR>
map <M-Right> <ScriptCmd>Tab_MoveRight()<CR>

# select search / substitute
xmap g/ "sy/<C-R>s
xmap gs "sy:%s/<C-R>s/

omap A <Cmd>normal! ggVG<CR>
xmap A :<C-U>normal! ggVG<CR>
# visual-block
autocmd ModeChanged *:[\x16] xunmap A
autocmd ModeChanged [\x16]:* xmap A :<C-U>normal! ggVG<CR>

# write to a privileged file
if executable('sudo')
		command! W w !sudo tee "%" >/dev/null
endif

nmap U <C-R>
nmap Y y$
map Q @@
sunmap Q
nmap gf gF
nnoremap & :&&<CR>
xnoremap & :&&<CR>

cnoremap <C-A> <Home>
cnoremap <C-B> <Left>
cnoremap <C-D> <Del>
cnoremap <C-E> <End>
cnoremap <C-F> <Right>
cnoremap <C-N> <Down>
cnoremap <C-P> <Up>
cnoremap <C-S-B> <S-Left>
cnoremap <C-S-F> <S-Right>
cnoremap <expr> %% getcmdtype( ) == ':' ? expand('%:h') .. '/' : '%%'

inoremap <CR> <C-G>u<CR>
inoremap <C-U> <C-G>u<C-U>
