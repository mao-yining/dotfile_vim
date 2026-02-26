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
inoremap <M-t> <C-o>:InsertTemplate<Space>
nnoremap <M-t> :<C-u>InsertTemplate<Space>

nmap ga <Cmd>Characterize<CR>

# Grep word under cursor
nnoremap <Leader>fw <Cmd>silent execute "grep" expand("<cword>")<CR>
# lvimgrep word in a current buffer
nnoremap <Leader>o <Cmd>execute "Occur" expand("<cword>")<CR>

import autoload 'qc.vim'
# git popup commands
nnoremap <Leader>g <scriptcmd>qc.Git()<CR>
xnoremap <Leader>g <scriptcmd>qc.Git()<CR>
# calc visually selected math expression
# base64 encode/decode
xnoremap <Leader>t <scriptcmd>qc.TextTr()<cr>
nnoremap <Leader>t <scriptcmd>qc.TextTr()<cr>
# quickfix&locations&diff
nnoremap <Leader>n <scriptcmd>qc.Nav()<CR>
# horizontal scroll
nnoremap zl <ScriptCmd>qc.HScroll($'normal! {v:count1}zl')<CR>
nnoremap zh <ScriptCmd>qc.HScroll($'normal! {v:count1}zh')<CR>
nnoremap zs <ScriptCmd>qc.HScroll('normal! zs')<CR>
nnoremap ze <ScriptCmd>qc.HScroll('normal! ze')<CR>
# changelist
nnoremap g; <ScriptCmd>qc.ChangeList('g;')<CR>
nnoremap g, <ScriptCmd>qc.ChangeList('g,')<CR>

import autoload 'text.vim'

nnoremap <silent> <Leader><CR> <ScriptCmd>text.Toggle()<CR>

# simple text objects
# -------------------
# i_ i. i: i, i; i| i/ i\ i* i+ i- i# i<Tab>
# a_ a. a: a, a; a| a/ a\ a* a+ a- a# a<Tab>
for char in [ '_', '.', ':', ',', ';', '<Bar>', '/', '<Bslash>', '*', '+', '-', '#', '<Tab>' ]
	execute $"xnoremap i{char} <Esc><ScriptCmd>text.Obj('{char}', 1)<CR>"
	execute $"xnoremap a{char} <Esc><ScriptCmd>text.Obj('{char}', 0)<CR>"
	execute $"onoremap i{char} <Cmd>normal vi{char}<CR>"
	execute $"onoremap a{char} <Cmd>normal va{char}<CR>"
endfor

# indent text object
omap ii <ScriptCmd>text.ObjIndent(true)<CR>
omap ai <ScriptCmd>text.ObjIndent(false)<CR>
xmap ii <Esc><ScriptCmd>text.ObjIndent(true)<CR>
xmap ai <Esc><ScriptCmd>text.ObjIndent(false)<CR>

xmap in <Esc><ScriptCmd>text.ObjNumber()<CR>
omap in <ScriptCmd>normal vin<CR>

# date text object
xmap id <Esc><ScriptCmd>text.ObjDate(1)<CR>
omap id <ScriptCmd>normal vid<CR>
xmap ad <Esc><ScriptCmd>text.ObjDate(0)<CR>
omap ad <ScriptCmd>normal vad<CR>

# line text object
xmap il <Esc><ScriptCmd>text.ObjLine(1)<CR>
omap il <ScriptCmd>normal vil<CR>
xmap al <Esc><ScriptCmd>text.ObjLine(0)<CR>
omap al <ScriptCmd>normal val<CR>

nmap <expr> [y  text.TransformSetup('string_encode')
xmap <expr> [y  text.TransformSetup('string_encode')
nmap <expr> ]y  text.TransformSetup('string_decode')
xmap <expr> ]y  text.TransformSetup('string_decode')
nmap <expr> [yy text.TransformSetup('string_encode') .. '_'
nmap <expr> ]yy text.TransformSetup('string_decode') .. '_'

nmap <expr> [u  text.TransformSetup('url_encode')
xmap <expr> [u  text.TransformSetup('url_encode')
nmap <expr> ]u  text.TransformSetup('url_decode')
xmap <expr> ]u  text.TransformSetup('url_decode')
nmap <expr> [uu text.TransformSetup('url_encode') .. '_'
nmap <expr> ]uu text.TransformSetup('url_decode') .. '_'

nmap <expr> [x  text.TransformSetup('xml_encode')
xmap <expr> [x  text.TransformSetup('xml_encode')
nmap <expr> ]x  text.TransformSetup('xml_decode')
xmap <expr> ]x  text.TransformSetup('xml_decode')
nmap <expr> [xx text.TransformSetup('xml_encode') .. '_'
nmap <expr> ]xx text.TransformSetup('xml_decode') .. '_'

nmap [p <ScriptCmd>text.PutLine('[p')<CR>
nmap ]p <ScriptCmd>text.PutLine(']p')<CR>
nmap [P <ScriptCmd>text.PutLine('[p')<CR>
nmap ]P <ScriptCmd>text.PutLine(']p')<CR>
nmap >P <ScriptCmd>text.PutLine(v:count1 .. '[p')<CR>>']
nmap >p <ScriptCmd>text.PutLine(v:count1 .. ']p')<CR>>']
nmap <P <ScriptCmd>text.PutLine(v:count1 .. '[p')<CR><']
nmap <p <ScriptCmd>text.PutLine(v:count1 .. ']p')<CR><']
nmap =P <ScriptCmd>text.PutLine(v:count1 .. '[p')<CR>=']
nmap =p <ScriptCmd>text.PutLine(v:count1 .. ']p')<CR>=']

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
xmap <silent><M-k> :sil! m '<-2<CR>gv
xmap <silent><M-j> :sil! m '>+1<CR>gv

nmap <CR> <Cmd>update<CR>

nmap =b <Cmd>enew<CR>
nmap \b <Cmd>bdelete<CR>

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

import autoload 'window.vim'
nnoremap <C-w>o <ScriptCmd>window.ToggleZoom()<CR>

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
	autocmd ModeChanged *:[\x16] xmap { <ScriptCmd>VisualBlockPara("{")<CR>
	autocmd ModeChanged *:[\x16] xmap } <ScriptCmd>VisualBlockPara("}")<CR>
	autocmd ModeChanged [\x16]:* xunmap {
		autocmd ModeChanged [\x16]:* xunmap }
augroup end
omap A <Cmd>normal! ggVG<CR>
xmap A :<C-U>normal! ggVG<CR>

nmap U <C-R>
nmap Y y$
nmap Q @@
xmap Q @@
nmap & :&&<CR>
xmap & :&&<CR>

imap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\t"
imap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\t"

map <F12> <Cmd>Calendar<CR>

nmap [a <Cmd>exe "previous" (v:count ? v:count : "")<CR>zv
nmap ]a <Cmd>exe "next" (v:count ? v:count : "")<CR>zv
nmap [A <Cmd>exe v:count ? v:count .. "argument" : "first"<CR>zv
nmap ]A <Cmd>exe v:count ? v:count .. "argument" : "last"<CR>zv

nmap [b <Cmd>exe "bprevious" (v:count ? v:count : "")<CR>zv
nmap ]b <Cmd>exe "bnext" (v:count ? v:count : "")<CR>zv
nmap [B <Cmd>exe v:count ? v:count .. "bfirst" : "bfirst"<CR>zv
nmap ]B <Cmd>exe v:count ? v:count .. "blast" : "blast"<CR>zv

nmap [l <Cmd>exe "lprevious" (v:count ? v:count : "")<CR>zv
nmap ]l <Cmd>exe "lnext" (v:count ? v:count : "")<CR>zv
nmap [L <Cmd>exe v:count ? v:count .. "ll" : "lfirst"<CR>zv
nmap ]L <Cmd>exe v:count ? v:count .. "ll" : "llast"<CR>zv

nmap [q <Cmd>exe "cprevious" (v:count ? v:count : "")<CR>zv
nmap ]q <Cmd>exe "cnext" (v:count ? v:count : "")<CR>zv
nmap [Q <Cmd>exe v:count ? v:count .. "cc" : "cfirst"<CR>zv
nmap ]Q <Cmd>exe v:count ? v:count .. "cc" : "clast"<CR>zv

nmap [t <Cmd>exe "tprevious" (v:count ? v:count : "")<CR>
nmap ]t <Cmd>exe "tnext" (v:count ? v:count : "")<CR>
nmap [T <Cmd>exe v:count ? v:count .. "trewind" : "trewind"<CR>
nmap ]T <Cmd>exe v:count ? v:count .. "tlast" : "tlast"<CR>

nmap [<C-L> <Cmd>exe "lpfile" (v:count ? v:count : "")<CR>
nmap ]<C-L> <Cmd>exe "lnfile" (v:count ? v:count : "")<CR>
nmap [<C-Q> <Cmd>exe "cpfile" (v:count ? v:count : "")<CR>
nmap ]<C-Q> <Cmd>exe "cnfile" (v:count ? v:count : "")<CR>

nmap [<C-T> <Cmd>exe v:count1 .. "ptprevious"<CR>
nmap ]<C-T> <Cmd>exe v:count1 .. "ptnext"<CR>

nmap [<Space> <Cmd>put!=nr2char(10)->repeat(v:count1)<Bar>']+<CR>
nmap ]<Space> <Cmd>put =nr2char(10)->repeat(v:count1)<Bar>']-<CR>

var colorcolumn: string
def ColorColumn()
	if !empty(&colorcolumn)
		colorcolumn = &colorcolumn
	endif
	&colorcolumn = empty(&colorcolumn) ?  colorcolumn : ''
enddef
nmap yot <ScriptCmd>ColorColumn()<CR>
nmap yob <Cmd>let &background = &background == "dark" ? "light" : "dark"<CR>
nmap yod <Cmd>exe (&diff ? "diffoff" : "diffthis")<CR>
nmap yoh <Cmd>set hlsearch! hlsearch?<CR>
nmap yoi <Cmd>set ignorecase! ignorecase?<CR>
nmap yol <Cmd>setl list! list?<CR>
nmap yon <Cmd>set number! number?<CR>
nmap yoo <Cmd>setl cursorline! cursorline?<CR>
nmap yor <Cmd>setl relativenumber! relativenumber?<CR>
nmap yos <Cmd>setl spell! spell?<CR>
nmap you <Cmd>setl cursorcolumn! cursorcolumn?<CR>
nmap yov <Cmd>let &ve = &ve =~# "all" ? "block,onemore" : "all"<Bar>set ve<CR>
nmap yow <Cmd>set wrap! wrap?<CR>
nmap yox <Cmd>exe "set" &cul && &cuc ? "nocuc culopt-=line" : "cul cuc culopt+=line"<CR>

import autoload 'diff.vim'
nmap ]n <ScriptCmd>diff.NextChange()<CR>
nmap [n <ScriptCmd>diff.PrevChange()<CR>
xmap ]n <ScriptCmd>diff.NextChange()<CR>
xmap [n <ScriptCmd>diff.PrevChange()<CR>

import autoload 'docs.vim'
nnoremap go <nop>
# go to journal file
nnoremap goj <ScriptCmd>docs.Journal()<CR>
# go to todo file
nnoremap got <ScriptCmd>docs.EditInTab(docs.root .. "todo.md")<CR>
# go to work too file
nnoremap gon <Cmd>Note<CR>

import autoload 'os.vim'
# go to current file in as file manager
nnoremap gof <ScriptCmd>os.FileManager()<CR>

# open URLs
nnoremap gx <ScriptCmd>os.Gx()<CR>
