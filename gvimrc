vim9script

set guioptions=!cCd

inoremap <C-S-V> <C-R><C-P>+
cnoremap <C-S-V> <C-R><C-O>+
nnoremap <expr> <C-Z> ':!' .. &shell .. '<CR>'

if has("gui_win32")
	set renderoptions=type:directx
	set linespace=0
	$ALPHADLL = $MYVIMDIR .. "gvim_fullscreen.dll"
	if has("libcall") && filereadable($ALPHADLL)
		noremap! <expr> <F11> $"<Cmd>se go{&go =~# 's' ? '-' : '+'}=s<CR>"
		noremap  <expr> <F11> $"<Cmd>se go{&go =~# 's' ? '-' : '+'}=s<CR>"
		noremap! <expr> <F12> libcall($ALPHADLL, "ToggleTransparency", "255,180")
		noremap  <expr> <F12> libcall($ALPHADLL, "ToggleTransparency", "255,180")
	endif
	augroup mswin_strat | au!
		autocmd GUIEnter * simalt ~x
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
