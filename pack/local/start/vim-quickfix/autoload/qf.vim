vim9script

def EchoErr(message: string)
	echohl ErrorMsg | echom "[qf.vim]" message | echohl None
enddef

def IsLocationList(): bool
	return getloclist(winnr(), {'filewinid': 0}).filewinid > 0
enddef

export def QuickFixText(info: dict<any>): list<string>
	var items = []
	if info.quickfix == 1
		items = getqflist({id: info.id, items: 1}).items
	else
		items = getloclist(info.winid, {id: info.id, items: 1}).items
	endif
	var l = []
	for idx in range(info.start_idx - 1, info.end_idx - 1)
		if items[idx].valid
			var text = bufname(items[idx].bufnr)->fnamemodify(':p:~:.')->pathshorten()
			if items[idx].lnum != 0
				text ..= $":{items[idx].lnum}"
			endif
			if items[idx].col != 0
				text ..= $":{items[idx].col}"
			endif
			text ..= $":{items[idx].text}"
			l->add(text)
		else
			l->add(items[idx].text)
		endif
	endfor
	return l
enddef

export def View(tab = false)
	var winid = win_getid()
	if tab
		exe "normal! \<C-W>\<CR>\<C-W>T"
	else
		exe "normal! \<CR>"
	endif
	if winid == win_getid()
		return
	endif
	normal! zz
	if exists(":BlinkLine") == 2
		BlinkLine
	endif
	wincmd p
enddef

export def Next()
	try
		if IsLocationList()
			lnext
		else
			cnext
		endif
		if exists(":BlinkLine") == 2
			BlinkLine
		endif
		wincmd p
	catch
	endtry
enddef

export def Prev()
	try
		if IsLocationList()
			lprev
		else
			cprev
		endif
		if exists(":BlinkLine") == 2
			BlinkLine
		endif
		wincmd p
	catch
	endtry
enddef

export def ToggleQF()
	for win in range(1, winnr('$'))
		if getbufvar(winbufnr(win), '&buftype') == 'quickfix'
			cclose
			return
		endif
	endfor
	copen
enddef

export def ToggleLocationList()
	for win in range(1, winnr('$'))
		if getbufvar(winbufnr(win), '&buftype') == 'quickfix'
			if getwinvar(win, 'loclist') == 1
				lclose
				return
			endif
		endif
	endfor
	try
		lopen
	catch /^Vim(lopen):E776:/
		EchoErr(v:exception->strpart(17))
	endtry
enddef

export def Older()
	silent! execute (IsLocationList() ? 'l' : 'c') .. 'older'
enddef

export def Newer()
	silent! execute (IsLocationList() ? 'l' : 'c') .. 'newer'
enddef
