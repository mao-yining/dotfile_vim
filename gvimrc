vim9script

set guioptions=!cd
set winaltkeys=no

inoremap <C-S-V> <C-R><C-P>+
cnoremap <C-S-V> <C-R><C-O>+

if !exists('g:vimrc_sourced')
	g:vimrc_sourced = 1
	set lines=35
	set columns=120
endif

if has("gui_win32")
	set renderoptions=type:directx
	set linespace=0
	$ALPHADLL = $MYVIMDIR .. "gvim_fullscreen.dll"
	if has("libcall") && filereadable($ALPHADLL)
		noremap! <expr><F11> libcall($ALPHADLL, "ToggleFullscreen", 0)
		noremap  <expr><F11> libcall($ALPHADLL, "ToggleFullscreen", 0)
		noremap! <expr><F12> libcall($ALPHADLL, "ToggleTransparency", "255,180")
		noremap  <expr><F12> libcall($ALPHADLL, "ToggleTransparency", "255,180")
	endif
	augroup mswin_strat | au!
		# autocmd GUIEnter * simalt ~x
		# :h w32-experimental-keycode-trans-strategy
		au VimEnter * test_mswin_event("set_keycode_trans_strategy", {strategy: "experimental"})
		# gVim 的 IME 初始化有问题，临时解决方案。
		au VimEnter * set imdisable | set noimdisable
	augroup END
endif

# quick font check:
# З3Э -- cyrillic ze, three, cyrillic e
# 1lI0OQB8 =-+*:(){}[]
# I1legal
