vim9script
# Name: vimfiles\pack\local\start\vim-notebook\autoload\notebook.vim
# Author: Mao-Yining <mao.yining@outlook.com>
# Desc: Note taking plugin

var config = {
	journals_path: '~/Documents/vault/journals/',
	notes_path: '~/Documents/vault/notes/',
	journal_template: '~/Documents/vault/templates/journal.md',
	note_template: '~/Documents/vault/templates/idea.md',
}
g:notebook_config = config->extend(get(g:, 'notebook_config', {}))

export def Journal(date: dict<number> = {})
	botright new
	const journals_path = config.journals_path->fnamemodify(':p')
	if !empty(journals_path)
		if !isdirectory(journals_path)
			journals_path->mkdir('p')
		endif
		execute 'lcd' journals_path
	endif
	const title = JournalTitle(date)
	const file = title .. '.md'
	if file->filereadable()
		exe 'edit' file
	else
		exe 'edit' file
		if config.journal_template->fnamemodify(':p')->filereadable()
			readfile(config.journal_template->fnamemodify(':p'))
				->map((_, v) =>  v->substitute("{{title}}", title, ""))
				->setline(1)
		else
			setline(1, "# " .. title)
		endif
	endif
	const buf = bufnr()
	normal! jj
	startinsert!
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
	const folder = config.journals_path
	const allfiles = globpath(folder, $'{year}-{month}-*.md', 0, 1)
		->map((_, v) => v->fnamemodify(':t'))

	var files: list<string>
	for file in allfiles
		if file =~# JOURNAL_PATTERN
			files->add(file)
		endif
	endfor

	return files
enddef

export def Note()
	botright new
	const notes_path = config.notes_path->fnamemodify(':p')
	if !empty(notes_path)
		if !isdirectory(notes_path)
			notes_path->mkdir('p')
		endif
		execute 'lcd' notes_path
	endif
	const title = input("Note name: ")
	const file = title .. '.md'
	if file->filereadable()
		exe 'edit' file
	else
		exe 'edit' file
		if config.note_template->fnamemodify(':p')->filereadable()
			readfile(config.note_template->fnamemodify(':p'))
				->map((_, v) =>  v->substitute("{{title}}", title, ""))
				->setline(1)
		else
			setline(1, "# " .. title)
		endif
	endif
	const buf = bufnr()
	search('^# ')
	normal! jo
	startinsert
enddef
