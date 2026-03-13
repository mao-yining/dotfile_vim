set tags=./tags

if !&l:modifiable && &l:readonly
	nnoremap <buffer> q <Cmd>wincmd c<CR>
endif

nnoremap <buffer> <LocalLeader>t <ScriptCmd>HelpToc<CR>

if !exists('g:help_example_languages')
	let g:help_example_languages = #{ vim: 'vim', vim9: 'vim', sh: 'sh', cpp: 'cpp' }
endif
