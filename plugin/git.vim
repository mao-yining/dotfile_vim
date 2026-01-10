if !executable("git") || "vim-fugitive"->getcompletion("packadd")->empty()
	finish
endif
packadd vim-fugitive
packadd vim-gitgutter
packadd gv.vim
packadd conflict-marker.vim
nmap <Leader>gg <Cmd>Git<CR>
nmap <Leader>gl <Cmd>GV<CR>
nmap <Leader>g<Space> :Git<Space>
nmap <Leader>gc<Space> :Git commit<Space>
nmap <Leader>gcc <Cmd>Git commit -v<CR>
nmap <Leader>gcs <Cmd>Git commit -s -v<CR>
nmap <Leader>gca <Cmd>Git commit --amend -v<CR>
nmap <Leader>gce <Cmd>Git commit --amend --no-edit -v<CR>
nmap <Leader>gb <Cmd>Git branch<CR>
nmap <Leader>gs :Git switch<Space>
nmap <Leader>gS :Git stash<Space>
nmap <Leader>gco :Git checkout<Space>
nmap <Leader>gcp :Git cherry-pick<Space>
nmap <Leader>gM :Git merge<Space>
nmap <Leader>gp <Cmd>Git! pull<CR>
nmap <Leader>gP <Cmd>Git! push<CR>
nmap <Leader>gm <Cmd>Git mergetool<CR>
nmap <Leader>gd <Cmd>Git difftool<CR>
nmap <Leader>gr <Cmd>Gread<CR>
nmap <Leader>gw <Cmd>Gwrite<CR>
nmap <Leader>gB <Cmd>GBrowse<CR>
nmap <LocalLeader>gl <Cmd>GV!<CR>
nmap <LocalLeader>gd <Cmd>Git diff %<CR>
nmap <LocalLeader>gD <Cmd>Gdiffsplit<CR>
nmap <LocalLeader>gb <Cmd>Git blame<CR>
nmap <LocalLeader>hw <Plug>(GitGutterStageHunk)
nmap <LocalLeader>hr <Plug>(GitGutterUndoHunk)
nmap <LocalLeader>hp <Plug>(GitGutterPreviewHunk)
omap ih <Plug>(GitGutterTextObjectInnerPending)
omap ah <Plug>(GitGutterTextObjectOuterPending)
xmap ih <Plug>(GitGutterTextObjectInnerVisual)
xmap ah <Plug>(GitGutterTextObjectOuterVisual)
nmap ]h <Plug>(GitGutterNextHunk)
nmap [h <Plug>(GitGutterPrevHunk)

let g:gitgutter_map_keys = 0
let g:gitgutter_preview_win_floating = 1
