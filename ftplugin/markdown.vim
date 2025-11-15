vim9script noclear

setlocal nolinebreak
setlocal textwidth=74

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
