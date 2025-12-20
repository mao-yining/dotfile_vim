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
nnoremap <expr> <Leader><Leader> Find()
nnoremap <expr> <Leader><LocalLeader> Find("tab")
nnoremap <expr> <LocalLeader><Leader> Find("", expand("%"))
nnoremap <expr> <Leader>b ":buffer "
nnoremap <expr> <Leader>t ":AsyncTask "
nnoremap <expr> <Leader>h ":help "
nnoremap <expr> <Leader>r ":Recent "
nnoremap <expr> <Leader>fm ":compiler "
nnoremap <expr> <Leader>ft ":set ft="
nnoremap <expr> <Leader>fs ":SLoad "
nnoremap <expr> <Leader>fc ":colorscheme "
nnoremap <expr> <Leader>fu ":Unicode "

# Grep word under cursor
if has("win32")
	nnoremap <Leader>fw <ScriptCmd>exe $'Rg \b{expand("<cword>")}\b -C {v:count}'<CR>
else
	nnoremap <Leader>fw <ScriptCmd>exe $'Rg \\b{expand("<cword>")}\\b -C {v:count}'<CR>
endif
# lvimgrep word in a current buffer
nnoremap <Leader>o <ScriptCmd>exe $'Occur {expand("<cword>")}'<CR>

import autoload 'text.vim'

nnoremap <silent> <Leader><CR> <scriptcmd>text.Toggle()<CR>

# simple text objects
# -------------------
# i_ i. i: i, i; i| i/ i\ i* i+ i- i# i<tab>
# a_ a. a: a, a; a| a/ a\ a* a+ a- a# a<tab>
for char in [ '_', '.', ':', ',', ';', '<bar>', '/', '<bslash>', '*', '+', '-', '#', '<tab>' ]
	execute $"xnoremap <silent> i{char} <Esc><ScriptCmd>text.Obj('{char}', 1)<CR>"
	execute $"xnoremap <silent> a{char} <Esc><ScriptCmd>text.Obj('{char}', 0)<CR>"
	execute $"onoremap <silent> i{char} :normal vi{char}<CR>"
	execute $"onoremap <silent> a{char} :normal va{char}<CR>"
endfor

# indent text object
onoremap <silent>ii <ScriptCmd>text.ObjIndent(true)<CR>
onoremap <silent>ai <ScriptCmd>text.ObjIndent(false)<CR>
xnoremap <silent>ii <Esc><ScriptCmd>text.ObjIndent(true)<CR>
xnoremap <silent>ai <Esc><ScriptCmd>text.ObjIndent(false)<CR>

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

inoremap <CR> <C-G>u<CR>
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
xnoremap <Leader>/ y/\V<C-R>"<CR>


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
		const last_nr = buf_jump_list[buf_jump_now].bufnr
		const last_line = buf_jump_list[buf_jump_now].lnum
		if buf_now != last_nr && bufloaded(last_nr)
				&& getbufvar(last_nr, "&bt") == null_string
			exe "buffer" last_nr
			exe "bd" buf_now
			return
		else
			buf_jump_now -= 1
		endif
	endwhile
	bp|while &bt != null_string|bp|endwhile
	exe "bd" buf_now
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
nnoremap <silent><expr> <Leader>S SourceVim()
xnoremap <silent><expr> <Leader>S SourceVim()

# change window width
map <C-Up> <C-W>+
map <C-Down> <C-W>-
map <C-Left> <C-W><
map <C-Right> <C-W>>

# change window in normal
nmap <Leader>w <C-W>
set termwinkey=<C-_>
noremap <M-H> <Cmd>wincmd h<CR>
noremap <M-J> <Cmd>wincmd j<CR>
noremap <M-K> <Cmd>wincmd k<CR>
noremap <M-L> <Cmd>wincmd l<CR>
inoremap <M-H> <Cmd>wincmd h<CR>
inoremap <M-J> <Cmd>wincmd j<CR>
inoremap <M-K> <Cmd>wincmd k<CR>
inoremap <M-L> <Cmd>wincmd l<CR>
tnoremap <M-H> <Cmd>wincmd h<CR>
tnoremap <M-J> <Cmd>wincmd j<CR>
tnoremap <M-K> <Cmd>wincmd k<CR>
tnoremap <M-L> <Cmd>wincmd l<CR>

tnoremap <C-S-V> <C-_>"+
tnoremap <C-\> <C-\><C-N>

nmap L gt
nmap H gT
nmap =<Tab> <Cmd>tabnew<CR>
nmap \<Tab> <Cmd>tabclose<CR>

for i in range(10)
	execute($"map <M-{i}> <Cmd>tabn {i == 0 ? 10 : i}<CR>")
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

omap A <Cmd>normal! ggVG<CR>
xmap A :<C-U>normal! ggVG<CR>
# visual-block
augroup mappings | au!
	autocmd ModeChanged *:[\x16] xunmap A
	autocmd ModeChanged [\x16]:* xmap A :<C-U>normal! ggVG<CR>
augroup end

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
