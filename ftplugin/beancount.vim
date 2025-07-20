let g:beancount_account_completion = 'chunks'
let g:beancount_detailed_first = 1
nnoremap <buffer><LocalLeader>f <Cmd>%AlignCommodity<CR>
inoremap <buffer>. .<C-O>:AlignCommodity<CR>
inoremap <Tab> <C-X><C-O>
