vim9script

set guioptions=!cCdM

inoremap <C-S-V> <C-R><C-P>+
cnoremap <C-S-V> <C-R><C-O>+

if has("win32")
	set renderoptions=type:directx
	set guifont=Inconsolata_Nerd_Font_Mono:h13
	set linespace=0
	noremap! <expr> <F11> $"<Cmd>se go{&go =~# 's' ? '-' : '+'}=s<CR>"
	noremap  <expr> <F11> $"<Cmd>se go{&go =~# 's' ? '-' : '+'}=s<CR>"
	augroup mswin_strat | au!
		autocmd GUIEnter * {
			simalt ~x
			# :h w32-experimental-keycode-trans-strategy
			test_mswin_event("set_keycode_trans_strategy", {strategy: "experimental"})
			# gVim 的 IME 初始化有问题，临时解决方案。
			set imdisable
			set noimdisable
		}
	augroup END
endif

# quick font check:
# З3Э -- cyrillic ze, three, cyrillic e
# 1lI0OQB8 =-+*:(){}[]
# I1legal
