vim9script

var input_flags = ['commonmark_x',
	'+wikilinks_title_after_pipe',
	'+east_asian_line_breaks',
]

var target_flags = ['commonmark_x',
]

var args = [
	'-f',
	join(input_flags, ''),
	'-t',
	join(target_flags, ''),
	'-s',
	'--wrap=auto',
]

g:neoformat_pandoc_pandoc = { exe: "pandoc", args: args, stdin: 1 }
