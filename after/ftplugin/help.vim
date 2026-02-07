set tags=./tags
if !&l:modifiable && &l:readonly
	nnoremap <buffer> q <Cmd>wincmd c<CR>
endif

if !exists(":HelpToc") && !"helptoc"->getcompletion("packadd")->empty()
	packadd helptoc
endif
if exists(":HelpToc")
	nnoremap <buffer> <LocalLeader>t <ScriptCmd>HelpToc<CR>
endif
