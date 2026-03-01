if exists('b:load_ftp')
	finish
endif
inoremap <buffer> . .<Cmd>LedgerAlign<CR><Right>
inoremap <buffer> = =<Cmd>LedgerAlign<CR><Right>
nnoremap <buffer> m<Space> :Ledger<Space>
nnoremap <buffer> <LocalLeader>c <Cmd>Ledger cleared<CR>
nnoremap <buffer> <LocalLeader>b <Cmd>Ledger balance<CR>
let b:load_ftp = 1
