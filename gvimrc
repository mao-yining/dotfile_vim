vim9script

if has("gui_win32")
	set renderoptions=type:directx
endif

autocmd GUIEnter * simalt ~x

set t_vb=                   # 关闭视觉铃声
set guioptions+=c           # 使用控制台对话框而不是弹出式对话框
set guioptions+=!           # 在内部终端窗口执行外部命令
set guioptions-=m           # 隐藏菜单栏
set guioptions-=T           # 隐藏工具栏
set guioptions-=L           # 隐藏左侧滚动条
set guioptions-=r           # 隐藏右侧滚动条
set guioptions-=b           # 隐藏底部滚动条
set guioptions-=e           # 隐藏 Tab 栏
set guioptions+=d           # 隐藏 Tab 栏

# Toggle fullscreen mode by pressing F11
noremap! <F11> <Cmd>ToggleFullscreen<CR>
noremap  <F11> <Cmd>ToggleFullscreen<CR>
# Toggle window transparency to 247 or 180 by pressing F12
noremap! <F12> <Cmd>ToggleTransparency<CR>
noremap  <F12> <Cmd>ToggleTransparency<CR>

# 粘贴快捷键
noremap! <C-S-V> <C-R><C-P>+

if has('multi_byte_ime')
	augroup IME
		autocmd!
		# Vim 的 IME 初始化有问题，临时解决方案。
		autocmd VimEnter * set imdisable | set noimdisable
		hi CursorIM guifg=#2d2c3a guibg=#cba6f7 # 输入法模式光标颜色
		hi Cursor guifg=#2d2c3a guibg=#f5e0dc   # 普通模式光标颜色
		hi lCursor guifg=#2d2c3a guibg=#f38ba8  # loadkeymap 模式光标颜色
	augroup END
endif
