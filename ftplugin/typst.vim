vim9script

def Watch()
	exe "Term typst watch" expand("%:p")
enddef

def Open()
	exe "Open" expand("%:p:r") .. ".pdf"
enddef

nnoremap <buffer> <F5> <Cmd>update<CR><ScriptCmd>Make<CR>
nnoremap <buffer> <Localleader>ll <Cmd>update<CR><ScriptCmd>Watch()<CR>
nnoremap <buffer> <Localleader>lv <ScriptCmd>Open()<CR>

b:undo_ftplugin = ' | exe "nunmap <buffer> <F5>"'
b:undo_ftplugin ..= ' | exe "nunmap <buffer> <LocalLeader>ll"'
b:undo_ftplugin ..= ' | exe "nunmap <buffer> <LocalLeader>lv"'
