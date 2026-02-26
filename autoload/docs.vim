vim9script
# Name: autoload\docs.vim
# Author: Mao-Yining <mao.yining@outlook.com>
# Desc: Note taking plugin

export const root = expand($DOCS ?? '~/Documents/vault/')
const journals_path = root .. 'journals/'
const notes_path = root .. 'notes/'
const journal_template = root .. 'templates/journal.md'
const note_template = root .. 'templates/idea.md'

export def Journal(date: dict<number> = {})
	const path = journals_path->fnamemodify(':p')
	const title = JournalTitle(date)
	const file = path .. title .. '.md'
	if file->filereadable()
		EditInTab(file)
	else
		NewFile(file, journal_template)
	endif
enddef

def JournalTitle(date: dict<number>): string
	const note_time = {
		year: get(date, 'year', strftime("%Y")->str2nr()),
		month: get(date, 'month', strftime("%m")->str2nr()),
		day: get(date, 'day', strftime("%d")->str2nr()),
	}
	const time_str = printf("%04d-%02d-%02d",
		note_time.year, note_time.month, note_time.day)
	return time_str
enddef

const JOURNAL_PATTERN = '^\d\{4\}-\d\{2\}-\d\{2\}\.md$'

export def GetJournals(year = getftime("%Y"), month = getftime("%m")): list<string>
	const folder = journals_path
	const allfiles = printf('%04d-%02d-*.md', year, month)
		->globpath(folder, false, true)->map((_, v) => v->fnamemodify(':t'))

	var files: list<string>
	for file in allfiles
		if file =~# JOURNAL_PATTERN
			files->add(file)
		endif
	endfor

	return files
enddef

export def Note()
	const title = input("Note name: ")
	if title->empty()
		return
	endif
	const path = notes_path->fnamemodify(':p')
	const file = path .. title .. '.md'
	if file->filereadable()
		EditInTab(file)
	else
		NewFile(file, note_template)
	endif
enddef

def NewFile(file: string, template: string)
	EditInTab(file)
	const title = file->fnamemodify(":t:r")
	if template->fnamemodify(':p')->filereadable()
		readfile(template->fnamemodify(':p'))
			->map((_, v) =>  v->substitute("{{title}}", title, ""))
			->setline(1)
	else
		setline(1, "# " .. title)
	endif
	search('^# ')
	normal! jj$
enddef

export def EditInTab(name: string)
	var bufinfo = getbufinfo(name)
	const path = name->fnamemodify(':p:h')
	if !empty(path)
		if !isdirectory(path)
			path->mkdir('p')
		endif
		silent exe 'lcd' path
	endif
	if bufinfo->empty() || bufinfo[0].windows->empty()
		if bufname()->empty() && (&hidden || !&modified)
			exe "e" name
		else
			exe "tabe" name
		endif
	else
		win_gotoid(bufinfo[0].windows[0])
	endif
enddef
