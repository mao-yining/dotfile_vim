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

var args = [
	'pandoc',
	'%:S',
	'-f',
	input_flags->join(''),
	"-t pdf",
	'-o %:.:s?\.md?\.pdf?:s?notes?.build?:S',
	'-s',
	'--wrap=auto',
	'--pdf-engine=lualatex',
	'--pdf-engine-opt=--shell-escape',
	'-V documentclass=ctexart',
]

&l:makeprg = args->join()
