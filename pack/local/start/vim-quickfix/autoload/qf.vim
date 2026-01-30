vim9script

def EchoErr(message: string)
	echohl ErrorMsg | echom "[qf.vim]" message | echohl None
enddef

def IsLocationList(winnr = winnr()): bool
	return getloclist(winnr, {'filewinid': 0}).filewinid > 0
enddef

export def QuickFixText(info: dict<any>): list<string>
	var items: list<dict<any>>
	if info.quickfix == 1
		items = getqflist({id: info.id, items: 1}).items
	else
		items = getloclist(info.winid, {id: info.id, items: 1}).items
	endif
	var l: list<string>
	for idx in range(info.start_idx - 1, info.end_idx - 1)
		if items[idx].valid
			var text = bufname(items[idx].bufnr)->fnamemodify(':p:~:.')->pathshorten()
			if items[idx].lnum != 0
				text ..= $"|{items[idx].lnum}"
			endif
			if items[idx].col != 0
				text ..= $":{items[idx].col}"
			endif
			text ..= $"|{items[idx].text}"
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
		exe "wincmd \<CR>"
		wincmd T
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
	if IsLocationList()
		execute($":{v:count1}lnext", "silent!")
	else
		execute($":{v:count1}cnext", "silent!")
	endif
	if exists(":BlinkLine") == 2
		BlinkLine
	endif
	wincmd p
enddef

export def Prev()
	if IsLocationList()
		execute($":{v:count1}lprev", "silent!")
	else
		execute($":{v:count1}cprev", "silent!")
	endif
	if exists(":BlinkLine") == 2
		BlinkLine
	endif
	wincmd p
enddef

const max_height = 10

export def COpen()
	exe $':{min([max_height, len(getqflist())])}cwindow'
enddef

export def LOpen()
	exe $':{min([max_height, len(getloclist(0))])}lwindow'
enddef

def IsQfWindowOpen(): bool
	for i in range(1, winnr('$'))
		if getbufvar(winbufnr(i), '&buftype') == 'quickfix'
			return true
		endif
	endfor
	return false
enddef

export def ToggleQF()
	if IsQfWindowOpen()
		cclose
	else
		COpen()
	endif
enddef

def IsLocWindowOpen(winnr = winnr()): bool
	for i in range(1, winnr('$'))
		if IsLocationList(i)
				&& (i == winnr
				|| getloclist(i, {'filewinid': 0}).filewinid == win_getid(winnr))
			return true
		endif
	endfor
	return false
enddef

export def ToggleLoc()
	if IsLocWindowOpen()
		lclose
		return
	endif
	try
		LOpen()
	catch /^Vim(lopen):E776:/
		EchoErr(v:exception->strpart(17))
	endtry
enddef

export def Older()
	try
		execute (IsLocationList() ? 'l' : 'c') .. 'older'
	catch /^Vim([cl]older):E380:/
	endtry
enddef

export def Newer()
	try
		execute (IsLocationList() ? 'l' : 'c') .. 'newer'
	catch /^Vim([cl]newer):E381:/
	endtry
enddef
