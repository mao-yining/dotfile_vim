setl complete-=o^9
inoremap <buffer> . .<Cmd>LedgerAlign<CR><Right>
inoremap <buffer> = =<Cmd>LedgerAlign<CR><Right>
nnoremap <buffer> gq <Cmd>LedgerAlignBuffer<CR>
nnoremap <buffer> m<Space> :Ledger<Space>
nnoremap <buffer> <LocalLeader>c <Cmd>Ledger cleared<CR>
nnoremap <buffer> <LocalLeader>b <Cmd>Ledger balance<CR>
