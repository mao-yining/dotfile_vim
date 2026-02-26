if exists('b:load_ftp')
	finish
endif
vim9script
# TODO: complete
# - highlight groups as the first word or a link after ->
# - colortemplete keywords
# - /256/16/8/0 after highlight group or as a first thing on the line
# - reverse/bold/italic/underline as the fourth part of the highlight definition
# - none/omit as a second or third part of highlight definition
# - color names (would require scanning of the buffer)
# - Include: for files
# - Environments: for gui/256/16/8/0

def HighlightCompletor(findstart: number, base: string): any
	if findstart > 0
		var prefix = getline('.')->strpart(0, col('.') - 1)->matchstr('\k\+$')
		if prefix->empty()
			return -2
		endif
		return col('.') - prefix->len() - 1
	endif

	var items = getcompletion('', 'highlight')
		->mapnew((_, v) => ({word: v, kind: 'h', dup: 0}))
		->matchfuzzy(base, {key: "word"})

	return items->empty() ? v:none : items
enddef

def Run()
	update
	Colortemplate!
	ColortemplateShow
enddef

&omnifunc = HighlightCompletor
noremap <buffer><F5> <ScriptCmd>Run()<CR>
noremap <buffer><F7> <Cmd>ColortemplateShow<CR>
noremap <buffer><F8> <Cmd>Colortemplate!<CR>
noremap <buffer><F9> <Cmd>ColortemplateAll!<CR>

import autoload "qc.vim"
if !has("gui_running")
	noremap <buffer><F3> <ScriptCmd>qc.ColorSupport()<CR>
endif
b:load_ftp = 1
