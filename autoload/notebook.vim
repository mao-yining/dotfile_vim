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

def EchoWarn(str: string)
	echohl WarningMsg
	echomsg str
	echohl NONE
enddef

export def KeywordExpr(word: string, opts: dict<bool>): list<string>
	if empty(word)
		return null_list
	endif

	const options = { preview_note: false, return_lines: false }->extend(opts)

	const note = GetNote(word)
	if note == null_dict
		EchoWarn('Cannot find note.')
		return null_list
	endif

	var lines: list<string>
	if options.preview_note && !options.return_lines
		execute config.preview_command note.file_name
	elseif options.preview_note && options.return_lines
		lines = readfile(note.file_name)
	else
		lines->add(note.title)
	endif

	return lines
enddef
export def HoverComplete(ArgLead: string, CmdLine: string, CursorPos: number): string
	if ArgLead =~ '^-'
		return ['-preview', '-return-lines']->join("\n")
	endif
	return null_string
enddef

export def InternalExecuteHoverCmd(...args: list<string>)
	var cword = ''
	for arg in args
		if arg != '-preview' && arg != '-return-lines'
			cword = arg
		endif
	endfor

	if empty(cword)
		cword = expand('<cword>')
	endif

	var lines = KeywordExpr(cword, {
		preview_note: index(args, '-preview') != -1,
		return_lines: index(args, '-return-lines') != -1,
	})

	if !empty(lines)
		echo join(lines, "\n")
	endif
enddef

export def Journal(date = {})
	botright new
	var journals_path = config.journals_path
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
	normal! $
enddef

def JournalTitle(date: dict<any> = {}): string
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

