vim9script

set t_vb=
set guioptions=!cd
set winaltkeys=no

inoremap <C-S-V> <C-R><C-P>+
cnoremap <C-S-V> <C-R><C-O>+

if has("gui_win32")
	set renderoptions=type:directx
	set linespace=0
	# autocmd GUIEnter * simalt ~x
	# Toggle fullscreen mode by pressing F11
	noremap! <F11> <Cmd>ToggleFullscreen<CR>
	noremap  <F11> <Cmd>ToggleFullscreen<CR>
	# Toggle window transparency to 247 or 180 by pressing F12
	noremap! <F12> <Cmd>ToggleTransparency<CR>
	noremap  <F12> <Cmd>ToggleTransparency<CR>
	augroup mswin_strat | au!
	# :h w32-experimental-keycode-trans-strategy
		au VimEnter * test_mswin_event('set_keycode_trans_strategy', {'strategy': 'experimental'})
	# gVim 的 IME 初始化有问题，临时解决方案。
	autocmd VimEnter * set imdisable | set noimdisable
	augroup END
endif

# quick font check:
# З3Э -- cyrillic ze, three, cyrillic e
# 1lI0OQB8 =-+*:(){}[]
# I1legal
