vim9script

compiler md2pdf
noremap <buffer> <F5> <ScriptCmd>update<Bar>Make()<CR>

def Make()
	popup_menu(getcompletion("md2", "compiler"), {
		pos: "center",
		title: "使用哪个编译器？",
		borderchars: get(g:, "popup_borderchars", ['─', '│', '─', '│', '┌', '┐', '┘', '└']),
		borderhighlight: get(g:, "popup_borderhighlight", ['Normal']),
		highlight: get(g:, "popup_highlight", 'Normal'),
		callback: (id, result) => {
			if result == -1 | return | endif
			execute "compiler" getwininfo(id)[0].bufnr->getbufoneline(result)
			silent :Make
		}})
enddef

setl nolinebreak
setl textwidth=74
setl conceallevel=2

noremap j gj
noremap k gk
noremap gj j
noremap gk k

def AddFormat(mark: string): string
	return $"c{mark}\<C-R>\"{mark}\<Esc>"
enddef

# 创建可视模式映射
xnoremap <expr> <LocalLeader>b AddFormat("**")
xnoremap <expr> <LocalLeader>i AddFormat("*")
xnoremap <expr> <LocalLeader>m AddFormat("$")
xnoremap <expr> <LocalLeader>s AddFormat("~~")
xnoremap <expr> <LocalLeader>c AddFormat("`")
xnoremap <expr> <LocalLeader>q AddFormat("`")

inorea <buffer> 》 >
inorea <buffer> 【 [
inorea <buffer> 】 ]
inorea <buffer> no! > [!Note]
inorea <buffer> ti! > [!Tip]
inorea <buffer> im! > [!Important]
inorea <buffer> wa! > [!Warning]
inorea <buffer> ca! > [!Caution]

import autoload "../autoload/markdown.vim" as md
nnoremap <buffer> gf <ScriptCmd>md.OpenWikiLink()<CR>

if exists("g:loaded_lsp")
	import autoload '../autoload/lsp.vim'
	augroup LspSetup
		au!
		au User LspAttached {
			lsp.SetupMaps()
			setl keywordprg=:LspHover
		}
	augroup END
endif

if exists("g:markdown_fenced_languages")|finish|endif

g:markdown_minlines = 500
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
