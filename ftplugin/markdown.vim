vim9script noclear

setlocal nolinebreak
setlocal textwidth=74

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

iab 》 >
iab 【 [
iab 】 ]

inorea <buffer> no! > [!Note]
inorea <buffer> ti! > [!Tip]
inorea <buffer> im! > [!Important]
inorea <buffer> wa! > [!Warning]
inorea <buffer> ca! > [!Caution]

var input_flags = ['commonmark_x',
	'+wikilinks_title_after_pipe',
	'+east_asian_line_breaks',
]

var target = 'pdf'

var args = [
	'%:S',
	'-f',
	join(input_flags, ''),
	$"-t {target}",
	$"-o %:.:s?\.md?\.{target}?:s?notes?build?:S",
	'--metadata title=%:t:r:S',
	'-s',
	'--wrap=auto',
	'--pdf-engine=lualatex',
	'--pdf-engine-opt=--shell-escape',
	'-V documentclass=ctexart',
]

&l:makeprg = $"pandoc {args->join(' ')}"
&l:conceallevel = 2

setl keywordprg=:LspHover
if exists("g:loaded_lsp")
	import autoload '../autoload/lsp.vim'
	augroup LspSetup
		au!
		au User LspAttached lsp.SetupMaps()
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
