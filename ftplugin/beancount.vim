vim9script
inoremap <buffer><expr> <Tab> CheckBackspace() ? "\<Tab>" : "<C-X><C-O>"
def CheckBackspace(): bool
	var col = col('.') - 1
	return !col || getline('.')[col - 1] =~# '\s'
enddef
nnoremap <buffer> <LocalLeader>f <Cmd>%AlignCommodity<CR>
inoremap <buffer> . .<C-\><C-O>:AlignCommodity<CR>
nnoremap <buffer> <LocalLeader>c <Cmd>GetContext<CR>
