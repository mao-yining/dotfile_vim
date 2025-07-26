vim9script

if has("gui_gtk2")
	set guifont=Luxi\ Mono\ 12
elseif has("x11")
	# Also for GTK 1
	set guifont=*-lucidatypewriter-medium-r-normal-*-*-180-*-*-m-*-*
elseif has("gui_win32")
	set renderoptions=type:directx
endif

set columns=86
set t_vb=                   # 关闭视觉铃声
set guioptions+=c           # 使用控制台对话框而不是弹出式对话框
set guioptions+=!           # 在内部终端窗口执行外部命令
set guioptions-=m           # 隐藏菜单栏
set guioptions-=T           # 隐藏工具栏
set guioptions-=L           # 隐藏左侧滚动条
set guioptions-=r           # 隐藏右侧滚动条
set guioptions-=b           # 隐藏底部滚动条
set guioptions-=e           # 隐藏 Tab 栏

# Toggle fullscreen mode by pressing F11
inoremap <F11> <Esc><Cmd>ToggleFullscreen<CR>
noremap <F11> <Esc><Cmd>ToggleFullscreen<CR>
# Toggle window transparency to 247 or 180 by pressing F12
inoremap <F12> <Esc><Cmd>ToggleTransparency<CR>
noremap <F12> <Esc><Cmd>ToggleTransparency<CR>

# 粘贴快捷键
noremap! <C-S-V> <C-R>+

# Vim 的 IME 自动切换有实现上的问题。不过以下的代码也可以有不错的效果。
# CmdlineLeave 事件会被很多插件误触发，这个实现也勉强可用。
noremap ? <Cmd>set noimdisable<CR>?
noremap / <Cmd>set noimdisable<CR>/
noremap : <Cmd>set noimdisable<CR>:<Del>:
cnoremap <C-C> <Cmd>set imdisable<CR><C-C>
cnoremap <CR> <Cmd>set imdisable<CR><CR>
cnoremap <C-[> <Cmd>set imdisable<CR><C-[>
augroup IME
	au!
	au GUIEnter * set imdisable
	au InsertEnter * set noimdisable
	au InsertLeavePre * set imdisable
augroup END

if has('multi_byte_ime')
	hi CursorIM guifg=#2d2c3a guibg=#cba6f7 # 输入法模式光标颜色
	hi Cursor guifg=#2d2c3a guibg=#f5e0dc   # 普通模式光标颜色
	hi lCursor guifg=#2d2c3a guibg=#f38ba8  # loadkeymap 模式光标颜色
endif
