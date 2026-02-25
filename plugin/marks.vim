vim9script

for r in 'abcdefghijklmnopqrstuvwxyz'
	sign_define($"'{r}", {text: $"'{r}", culhl: "CursorLineNr", texthl: "Identifier"})
	exe $"nnoremap m{r} <ScriptCmd>ToggleMark('{r}')<CR>"
endfor
for r in 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
	sign_define($"'{r}", {text: $"'{r}", culhl: "CursorLineNr", texthl: "Identifier"})
	exe $"nnoremap m{r} <ScriptCmd>ToggleGlobalMark('{r}')<CR>"
endfor

def ToggleMark(mark: string)
	const bufnr = bufnr()
	const current_line = line('.')
	if getmarklist(bufnr)->filter((_, v) => v.mark == "'" .. mark
			&& v.pos[1] == current_line)->empty()
		exe "mark" mark
	else
		exe "delmarks" mark
	endif
	UpdateMarks(bufnr)
enddef

def ToggleGlobalMark(mark: string)
	const bufnr = bufnr()
	const current_line = line('.')
	if getmarklist()->filter((_, v) => v.mark == "'" .. mark
			&& v.pos[0] == bufnr && v.pos[1] == current_line)->empty()
		exe "mark" mark
	else
		exe "delmarks" mark
	endif
	UpdateVisibleBuffersMarks()
enddef

def UpdateMarks(bufnr: number = bufnr())
	sign_unplace("marks", {buffer: bufnr})
	getmarklist()->filter((_, v) => v.pos[0] == bufnr) # global
		->extend(getmarklist(bufnr)) # local
		->filter((_, v) => v.mark =~ '[[:alpha:]]')
		->foreach((_, v) => {
			sign_place(0, "marks", v.mark, v.pos[0], {lnum: v.pos[1]})
		})
enddef

def UpdateVisibleBuffersMarks()
	getbufinfo({buflisted: 1, bufloaded: 1})->foreach((_, v) => {
		if !empty(v.windows)
			UpdateMarks(v.bufnr)
		endif
	})
enddef

augroup mark_signs
	au!
	au BufEnter,TextChanged * UpdateMarks()
	au CmdlineLeave : timer_start(0, (_) => UpdateVisibleBuffersMarks())
augroup END
