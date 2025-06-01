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
hi! clear SpellRare
hi! SpellBad gui=undercurl guisp=LightRed term=underline ctermbg=12
hi! SpellCap gui=undercurl guisp=LightYellow term=underline ctermbg=9
hi! SpellRare gui=undercurl guisp=LightBlue term=underline ctermbg=13
