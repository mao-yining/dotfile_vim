if exists('b:load_ftp')
	finish
endif
inoremap <buffer> . .<Cmd>LedgerAlign<CR><Right>
inoremap <buffer> = =<Cmd>LedgerAlign<CR><Right>
nnoremap <buffer> m<Space> :Ledger<Space>
nnoremap <buffer> <LocalLeader>b <Cmd>Ledger balancesheet<CR>
nnoremap <buffer> <LocalLeader>c <Cmd>Ledger cashflow<CR>
nnoremap <buffer> <LocalLeader>i <Cmd>Ledger incomestatement<CR>
let b:load_ftp = 1
