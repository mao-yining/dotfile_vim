nmap <buffer> q <Cmd>q<CR>
nmap <buffer> { <Plug>(qf_previous_file)
nmap <buffer> } <Plug>(qf_next_file)
nmap <buffer> <Left>  <Plug>(qf_older)
nmap <buffer> <Right> <Plug>(qf_newer)
nnoremap <buffer> t <C-W><CR><C-W>T
nnoremap <buffer> o <CR><Cmd>wincmd p<CR>

if getqflist({'title': 1}).title =~# "^:Dispatch"
	nmap <buffer> <C-C> <Cmd>AbortDispatch<CR>
elseif getqflist({'title': 1}).title =~# "^:AsyncRun"
	nmap <buffer> <C-C> <Cmd>AsyncStop<CR>
endif
