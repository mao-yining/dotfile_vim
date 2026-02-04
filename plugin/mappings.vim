vim9script

def Find(how = null_string, path = null_string): string
	var mods: string
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
nnoremap <expr> <Leader>ft ":set filetype="
nnoremap <expr> <Leader>fs ":SLoad "
nnoremap <expr> <Leader>fc ":colorscheme "
nnoremap <expr> <Leader>fu ":Unicode "
inoremap <C-T> <C-O>:InsertTemplate<space>

# Grep word under cursor
nnoremap <Leader>fw <ScriptCmd>silent execute "grep" expand("<cword>")<CR>
# lvimgrep word in a current buffer
nnoremap <Leader>o <ScriptCmd>execute "Occur" expand("<cword>")<CR>

import autoload 'text.vim'

nnoremap <silent> <Leader><CR> <ScriptCmd>text.Toggle()<CR>

# simple text objects
# -------------------
# i_ i. i: i, i; i| i/ i\ i* i+ i- i# i<Tab>
# a_ a. a: a, a; a| a/ a\ a* a+ a- a# a<Tab>
for char in [ '_', '.', ':', ',', ';', '<Bar>', '/', '<Bslash>', '*', '+', '-', '#', '<Tab>' ]
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

xnoremap <silent> in <Esc><ScriptCmd>text.ObjNumber()<CR>
onoremap <silent> in :<C-u>normal vin<CR>

# date text object
xnoremap <silent> id <Esc><ScriptCmd>text.ObjDate(1)<CR>
onoremap <silent> id :<C-u>normal vid<CR>
xnoremap <silent> ad <Esc><ScriptCmd>text.ObjDate(0)<CR>
onoremap <silent> ad :<C-u>normal vad<CR>

# line text object
xnoremap <silent> il <Esc><ScriptCmd>text.ObjLine(1)<CR>
onoremap <silent> il :<C-u>normal vil<CR>
xnoremap <silent> al <Esc><ScriptCmd>text.ObjLine(0)<CR>
onoremap <silent> al :<C-u>normal val<CR>

# CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
# so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>
inoremap <CR> <C-G>u<CR>

nnoremap <Leader>% :%s/\<<C-R>=expand("<cword>")<CR>\>/<C-R>=expand("<cword>")<CR>
xnoremap <Leader>% y:%s/\V<C-R>"/<C-R>"
# literal search
nnoremap <Leader>/ <ScriptCmd>exe $"Search {input("Search: ")}"<CR>
xnoremap <Leader>/ y/\V<C-R>"<CR>

import autoload 'substitute.vim'

nmap s <ScriptCmd>substitute.SetOperatorFunc(false)<CR>g@
nmap ss <ScriptCmd>substitute.Line()<CR>
nmap S <ScriptCmd>substitute.ToEndOfLine()<CR>
xmap s <Esc>`<<ScriptCmd>substitute.SetOperatorFunc(true)<CR>g@`>

# move lines
xnoremap <M-j> :sil! m '>+1<CR>gv
xnoremap <M-k> :sil! m '<-2<CR>gv

nnoremap <silent><expr> <CR> &buftype ==# "quickfix" ? "\r" : ":\025confirm " .. (&buftype !=# "terminal" ? (v:count ? "write" : "update") : &modified <Bar><Bar> exists("*jobwait") && jobwait([&channel], 0)[0] == -1 ? "normal! i" : "bdelete!") .. "\r"

nmap =b <Cmd>enew<CR>
nmap \b <Cmd>Bdelete<CR>

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
inoremap <M-H> <Esc><Cmd>wincmd h<CR>
inoremap <M-J> <Esc><Cmd>wincmd j<CR>
inoremap <M-K> <Esc><Cmd>wincmd k<CR>
inoremap <M-L> <Esc><Cmd>wincmd l<CR>
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
	const tabnr = tabpagenr() - 2
	if tabnr >= 0
		exe 'tabmove' tabnr
	endif
enddef
def Tab_MoveRight()
	const tabnr = tabpagenr() + 1
	if tabnr <= tabpagenr('$')
		exe 'tabmove' tabnr
	endif
enddef
map <M-Left> <ScriptCmd>Tab_MoveLeft()<CR>
map <M-Right> <ScriptCmd>Tab_MoveRight()<CR>

# visual-block
def VisualBlockPara(cmd: string)
	var target_row = getpos($"'{cmd}")[1]
	if getline(target_row) =~ "^\s*$"
		target_row += (cmd == "{" ? 1 : -1)
		if target_row == line('.')
			target_row = (cmd == "{" ? prevnonblank(target_row - 1)
				: nextnonblank(target_row + 1))
		endif
	endif
	if target_row > 0
		exe $":{target_row}"
	endif
enddef
augroup visual-block | au!
	autocmd ModeChanged [\x16]:* xmap A :<C-U>normal! ggVG<CR>
	autocmd ModeChanged *:[\x16] xunmap A
	autocmd ModeChanged *:[\x16] xnoremap { <ScriptCmd>VisualBlockPara("{")<CR>
	autocmd ModeChanged *:[\x16] xnoremap } <ScriptCmd>VisualBlockPara("}")<CR>
	autocmd ModeChanged [\x16]:* xunmap {
	autocmd ModeChanged [\x16]:* xunmap }
augroup end
omap A <Cmd>normal! ggVG<CR>
xmap A :<C-U>normal! ggVG<CR>

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

inoremap <silent><expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <silent><expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
