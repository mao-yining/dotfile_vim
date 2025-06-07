let g:beancount_account_completion = 'chunks'
let g:beancount_detailed_first = 1
nnoremap <buffer><localleader>f <cmd>%AlignCommodity<cr>
inoremap <buffer>. .<C-O>:AlignCommodity<CR>
inoremap <Tab> <c-x><c-o>
