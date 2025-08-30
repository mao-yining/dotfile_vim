vim9script noclear

var input_flags = ['commonmark_x',
	'+wikilinks_title_after_pipe',
	'+east_asian_line_breaks',
]

var target = 'pdf'

var args = [
	'%',
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

# g:neoformat_pandoc_pandoc = { exe: "pandoc", args: args, stdin: 1 }
&l:makeprg = $"pandoc {args->join(' ')}"
