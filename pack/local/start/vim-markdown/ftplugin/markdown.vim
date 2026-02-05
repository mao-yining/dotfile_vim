vim9script

import autoload "../autoload/markdown.vim" as md

setl nolinebreak
setl textwidth=74
setl conceallevel=2
setl omnifunc=md.OmniFunc()

noremap <buffer> j gj
noremap <buffer> k gk
noremap <buffer> gj j
noremap <buffer> gk k

inorea <buffer> 》 >
inorea <buffer> 【 [
inorea <buffer> 】 ]
inorea <buffer> no! > [!Note]
inorea <buffer> ti! > [!Tip]
inorea <buffer> im! > [!Important]
inorea <buffer> wa! > [!Warning]
inorea <buffer> ca! > [!Caution]

nnoremap <buffer> gf <ScriptCmd>md.OpenWikiLink()<CR>
onoremap <buffer><silent>if <ScriptCmd>md.ObjCodeFence(true)<CR>
onoremap <buffer><silent>af <ScriptCmd>md.ObjCodeFence(false)<CR>
xnoremap <buffer><silent>if <Esc><ScriptCmd>md.ObjCodeFence(true)<CR>
xnoremap <buffer><silent>af <Esc><ScriptCmd>md.ObjCodeFence(false)<CR>

command! -nargs=? -buffer -complete=custom,md.PandocComplete Pandoc md.Pandoc(<f-args>)
noremap <buffer> <F5> <ScriptCmd>update<Bar>md.Make()<CR>

# This is the dictionary of the form [32]: https://example.com that takes into
# account of all the links that the user place at the bottom of a markdown
# file.
b:markdown_links = md.RefreshLinksDict()

# Check that the values of the dict are valid URL
for link in values(b:markdown_links)
	if !md.IsURL(link)
		md.Echowarn($'"{link}" is not a valid URL.'
			.. ' Run :MDEReleaseNotes to read more')
		sleep 200m
		break
	endif
endfor

# Convert links inline links [mylink](blabla) to referenced links [mylink][3]
command! -buffer -nargs=0 MDEConvertLinks md.ConvertLinks()

# Redefinition of <CR>.
inoremap <buffer><CR> <C-E><ScriptCmd>md.CR_Hacked()<CR>

noremap <buffer> <expr> gx empty(md.IsLink())
			\ ? '<cmd>echo "Invalid URL"<CR>'
			\ : '<ScriptCmd>md.OpenLink()<CR>'

def SetSurroundOpFunc(style: string)
	&l:opfunc = md.SurroundSmart->function([style])
enddef

nnoremap <buffer><LocalLeader>b <ScriptCmd>SetSurroundOpFunc('markdownBold')<CR>g@
xnoremap <buffer><LocalLeader>b <ScriptCmd>SetSurroundOpFunc('markdownBold')<CR>g@

nnoremap <buffer><LocalLeader>i <ScriptCmd>SetSurroundOpFunc('markdownItalic')<CR>g@
xnoremap <buffer><LocalLeader>i <ScriptCmd>SetSurroundOpFunc('markdownItalic')<CR>g@

nnoremap <buffer><LocalLeader>s <ScriptCmd>SetSurroundOpFunc('markdownStrike')<CR>g@
xnoremap <buffer><LocalLeader>s <ScriptCmd>SetSurroundOpFunc('markdownStrike')<CR>g@

nnoremap <buffer><LocalLeader>c <ScriptCmd>SetSurroundOpFunc('markdownCode')<CR>g@
xnoremap <buffer><LocalLeader>c <ScriptCmd>SetSurroundOpFunc('markdownCode')<CR>g@

nnoremap <buffer><LocalLeader>u <ScriptCmd>SetSurroundOpFunc('markdownUnderline')<CR>g@
xnoremap <buffer><LocalLeader>u <ScriptCmd>SetSurroundOpFunc('markdownUnderline')<CR>g@

nnoremap <buffer><LocalLeader>f <ScriptCmd>&l:opfunc = md.SetBlock<CR>g@
xnoremap <buffer><LocalLeader>f <ScriptCmd>&l:opfunc = md.SetBlock<CR>g@

nnoremap <buffer><LocalLeader>q <ScriptCmd>&l:opfunc = md.SetQuoteBlock<CR>g@
xnoremap <buffer><LocalLeader>q <ScriptCmd>&l:opfunc = md.SetQuoteBlock<CR>g@

nnoremap <buffer><C-A> <ScriptCmd>md.ToggleMark()<CR><C-A>

nnoremap <buffer><LocalLeader>d <ScriptCmd>md.RemoveAllStyle()<CR>

nnoremap <buffer><LocalLeader>l <ScriptCmd>&l:opfunc = md.CreateLink<CR>g@
xnoremap <buffer><LocalLeader>l <ScriptCmd>&l:opfunc = md.CreateLink<CR>g@

nnoremap <buffer><LocalLeader>h <ScriptCmd>&l:opfunc = highlights.AddProp<CR>g@
xnoremap <buffer><LocalLeader>h <ScriptCmd>&l:opfunc = highlights.AddProp<CR>g@

nnoremap <buffer><silent> K <ScriptCmd>md.PreviewPopup()<CR>

if exists("g:markdown_fenced_languages")|finish|endif
g:markdown_minlines = 500
g:markdown_syntax_conceal = 1
g:markdown_fenced_languages = [
	"bash=sh", "shell=sh", "sh", "make",
	"asm", "c", "cpp",
	"rust", "go",
	"javascript",
	"yaml", "json", "jsonc", "toml",
	"python", "perl", "vim", "ruby", "lua",
	"tex", "tikz=tex", "typst",
	"git", "gitcommit", "gitrebase", "diff",
	"messages", "log",
	"mermaid",
]
