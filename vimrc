vim9script

$v = $HOME .. (has('win32') ? '/vimfiles' : '/.vim')
$VIMRC = $v .. '/vimrc'

g:mapleader = ' '            # 定义<leader>键
g:maplocalleader = ';'       # 定义<loaclleader>键

source $v/config/options.vim

source $v/config/keymaps.vim

source $v/config/autocmds.vim

source $v/config/plugs.vim

colorscheme catppuccin_mocha # 颜色主题
syntax enable                # 开启语法高亮功能
filetype plugin indent on    # 写在所有 packadd! 命令之后
