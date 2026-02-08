vim9script
if exists('b:load_ftp')
	finish
endif
import autoload "../autoload/markdown.vim" as md
setl include=\[\[\\s\]\]
setl define=^#\ \\s*
setl nolinebreak
setl textwidth=74
setl conceallevel=2
# def OmniFunc(findstart: number, base: string): any # TODO
# 	if findstart == 1
# 		const line = getline('.')
# 		var idx = col('.')
# 		while idx > 0
# 			idx -= 1
# 			const c = line->strpart(idx, 2)
# 			if c == '[['
# 				idx += 2
# 				break
# 			endif
# 		endwhile
# 		echo line[idx] .. idx .. line
# 		return idx
# 	endif
# 	return taglist('^' .. base)->filter((_, v) => v.kind != 'c')
# 		->map((_, v) => {
# 			return {word: v->get('name'), kind: v->get('kind')}
# 		})
# enddef
# setl omnifunc=OmniFunc
noremap <buffer> k gk
noremap <buffer> j gj
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
# b:markdown_links = md.RefreshLinksDict()

# # Check that the values of the dict are valid URL
# for link in values(b:markdown_links)
# 	if !md.IsURL(link)
# 		md.Echowarn($'"{link}" is not a valid URL.')
# 		sleep 200m
# 		break
# 	endif
# endfor

# Convert links inline links [mylink](blabla) to referenced links [mylink][3]
command! -buffer -nargs=0 ConvertLinks md.ConvertLinks()

inoremap <buffer><silent><CR> <C-O>:call markdown#CR_Hacked()<CR>

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

nnoremap <buffer><M-x> <Plug>(CheckboxToggle)
xnoremap <buffer><M-X> <Plug>(CheckboxToggle)

nnoremap <buffer><LocalLeader>d <ScriptCmd>md.RemoveAllStyle()<CR>

nnoremap <buffer><LocalLeader>l <ScriptCmd>&l:opfunc = md.CreateLink<CR>g@
xnoremap <buffer><LocalLeader>l <ScriptCmd>&l:opfunc = md.CreateLink<CR>g@

nnoremap <buffer><silent> K <ScriptCmd>md.PreviewPopup()<CR>

b:load_ftp = 1
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
