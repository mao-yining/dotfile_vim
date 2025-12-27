vim9script
if exists("g:current_compiler")
	finish
endif
g:current_compiler = "md2pdf"

var input_flags = [
	'commonmark_x',
	'+wikilinks_title_after_pipe',
	'+east_asian_line_breaks',
]

var target = 'pdf'

var args = [
	'%:S',
	'-f',
	join(input_flags, ''),
	$"-t {target}",
	$'-o %:.:s?\.md?\.{target}?:s?notes?.build?:S',
	'-s',
	'--wrap=auto',
	'--pdf-engine=lualatex',
	'--pdf-engine-opt=--shell-escape',
	'-V documentclass=ctexart',
]

&l:makeprg = $"pandoc {args->join(' ')}"
