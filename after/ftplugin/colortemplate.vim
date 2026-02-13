if exists('b:load_ftp')
	finish
endif
vim9script

import autoload "popup.vim"

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

def ColorSupport()
	var commands = []
	commands->extend([
		{text: "Color support"},
		{text: "tgc/256", key: "g", cmd: (_) => {
			if &tgc
				set t_Co=256
				set notgc
				popup_notification("Switching to 256 colors", {})
			else
				set t_Co=256
				set tgc
				popup_notification("Switching to GUI colors", {})
			endif
		}},
		{text: "16/8", key: "t", cmd: (_) => {
			set notgc
			if str2nr(&t_Co) == 16
				set t_Co=8
				popup_notification("Switching to 8 colors", {})
			else
				set t_Co=16
				popup_notification("Switching to 16 colors", {})
			endif
		}},
		{text: "0", key: "T", cmd: (_) => {
			set notgc
			set t_Co=0
			popup_notification("Switching to 0 colors", {})
		}},
	])
	popup.Commands(commands)
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

b:undo_ftplugin = 'setl omnifunc<'
	.. ' | exe "nunmap <buffer> <F5>"'
	.. ' | exe "nunmap <buffer> <F7>"'
	.. ' | exe "nunmap <buffer> <F8>"'
	.. ' | exe "nunmap <buffer> <F9>"'
if !has("gui_running")
	noremap <buffer><F3> <ScriptCmd>ColorSupport()<CR>
	b:undo_ftplugin ..= ' | exe "nunmap <buffer> <F3>"'
endif
b:load_ftp = 1
