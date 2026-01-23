vim9script

# Open links in wiki style
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

# code block text object
export def ObjCodeFence(inner: bool)
	# requires syntax support
	if !exists("g:syntax_on")
		return
	endif

	def IsCode(): bool
		var stx = synstack(line('.'), col('.'))->map('synIDattr(v:val, "name")')->join()
		return stx =~? 'markdownCodeBlock\|markdownHighlight'
	enddef
	def IsCodeDelimiter(): bool
		var stx = synstack(line('.'), col('.'))->map('synIDattr(v:val, "name")')->join()
		return stx =~? 'markdownCodeDelimiter'
	enddef

	cursor(line('.'), 1)

	if !IsCode() && !IsCodeDelimiter()
		if search('^\s*```', 'cW', line(".") + 500, 100) <= 0
			return
		endif
	elseif !IsCodeDelimiter() || (!IsCode() && IsCodeDelimiter())
		if search('^\s*```', 'bW') <= 0
			return
		endif
	endif

	var pos_start = line('.') + (inner ? 1 : 0)

	# Search for the code end.
	if search('^\s*```\s*$', 'W') <= 0
		return
	endif

	var pos_end = line('.') - (inner ? 1 : 0)

	exe $":{pos_end}"
	normal! V
	exe $":{pos_start}"
enddef

def Make()
	getcompletion("md2", "compiler")->popup_menu({
		pos: "center",
		title: "使用哪个编译器？",
		borderchars: get(g:, "popup_borderchars", ['─', '│', '─', '│', '┌', '┐', '┘', '└']),
		borderhighlight: get(g:, "popup_borderhighlight", ['Normal']),
		highlight: get(g:, "popup_highlight", 'Normal'),
		callback: (id, result) => {
			if result == -1 | return | endif
			execute "compiler" getwininfo(id)[0].bufnr->getbufoneline(result)
			silent :Make
		}})
enddef
