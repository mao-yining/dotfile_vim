vim9script

b:undo_ftplugin = 'setl omnifunc<'
	.. ' | exe "nunmap <buffer> <F5>"'
	.. ' | exe "nunmap <buffer> <F7>"'
	.. ' | exe "nunmap <buffer> <F8>"'
	.. ' | exe "nunmap <buffer> <F9>"'

import autoload "../import/colortemplate.vim" as ct

&omnifunc = ct.HighlightCompletor
if !has("gui_running")
	noremap <buffer><F3> <ScriptCmd>ct.ColorSupport()<CR>
	b:undo_ftplugin ..= ' | exe "nunmap <buffer> <F3>"'
endif
noremap <buffer><F5> <ScriptCmd>ct.Run()<CR>
noremap <buffer><F7> <Cmd>ColortemplateShow<CR>
noremap <buffer><F8> <Cmd>Colortemplate!<CR>
noremap <buffer><F9> <Cmd>ColortemplateAll!<CR>

