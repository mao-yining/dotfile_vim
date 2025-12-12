packadd vim-vsnip
packadd vim-vsnip-integ
packadd friendly-snippets

inoremap <expr> <C-l>   vsnip#expandable()  ? "<Plug>(vsnip-expand)"         : "<C-j>"
snoremap <expr> <C-l>   vsnip#expandable()  ? "<Plug>(vsnip-expand)"         : "<C-j>"
inoremap <expr> <C-j>   vsnip#available(1)  ? "<Plug>(vsnip-expand-or-jump)" : "<C-l>"
snoremap <expr> <C-j>   vsnip#available(1)  ? "<Plug>(vsnip-expand-or-jump)" : "<C-l>"
inoremap <expr> <Tab>   vsnip#jumpable(1)   ? "<Plug>(vsnip-jump-next)"      : "<Tab>"
snoremap <expr> <Tab>   vsnip#jumpable(1)   ? "<Plug>(vsnip-jump-next)"      : "<Tab>"
inoremap <expr> <S-Tab> vsnip#jumpable(-1)  ? "<Plug>(vsnip-jump-prev)"      : "<S-Tab>"
snoremap <expr> <S-Tab> vsnip#jumpable(-1)  ? "<Plug>(vsnip-jump-prev)"      : "<S-Tab>"
nmap     <C-S>   <Plug>(vsnip-select-text)
xmap     <C-S>   <Plug>(vsnip-select-text)
nmap     <C-S-S> <Plug>(vsnip-cut-text)
xmap     <C-S-S> <Plug>(vsnip-cut-text)
