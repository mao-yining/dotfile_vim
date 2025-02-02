let g:vimtex_quickfix_mode = 0
let g:tex_flavor = "latex"
let g:vimtex_compiler_latexmk_engines = { '_' : "-xelatex", }
let g:vimtex_compiler_latexmk = {
			\ 'aux_dir' : '',
			\ 'out_dir' : '',
			\ 'callback' : 1,
			\ 'continuous' : 1,
			\ 'executable' : 'latexmk',
			\ 'hooks' : [],
			\ 'options' : [
			\   '-verbose',
			\   '-file-line-error',
			\	'-shell-escape',
			\   '-synctex=1',
			\   '-interaction=nonstopmode',
			\ ],
			\}
autocmd FileType tex call pencil#init({'wrap': 'soft', 'autoformat': 1})
" gvim -v --not-a-term -T dumb -c "VimtexInverseSearch %l '%f'"
