vim9script
# Name: vimfiles\pack\local\start\vim-notebook\autoload\notebook.vim
# Author: Mao-Yining <mao.yining@outlook.com>
# Desc: Note taking plugin

var config = {
	notes_path: '~/Documents/vault/journals/',
	template_dir: '~/Documents/vault/templates/',
	browseformat: '%f - %h [%r Refs] [%b B-Refs] %t',
	preview_command: 'pedit',
	completion_kind: '[zettelkasten]',
	browse_title_width: 30
}
g:notebook_config = config->extend(get(g:, 'notebook_config', {}))

const formatters: dict<func> = {
	'%r': (line: dict<any>): string => {
		return string(get(line, 'references', [])->len())
	},
	'%b': (line: dict<any>): string => {
		return string(get(line, 'back_references', [])->len())
	},
	'%f': (line: dict<any>): string => {
		return fnamemodify(get(line, 'file_name', ''), ':t')
	},
	'%h': (line: dict<any>): string => {
		var title = get(line, 'title', '')
		var title_width = strdisplaywidth(title)
		var max_width = get(config, 'browse_title_width', 50)

		if title_width < max_width
			return title .. repeat(' ', max_width - title_width)
		else
			var truncated = ''
			for char in title->split('\zs')
				if strdisplaywidth(truncated) + strdisplaywidth(char) <= max_width - 3
					truncated = truncated .. char
				else
					break
				endif
			endfor
			truncated = truncated .. '...'
			return truncated .. repeat(' ', max_width - strdisplaywidth(truncated))
		endif
	},
	'%d': (line: dict<any>): string => {
		return get(line, 'id', '')
	},
	'%t': (line: dict<any>): string => {
		var tags: list<string> = []
		var seen_tags: dict<bool> = {}

		for tag in get(line, 'tags', [])
			var tag_name = get(tag, 'name', '')
			if !empty(tag_name) && !has_key(seen_tags, tag_name)
				tags->add(tag_name)
				seen_tags[tag_name] = true
			endif
		endfor

		return join(tags, ' ')
	},
}

def EchoWarn(str: string)
	echohl WarningMsg
	echomsg str
	echohl NONE
enddef

def GetFormatKeys(format: string): list<string>
	var matches: list<string> = []
	var start = 0

	while start < len(format)
		var match_start = match(format, '%\a', start)
		if match_start == -1
			break
		endif

		var match_end = matchend(format, '%\a', start)
		var key = format[match_start : match_end - 1]
		matches->add(key)
		start = match_end
	endwhile

	return matches
enddef

export def Format(lines: list<dict<any>>, format_str: string): list<string>
	var formatted_lines: list<string> = []
	var modifiers = GetFormatKeys(format_str)

	for line in lines
		var result = format_str

		for modifier in modifiers
			if has_key(formatters, modifier)
				var value = formatters[modifier](line)
				result = substitute(result, modifier, value, 'g')
			endif
		endfor

		formatted_lines->add(result)
	endfor

	return formatted_lines
enddef

def SetQfList(lines: list<string>, action: string, bufnr: number,
		use_loclist: bool, what: dict<any> = {})
	var local_efm = getbufvar(bufnr, '&errorformat', '')
	what.efm = what->get('efm', local_efm)

	if use_loclist
		setloclist(bufnr, lines, action, what)
	else
		setqflist(lines, action, what)
	endif
enddef

def GetAllTags(_lookup_tag = null_string): list<dict<any>>
	var lookup_tag = _lookup_tag
	if !empty(lookup_tag)
		lookup_tag = lookup_tag->substitute('\\<', '', 'g')
		lookup_tag = lookup_tag->substitute('\\>', '', 'g')
	endif

	var tags = GetTags()
	if !empty(lookup_tag)
		var filtered_tags: list<dict<any>> = []
		for tag in tags
			if match(tag.name, lookup_tag) != -1
				filtered_tags->add(tag)
			endif
		endfor
		return filtered_tags
	endif

	return tags
enddef

def GenerateNoteId(date: dict<any> = {}): string
	const note_time = {
		year: get(date, 'year', strftime("%Y")->str2nr()),
		month: get(date, 'month', strftime("%m")->str2nr()),
		day: get(date, 'day', strftime("%d")->str2nr()),
		hour: get(date, 'hour', strftime("%H")->str2nr()),
		min: get(date, 'min', strftime("%M")->str2nr()),
		sec: get(date, 'sec', strftime("%S")->str2nr()),
	}

	const time_str = printf("%04d-%02d-%02d-%02d-%02d-%02d",
		note_time.year, note_time.month, note_time.day,
		note_time.hour, note_time.min, note_time.sec)
	return time_str
enddef

var complete_tags = false

export def CompleteFunc(find_start: number, base: string): any
	if find_start == 1 && empty(base)
		var pos = getcurpos()
		var line = getline('.')
		var line_to_cursor = line[ : pos[2] - 1]

		if match(line_to_cursor, '\\s#\\k*$') != -1
			complete_tags = true
			return match(line_to_cursor, '#\\k*$')
		elseif match(line_to_cursor, '^#\\k*$') != -1
			complete_tags = true
			return match(line_to_cursor, '#\\k*$')
		else
			complete_tags = false
			return match(line_to_cursor, '\\k*$')
		endif
	endif

	var words: list<dict<any>> = []

	if complete_tags
		var tags = GetTags()
		var temp: dict<bool> = {}
		for tag in tags
			temp[tag.name] = true
		endfor

		for tag_name in keys(temp)
			if match(tag_name, base) != -1
				words->add({
					word: tag_name,
					abbr: tag_name,
					dup: 0,
					empty: 0,
					kind: config.completion_kind,
					icase: 1,
				})
			endif
		endfor
	else
		var notes = GetNotes()
		notes = notes->filter((_, note) => {
			var title = get(note, 'title', '')
			return match(title, base) != -1
		})

		for note in notes
			words->add({
				word: note.id,
				abbr: note.title,
				dup: 0,
				empty: 0,
				kind: config.completion_kind,
				icase: 1,
			})
		endfor
	endif

	return words
enddef

export def SetNoteId(bufnr: number, date: dict<any> = {})
	const id = GenerateNoteId(date)
	if !empty(id)
		execute 'file' id .. '.md'
		setbufvar(bufnr, '&filetype', 'markdown')
	else
		echo "There's already a note with the same ID."
	endif
enddef

export def TagFunc(pattern: string, flags: string, info: dict<any>): any
	var in_insert = match(flags, 'i') != -1
	var pattern_provided = pattern != '\\<\\k\\k' || pattern == '*'

	var all_tags: list<dict<any>>
	if pattern_provided
		all_tags = GetAllTags(pattern)
	else
		all_tags = GetAllTags()
	endif

	var tags: list<dict<any>> = []
	for tag in all_tags
		tags->add({
			name: substitute(tag.name, '#', '', 'g'),
			filename: tag.file_name,
			cmd: string(tag.linenr),
			kind: 'zettelkasten',
		})
	endfor

	if !in_insert
		var notes = GetNotes()
		for note in notes
			if match(note.id, pattern) != -1 || !pattern_provided
				tags->add({
					name: note.id,
					filename: note.file_name,
					cmd: '1',
					kind: 'zettelkasten',
				})
			endif
		endfor
	endif

	if !empty(tags)
		return tags
	endif

	return null
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

export def GetBackReferences(note_id: string): list<dict<any>>
	var note = GetNote(note_id)
	if note == null
		return []
	endif

	var title_cache: dict<string> = {}
	def GetTitle(id: string): string
		if has_key(title_cache, id)
			return title_cache[id]
		endif

		var n = GetNote(id)
		if n != null
			title_cache[id] = n.title
		endif
		return title_cache->get(id, '')
	enddef

	var references: list<dict<any>>
	for ref in note.back_references
		references->add({
			id: ref.id,
			linenr: ref.linenr,
			title: ref.title,
			file_name: ref.file_name,
		})
	endfor

	return references
enddef

export def ShowBackReferences(cword: string, use_loclist: bool = false)
	var references = GetBackReferences(cword)
	if empty(references)
		echo 'No back references found.'
		return
	endif

	var lines: list<string> = []
	for ref in references
		var line = fnamemodify(ref.file_name, ':.')
			.. ':' .. ref.linenr .. ': ' .. ref.title
		lines->add(line)
	endfor

	SetQfList([], ' ', bufnr(), use_loclist, {
		title: '[[' .. cword .. ']] References',
		lines: lines,
	})

	if use_loclist
		execute 'botright lopen | wincmd p'
	else
		execute 'botright copen | wincmd p'
	endif
enddef

export def GetToc(note_id: string, format: string = '- [%h](%d)'): list<string>
	var references = GetBackReferences(note_id)
	var lines: list<dict<any>> = []

	for note in references
		lines->add({
			file_name: note.file_name,
			id: note.id,
			title: note.title,
		})
	endfor

	return Format(lines, format)
enddef

export def GetNoteBrowserContent(opt: dict<any>): list<string>
	if empty(config.notes_path)
		echo "'notes_path' option is required for note browsing."
		return []
	endif

	var filter_tags: dict<bool> = {}
	for tag in get(opt, 'tags', [])
		filter_tags[tag] = true
	endfor

	var all_notes = GetNotes()
	var lines: list<dict<any>> = []

	for note in all_notes
		var has_tag = false
		if empty(get(opt, 'tags', []))
			has_tag = true
		else
			for tag in get(note, 'tags', [])
				if has_key(filter_tags, tag.name)
					has_tag = true
					break
				endif
			endfor
		endif

		if has_tag
			lines->add({
				file_name: note.file_name,
				id: note.id,
				references: note.references,
				back_references: note.back_references,
				tags: note.tags,
				title: note.title,
			})
		endif
	endfor

	if has_key(opt, 'date')
		lines = lines->filter((_, v) => {
			var note_date = split(v.id, '-')->map((_, x) => str2nr(x))

			if has_key(opt.date, 'year') && note_date[0] != opt.date.year
				return false
			endif
			if has_key(opt.date, 'month') && note_date[1] != opt.date.month
				return false
			endif
			if has_key(opt.date, 'day') && note_date[2] != opt.date.day
				return false
			endif
			return true
		})
	endif

	return Format(lines, config.browseformat)
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

export def NewNote(opt: dict<any> = {})
	var options = extend({}, opt, 'force')
	botright new
	var buf = bufnr()
	var notes_path = config.notes_path
	if !empty(notes_path)
		if !isdirectory(notes_path)
			notes_path->mkdir('p')
		endif
		execute 'lcd' notes_path
	endif

	if has_key(options, 'template')
		const template_content = readfile(options.template)
		setline(1, template_content)
	else
		normal! ggI# New Note
	endif

	var date = {}
	if has_key(options, 'date')
		date = options.date
	endif

	SetNoteId(buf, date)
	normal! $
enddef

# 定义常量
const TITLE_PATTERN = '# .\+'
const ZK_ID_PATTERN = '\d\+-\d\+-\d\+-\d\+-\d\+-\d\+'
const ZK_FILE_NAME_PATTERN = '\d\+-\d\+-\d\+-\d\+-\d\+-\d\+\.md'

# 缓存变量
var note_cache_with_file_path: dict<any> = {}
var note_cache_with_id: dict<any> = {}

# 在指定文件夹中获取所有 Zettelkasten 笔记文件
def GetFiles(folder: string): list<string>
	var files_str = globpath(folder, '*.md', 0, 1)
	var files: list<string> = []

	for file in files_str
		if match(file, ZK_FILE_NAME_PATTERN) != -1
			files->add(file)
		endif
	endfor

	return files
enddef

# 从行中提取引用
def ExtractReferences(line: string, linenr: number): list<dict<any>>
	var references: list<dict<any>> = []
	var pattern = '\[\[' .. ZK_ID_PATTERN .. '\]\]'

	var start = 0
	while start < len(line)
		var match_start = line->match(pattern, start)
		if match_start == -1
			break
		endif

		var match_end = line->matchend(pattern, start)
		var ref = line[match_start : match_end - 1]
		ref = trim('[]')

		references->add({ id: ref, linenr: linenr })
		start = match_end
	endwhile

	return references
enddef

def ExtractBackReferences(notes: list<dict<any>>, note_id: string): list<dict<any>>
	var back_references: list<dict<any>>

	for note in notes
		if note.id == note_id
			continue
		endif

		for ref in note.references
			if ref.id == note_id
				back_references->add({
					id: note.id,
					title: note.title,
					file_name: note.file_name,
					linenr: ref.linenr,
				})
				break
			endif
		endfor
	endfor

	return back_references
enddef

# 从行中提取标签
def ExtractTags(line: string, linenr: number): list<dict<any>>
	var tags: list<dict<any>> = []
	var tag_pattern = '#\a\w*\(-\w\+\)*'

	var start = 0
	while start < len(line)
		var match_start = match(line, tag_pattern, start)
		if match_start == -1
			break
		endif

		# 检查标签前的字符
		var prev_char = match_start > 0 ? line[match_start - 1] : ''
		var tag: string
		if empty(prev_char) || prev_char == ' '
			tag = matchstr(line, tag_pattern, start)
			tags->add({ linenr: linenr, name: tag })
		endif

		start = match_start + len(tag)
	endwhile

	return tags
enddef

# 获取笔记信息
def GetNoteInformation(file_path: string): dict<any>
	const last_modified = '%Y-%m-%d.%H:%M:%S'->strftime(getftime(file_path))

	if note_cache_with_file_path->has_key(file_path) &&
			note_cache_with_file_path[file_path].last_modified == last_modified
		return note_cache_with_file_path[file_path]
	endif

	if !filereadable(file_path)
		return null_dict
	endif
	const lines = readfile(file_path)

	var info = {
		id: file_path->matchstr(ZK_ID_PATTERN),
		title: '',
		file_name: file_path,
		last_modified: last_modified,
		tags: [],
		references: [],
		back_references: [],
	}
	var linenr = 0
	for line in lines
		linenr += 1
		if empty(line)
			continue
		endif

		if empty(info.title) && line[0] ==# '#'
			info.title = line->matchstr(TITLE_PATTERN)
		endif

		const refs = ExtractReferences(line, linenr)
		if !empty(refs)
			info.references->extend(refs)
		endif

		const tags = ExtractTags(line, linenr)
		if !empty(tags)
			info.tags->extend(tags)
		endif
	endfor

	if !empty(info.id)
		note_cache_with_file_path[file_path] = info
		note_cache_with_id[info.id] = info
	endif

	return info
enddef

export def GetNote(id: string): dict<any>
	if note_cache_with_id->has_key(id)
		return note_cache_with_id[id]
	endif
	GetNotes()
	if note_cache_with_id->has_key(id)
		return note_cache_with_id[id]
	endif
	return {}
enddef

export def GetNotes(): list<dict<any>>
	const folder = config.notes_path
	const files = GetFiles(folder)

	var all_notes: list<dict<any>>
	for file in files
		const note = GetNoteInformation(file)
		if !empty(note)
			all_notes->add(note)
		endif
	endfor

	for note in all_notes
		if empty(note.id)
			continue
		endif
		note.back_references = ExtractBackReferences(all_notes, note.id)
	endfor

	return all_notes
enddef

export def GetTags(): list<dict<any>>
	var notes = GetNotes()
	var tags: list<dict<any>>
	var seen_tags: dict<bool>
	for note in notes
		if empty(note.tags)
			continue
		endif

		for tag in note.tags
			var tag_key = tag.name .. '@' .. tag.linenr .. '@' .. note.file_name
			if !has_key(seen_tags, tag_key)
				tags->add({
					linenr: tag.linenr,
					name: tag.name,
					file_name: note.file_name,
				})
				seen_tags[tag_key] = true
			endif
		endfor
	endfor

	return tags
enddef

export def Browse(opt: dict<any> = {})
	const options = extend({ tags: [] }, opt)
	const bufnr = bufadd("note://browser")
	exe "buffer" bufnr
	setl modifiable
	GetNoteBrowserContent({
		tags: options.tags,
		date: options->get("date", {}),
	})->setline(1)
	setl filetype=notebrowser
	setl nomodifiable
enddef

# Tag Tree {{{
var folded_keys: dict<bool>

def UniqueStringTable(t: list<string>): list<string>
	var temp: dict<bool> = {}
	for item in t
		temp[item] = true
	endfor

	var result: list<string> = []
	for key in keys(temp)
		result->add(key)
	endfor

	return result
enddef

def SortTags(tags: list<string>): list<string>
	var atags: dict<list<string>> = {}

	for tag in sort(tags)
		var k = toupper(tag[1])  # 获取标签的第二个字符（第一个是 #）
		if has_key(atags, k)
			atags[k]->add(tag)
		else
			atags[k] = [tag]
		endif
	endfor

	var lines: list<string> = []

	for k in atags->keys()->sort()
		if len(atags[k]) > 0
			if !get(folded_keys, k, false)
				lines->add('▼ ' .. k)
				for t in atags[k]
					lines->add('  ' .. t)
				endfor
			else
				lines->add('▶ ' .. k)
			endif
		endif
	endfor

	return lines
enddef

def UpdateSidebarContext()

	setlocal modifiable

	var result = GetTags()
	var lines: list<string> = []

	for tag in result
		lines->add(tag.name)
	endfor

	var unique_lines = lines->uniq()
	var sorted_lines = SortTags(unique_lines)

	deletebufline('%', 1, '$')
	setline(1, sorted_lines)

	setlocal nobuflisted
	setlocal nomodifiable

	normal! gg
enddef

export def OpenTagTree()
	execute ':30vsplit note://tags_tree'
	setlocal filetype=notetagstree
	folded_keys = {}
	UpdateSidebarContext()
enddef

export def ToggleFoldedKey()
	var line = getline('.')
	if len(line) < 5
		return
	endif

	var k = line[4]
	if has_key(folded_keys, k) && folded_keys[k]
		folded_keys[k] = false
	else
		folded_keys[k] = true
	endif

	UpdateSidebarContext()
enddef
# }}}
# vim:fdm=marker
