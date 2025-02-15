vim9script

if has("gui_gtk2")
	set guifont=Luxi\ Mono\ 12
elseif has("x11")
	# Also for GTK 1
	set guifont=*-lucidatypewriter-medium-r-normal-*-*-180-*-*-m-*-*
elseif has("gui_win32")
	# set guifont=Inconsolata\ Nerd\ Font\ Mono:h12  # 使用默认字体 (Consolas) 效果挺好。
	# set guifontwide=霞鹜文楷等宽,等距更纱黑体\ SC
	set guifont=:h12
	set renderoptions=type:directx
	# 默认：未知，但是这个字体不会有显示上的问题，使用DirectX和使用默认渲染器
	# 的字体并不一样。默认的双宽字体似乎是宋体横向拉长，也就是直接打印出的样子。
endif

set t_vb=                   # 关闭视觉铃声
# set guioptions+=a         
set guioptions+=c           # 使用控制台对话框而不是弹出式对话框
set guioptions+=!           # 在内部终端窗口执行外部命令
set guioptions-=m           # 隐藏菜单栏
set guioptions-=T           # 隐藏工具栏
set guioptions-=L           # 隐藏左侧滚动条
set guioptions-=r           # 隐藏右侧滚动条
set guioptions-=b           # 隐藏底部滚动条
set guioptions-=e           # 隐藏 Tab 栏

# Toggle fullscreen mode by pressing F11
inoremap <f11> <esc><cmd>ToggleFullscreen<cr>
noremap <f11> <esc><cmd>ToggleFullscreen<cr>
# Toggle window transparency to 247 or 180 by pressing F12
inoremap <f12> <esc><cmd>ToggleTransparency<cr>
noremap <f12> <esc><cmd>ToggleTransparency<cr>
