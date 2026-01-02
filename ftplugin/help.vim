set tags=./tags
nnoremap <buffer> q <Cmd>bd<CR>

if !exists(":HelpToc") && !"helptoc"->getcompletion("packadd")->empty()
	packadd helptoc
endif
if exists(":HelpToc")
	nnoremap <buffer> <LocalLeader>t <ScriptCmd>HelpToc<CR>
endif
