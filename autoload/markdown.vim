vim9script

export def OpenWikiLink()
	const line = getline('.')
	const col = col('.')
	const start_pos = strridx(line[ : col - 1], '[[')
	const end_pos = stridx(line[col - 1 : ], ']]')
	try
		if start_pos == -1 || end_pos == -1
			normal gF
			return
		endif
		g:SetProjectRoot()
		execute 'find' fnameescape(line[start_pos : col + end_pos]->trim('[] '))
	catch /^Vim\%((\a\+)\)\=:E/
		echohl ErrorMsg
		echomsg v:exception->substitute('\S\{-}:', '', '')
		echohl None
	endtry
enddef
