vim9script
# Name: autoload/substitute.vim
# Author: Mao-Yining <mao.yining@outlook.com>
# Desc: Subversive-style text substitution operators for Vim9
# Usage:
# import autoload 'substitute.vim'
#
# nmap s <ScriptCmd>substitute.SetOperatorFunc(false)<CR>g@
# nmap ss <ScriptCmd>substitute.Line()<CR>
# nmap S <ScriptCmd>substitute.ToEndOfLine()<CR>
# xmap s <Esc>`<<ScriptCmd>substitute.SetOperatorFunc(true)<CR>g@`>

export def SetOperatorFunc(visual: bool)
	&operatorfunc = (v: bool, type: string) => {
		var cmd = "normal! "
		if v
			cmd ..= $"`<\"_c{visualmode()}`>"
		else
			if type == 'line'
				cmd ..= "`[\"_cV`]"
			else
				cmd ..= "`[\"_cv`]"
			endif
		endif

		cmd ..= "\<C-R>" .. v:register

		if getreg(v:register) =~ '\v\n$'
			cmd ..= "\<BS>"
		endif

		const save_paste = &paste
		set paste
		exe cmd .. "\<Esc>"
		&paste = save_paste

		var end_change_pos = getpos("']")
		end_change_pos[2] = max((0, end_change_pos[2] - 1))
		setpos("']", end_change_pos)
	}->function([visual])
enddef

export def Line()
	const paste_is_multiline = getreg(v:register) =~ '\n'
	var paste_type = "P"

	if v:count1 > 1 || paste_is_multiline
		if line('.') >= line('$') - v:count1 + 1
			paste_type = 'p'
		endif
		execute $"normal! {v:count1}\"_dd"
		if !paste_is_multiline
			execute "normal! O\<Esc>"
		endif
	else
		execute "normal! 0\"_d$"
	endif

	execute $"normal! \"{v:register}{paste_type}"
enddef

export def ToEndOfLine()
	execute $"normal! \"_d$\"{v:register}{v:count1}p"
enddef
