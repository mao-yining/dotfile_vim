vim9script

import autoload "./qc.vim"
export def SetupMaps()
	autocmd_add([{
		replace: true,
		event:   'FileType',
		bufnr:   bufnr(),
		cmd:     'setl omnifunc=LspOmniFunc keywordprg=:LspHover'
	}])
	setl omnifunc=LspOmniFunc keywordprg=:LspHover
	nmap <buffer> gD <Cmd>LspGotoDeclaration<CR>
	nmap <buffer> gd <Cmd>LspGotoDefinition<CR>
	nmap <buffer> gy <Cmd>LspGotoTypeDef<CR>
	nmap <buffer> gi <Cmd>LspGotoImpl<CR>
	nmap <buffer> gr <Cmd>LspShowReferences<CR>
	nmap <buffer> gs <Cmd>LspShowSignature<CR>
	nmap <buffer> yoI <Cmd>LspInlayHints toggle<CR>
	nmap <buffer> [oI <Cmd>LspInlayHints enable<CR>
	nmap <buffer> ]oI <Cmd>LspInlayHints disable<CR>
	xmap <buffer> . <Cmd>LspSelectionExpand<CR>
	xmap <buffer> , <Cmd>LspSelectionShrink<CR>
	map  <buffer> <F2> <Cmd>LspRename<CR>
	nmap <buffer> <LocalLeader>s <Cmd>LspDocumentSymbol<CR>
	nmap <buffer> <LocalLeader>c <ScriptCmd>qc.LspCommands()<CR>
enddef
