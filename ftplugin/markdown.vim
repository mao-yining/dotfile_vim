vim9script

compiler md2pdf

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

import autoload "../import/markdown.vim" as md

nnoremap <buffer> gf <ScriptCmd>md.OpenWikiLink()<CR>

onoremap <buffer><silent>if <ScriptCmd>md.ObjCodeFence(true)<CR>
onoremap <buffer><silent>af <ScriptCmd>md.ObjCodeFence(false)<CR>
xnoremap <buffer><silent>if <Esc><ScriptCmd>md.ObjCodeFence(true)<CR>
xnoremap <buffer><silent>af <Esc><ScriptCmd>md.ObjCodeFence(false)<CR>

noremap <buffer> <F5> <ScriptCmd>update<Bar>md.Make()<CR>

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
