vim9script

$v = $HOME .. (has('win32') ? '/vimfiles' : '/.vim')
$VIMRC = $v .. '/vimrc'

g:mapleader = ' '            # 定义<leader>键
g:maplocalleader = ';'       # 定义<loaclleader>键

source $v/config/options.vim

source $v/config/keymaps.vim

source $v/config/autocmds.vim

source $v/config/plugs.vim

silent! colorscheme catppuccin_mocha # 颜色主题
hi! clear SpellBad
hi! clear SpellCap
hi! clear SpellLocal
hi! clear SpellRare
hi! SpellBad gui=undercurl guisp=LightRed term=undercurl
hi! SpellCap gui=undercurl guisp=LightYellow term=undercurl
hi! SpellLocal gui=undercurl guisp=LightBlue term=undercurl
hi! SpellRare gui=undercurl guisp=LightGreen term=undercurl
hi! ALEVirtualTextError   ctermfg=12 ctermbg=16 guifg=#ff0000 guibg=#1E1E2E
hi! ALEVirtualTextWarning ctermfg=6  ctermbg=16 guifg=#ff922b guibg=#1E1E2E
hi! ALEVirtualTextInfo    ctermfg=14 ctermbg=16 guifg=#fab005 guibg=#1E1E2E
