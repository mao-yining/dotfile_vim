set tags=./tags
nnoremap <buffer> q <Cmd>bd<CR>

if !exists(":HelpToc") && !"helptoc"->getcompletion("packadd")->empty()
	packadd helptoc
else
	finish
endif
nnoremap <buffer> <LocalLeader>t <ScriptCmd>HelpToc<CR>
