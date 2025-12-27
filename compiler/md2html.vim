vim9script

if exists("g:current_compiler")
    finish
endif

g:current_compiler = "markdown_html"

var input_flags = [
	'commonmark_x',
	'+wikilinks_title_after_pipe',
	'+east_asian_line_breaks',
]

var target = 'pdf'

var args = [
	'-s',
	'--toc',
	'--toc-depth=3',
	'-f',
	join(input_flags, ''),
	'%',
	'-o'
	'-s',
	'--wrap=auto',
	'%:t:r.html'
]

&l:makeprg = $"pandoc {args->join(' ')}"
