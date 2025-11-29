vim9script
# Check after/plugin/if_loaded.vim for settings that depends on plugin existence
# Plugin settings

packadd comment
# packadd editexisting
packadd editorconfig
packadd helptoc
packadd hlyank
packadd matchit
packadd nohlsearch

nmap <LocalLeader>t <Cmd>HelpToc<CR>
tmap <C-T><C-T> <Cmd>HelpToc<CR>

g:popup_borderchars = ['─', '│', '─', '│', '╭', '╮', '╯', '╰']
g:popup_borderchars_t = ['─', '│', '─', '│', '├', '┤', '╯', '╰']
g:hlyank_duration = 200

if executable("ctags")
    silent! packadd vim-gutentags
endif
