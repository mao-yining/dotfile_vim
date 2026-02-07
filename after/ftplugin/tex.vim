vim9script
compiler tex
if exists('g:tex_comment_nospell')|finish|endif
g:tex_comment_nospell = 1
g:vimtex_quickfix_autoclose_after_keystrokes = 2
g:vimtex_doc_handlers = ['vimtex#doc#handlers#texdoc']
g:vimtex_quickfix_open_on_warning = 0
g:vimtex_format_enabled = 1
g:vimtex_fold_enabled = 1
g:vimtex_fold_manual = 1
g:matchup_override_vimtex = 1
g:vimtex_view_skim_reading_bar = 1
g:vimtex_complete_enabled = 1
g:vimtex_quickfix_mode = 0
g:vimtex_compiler_latexmk = {
	aux_dir: '',
	out_dir: '',
	callback: 1,
	continuous: 1,
	executable: 'latexmk',
	hooks: [],
	options: [
		'-verbose',
		'-file-line-error',
		'-shell-escape',
		'-synctex=1',
		'-interaction=nonstopmode',
	],
}
