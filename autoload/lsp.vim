vim9script

export def SetupMaps()
	nmap     <buffer> gD <Cmd>LspGotoDeclaration<CR>
	nmap     <buffer> gd <Cmd>LspGotoDefinition<CR>
	nmap     <buffer> gy <Cmd>LspGotoTypeDef<CR>
	nmap     <buffer> gi <Cmd>LspGotoImpl<CR>
	nmap     <buffer> gr <Cmd>LspPeekReferences<CR>
	nmap     <buffer> gR <Cmd>LspShowReferences<CR>
	nmap     <buffer> gs <Cmd>LspSubTypeHierarchy<CR>
	nmap     <buffer> gS <Cmd>LspSuperTypeHierarchy<CR>
	nmap     <buffer> yoI <Cmd>LspInlayHints toggle<CR>
	nmap     <buffer> [oI <Cmd>LspInlayHints enable<CR>
	nmap     <buffer> ]oI <Cmd>LspInlayHints disable<CR>
	noremap  <buffer> <Leader>ca <Cmd>LspCodeAction<CR>
	noremap  <buffer> <Leader>cl <Cmd>LspCodeLens<CR>
	xnoremap <buffer> . <Cmd>LspSelectionExpand<CR>
	xnoremap <buffer> , <Cmd>LspSelectionShrink<CR>
	map      <buffer> <F2> <Cmd>LspRename<CR>
enddef
