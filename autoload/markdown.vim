vim9script

export def OpenWikiLink()
	const line = getline('.')
	const col = col('.')
	const start = strridx(line->strpart(0, col), '[[')
	const end = stridx(line->strpart(col), ']]')
	try
		if start == -1 || end == -1
			normal gF
			return
		endif
		g:SetProjectRoot()
		execute 'find' fnameescape(line->strpart(start, col - start + end)->trim('[] '))
	catch /^Vim\%((\a\+)\)\=:E/
		echohl ErrorMsg
		echomsg v:exception->substitute('\S\{-}:', '', '')
		echohl None
	endtry
enddef
