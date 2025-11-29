vim9script
packadd helptoc

nnoremap <buffer> <LocalLeader>t <ScriptCmd>HelpToc<CR>
nnoremap <buffer> q <Cmd>bd<CR>

def HelpComplete(findstart: number, base: string): any
	if findstart
		const colnr = col('.') - 1 # Get the column number before the cursor
		const line = getline('.')
		for i in range(colnr - 1, 0, -1)
			if line[i] ==# '|'
				return i + 1 # Don't include the `|` in base
			elseif line[i] ==# "'"
				return i # Include the `'` in base
			endif
		endfor
	else
		return getcompletion(base, 'help')
	endif
	return null_string
enddef
setlocal completefunc=HelpComplete
setlocal complete-=o
setlocal complete^=F
setlocal complete^=t
