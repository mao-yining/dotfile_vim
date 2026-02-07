vim9script
# --------- Constants ---------------------------------
const CODE_OPEN_REGEX = '\v((\\|\`)@<!|(\\\`))@<=\`(\`)@!\S'
const CODE_CLOSE_REGEX = '\v\S((\\|\`)@<!|(\\\`))@<=\`(\`)@!|^$'

# TODO It correctly pick \**, and it excludes ** and \*. It cannot distinguish
# is the pattern *\* is opening or closing, because you can easily have
# \S*\*\S, like foo*\*bar.
# You cannot distinguish if the first * is an opening or closing pattern
# without any additional information (read: internal state)
# regex cannot be used when internal states are involved.
# However, by using the information: A) The cursor is currently on a
# highlighted region B) The search direction, you should reliably (always?)
# hit the correct delimiter. Perhaps that could be mathematically proven.
const ITALIC_OPEN_REGEX = '\v((\\|\*)@<!|(\\\*))@<=\*(\*)@!\S'
const ITALIC_CLOSE_REGEX = '\v\S((\\|\*)@<!|(\\\*))@<=\*(\*)@!|^$'

const ITALIC_U_OPEN_REGEX = '\v((\\|_)@<!|(\\_))@<=_(_)@!\S'
const ITALIC_U_CLOSE_REGEX = '\v\S((\\|_)@<!|(\\_))@<=_(_)@!|^$'

const BOLD_OPEN_REGEX = '\v((\\|\*)@<!|(\\\*))@<=\*\*(\*)@!\S'
const BOLD_CLOSE_REGEX = '\v\S((\\|\*)@<!|(\\\*))@<=\*\*(\*)@!|^$'

const BOLD_U_OPEN_REGEX = '\v((\\|_)@<!|(\\_))@<=__(_)@!\S'
const BOLD_U_CLOSE_REGEX = '\v\S((\\|_)@<!|(\\_))@<=__(_)@!|^$'

const STRIKE_OPEN_REGEX = '\v((\\|\~)@<!|(\\\~))@<=\~\~(\~)@!\S'
const STRIKE_CLOSE_REGEX = '\v\S((\\|\~)@<!|(\\\~))@<=\~\~(\~)@!|^$'
# TODO: CODEBLOCK REGEX COULD BE IMPROVED
const CODEBLOCK_OPEN_REGEX = '^```'
const CODEBLOCK_CLOSE_REGEX = '^```$'
# TODO: QUOTEBLOCK REGEX COULD BE IMPROVED
const QUOTEBLOCK_OPEN_REGEX = '^\s*>\s\+'
const QUOTEBLOCK_CLOSE_REGEX = $'^\.*\({QUOTEBLOCK_OPEN_REGEX}\)\@!'

# TODO: investigate and match with syntax
const UNDERLINE_OPEN_REGEX = "<u\>"
const UNDERLINE_CLOSE_REGEX = "\\(</u\\_s*>\\|^$\\)"
# Of the form '[bla bla](https://example.com)' or '[bla bla][12]'
# TODO: if you only want numbers as reference, line [my page][11], then you
# have to replace the last part '\[[^]]+\]' with '\[\d+\]'
# TODO: I had to remove the :// at the end of each prefix because otherwise
# the regex won't work.

const URL_PREFIXES = [ 'https://', 'http://', 'ftp://', 'ftps://',
	'sftp://', 'telnet://', 'file://']

const URL_PREFIXES_REGEX = URL_PREFIXES
	->mapnew((_, val) => substitute(val, '\v(\w+):.*', '\1', ''))
	->join("\|")

const LINK_OPEN_REGEX = '\v\zs\[\ze[^]]+\]'
	.. $'(\(({URL_PREFIXES_REGEX}):[^)]+\)|\[[^]]+\])'
# TODO Differently of the other CLOSE regexes, the link CLOSE regex end up ON
# the last ] and not just before the match
const LINK_CLOSE_REGEX = '\v\[[^]]+\zs\]\ze'
	.. $'(\(({URL_PREFIXES_REGEX}):[^)]+\)|\[[^]]+\])'

const TEXT_STYLES_DICT = {
	markdownCode: {open_delim: '`', close_delim: '`',
		open_regex: CODE_OPEN_REGEX, close_regex: CODE_CLOSE_REGEX },

	# TODO on the delimiter synIDattr(synID(line("."), charcharcol("."), 1), "name")
	# return markdownCodeDelimiter instead of
	# markdownCodeBlockDelimiter. Perhaps it is a bug in vim-markdown. Hence, we
	# cannot include it here.
	# markdownCodeBlock: {open_delim: '```', close_delim: '```',
	# open_regex: CODEBLOCK_OPEN_REGEX, close_regex: CODEBLOCK_CLOSE_REGEX },

	markdownItalic: { open_delim: '*', close_delim: '*',
		open_regex: ITALIC_OPEN_REGEX, close_regex: ITALIC_CLOSE_REGEX },

	markdownItalicU: { open_delim: '_', close_delim: '_',
		open_regex: ITALIC_U_OPEN_REGEX, close_regex: ITALIC_U_CLOSE_REGEX },

	markdownBold: { open_delim: '**', close_delim: '**',
		open_regex: BOLD_OPEN_REGEX, close_regex: BOLD_CLOSE_REGEX },

	markdownBoldU: { open_delim: '__', close_delim: '__',
		open_regex: BOLD_U_OPEN_REGEX, close_regex: BOLD_U_CLOSE_REGEX },

	markdownStrike: { open_delim: '~~', close_delim: '~~',
		open_regex: STRIKE_OPEN_REGEX, close_regex: STRIKE_CLOSE_REGEX },

	markdownLinkText: { open_delim: '[', close_delim: ']',
		open_regex: LINK_OPEN_REGEX, close_regex: LINK_CLOSE_REGEX },

	markdownUnderline: { open_delim: '<u>', close_delim: '</u>',
		open_regex: UNDERLINE_OPEN_REGEX, close_regex: UNDERLINE_CLOSE_REGEX },
}

const LINK_OPEN_DICT = {[TEXT_STYLES_DICT.markdownLinkText.open_delim]:
TEXT_STYLES_DICT.markdownLinkText.open_regex}

# TODO on the delimiter synIDattr(synID(line("."), charcharcol("."), 1), "name")
# return markdownCodeDelimiter instead of
# markdownCodeBlockDelimiter. Perhaps it is a bug in vim-markdown. Hence, we
# cannot include it here.
const CODEBLOCK_OPEN_DICT = {'```': CODEBLOCK_OPEN_REGEX}
const CODEBLOCK_CLOSE_DICT = {'```': CODEBLOCK_CLOSE_REGEX}

const QUOTEBLOCK_OPEN_DICT = {'> ': QUOTEBLOCK_OPEN_REGEX}
const QUOTEBLOCK_CLOSE_DICT = {'> ': QUOTEBLOCK_CLOSE_REGEX}
# --------- End Constants ---------------------------------

var main_id = -1
var prompt_id = -1

var prompt_cursor = '▏'
var prompt_sign = '> '
var prompt_text = ''

var fuzzy_search = true

var popup_width = (&columns * 2) / 3
var links_popup_opts = {
	pos: 'center',
	border: [1, 1, 1, 1],
	borderchars:  ['─', '│', '─', '│', '├', '┤', '╯', '╰'],
	minwidth: popup_width,
	maxwidth: popup_width,
	scrollbar: 0,
	cursorline: 1,
	mapping: 0,
	wrap: 0,
	drag: 0,
}

var large_files_threshold = 0

const references_comment =
	"<!-- DO NOT REMOVE vim-markdown references DO NOT REMOVE-->"

# To account for multi-byte chars, I had to spend one afternoon with chat GPT
# to understand how the URLToPath and PathToURL function should look like.

def PercentDecode(s: string): string
	var result = ''
	var i = 0
	while i < len(s)
		if s[i] ==# '%'
			var bytes = []
			while i + 2 < len(s) && s[i] ==# '%'
				var hex = strpart(s, i + 1, 2)
				var n = str2nr(hex, 16)
				if n < 0 || n > 255
					break
				endif
				bytes->add(n)
				i += 3
			endwhile

			if !empty(bytes)
				# Convert list of bytes to blob, then decode blob to UTF-8 string
				var decoded_list = list2blob(bytes)->blob2str({'encoding': 'utf-8'})
				# blob2str returns a list of strings (split by newline bytes), join them safely
				var decoded_str = join(decoded_list, "\n")
				result ..= decoded_str
			endif
		else
			result ..= s[i]
			i += 1
		endif
	endwhile
	return result
enddef

export def URLToPath(url: string): string
	var rest = ''

	# Windows:
	if has('win32') || has('win64')
		rest = substitute(url, '^file:', '', '')
		# If it starts with a drive letter, like '///C:/', we remove the leading
		# '///'. Otherwise it is a UNC (like \\server\foo\bar) but that is already set
		if rest =~ '^///[A-Za-z]:/'
			rest = rest->trim('/', 1)
		endif
	else
		rest = substitute(url, '^file://', '', '')
	endif

	rest = PercentDecode(rest)

	if has('win32') || has('win64')
		# Convert forward slashes to backslashes on Windows
		rest = rest->tr('/', '\')
	endif

	return rest
enddef

export def PathToURL(path: string): string
	var rest = ''
	if has('win32') || has('win64')
		rest = path->substitute('\\', '/', 'g')
	else
		rest = path
	endif

	var utf8 = iconv(rest, &encoding, 'utf-8')
	var bytes = str2blob([utf8])
	if len(bytes) > 0 && bytes[len(bytes) - 1] == 0x0A
		call remove(bytes, len(bytes) - 1)
	endif

	var allowed = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-_.~/:'
	var encoded = ''
	for val in bytes
		if stridx(allowed, nr2char(val)) >= 0
			encoded ..= nr2char(val)
		else
			encoded ..= printf('%%%02X', val)
		endif
	endfor

	if has('win32') || has('win64')
		if rest =~ '^[A-Za-z]:/'
			return 'file:///' .. encoded
		else
			return 'file:' .. encoded
		endif
	else
		return 'file://' .. encoded
	endif
enddef

def GetFileSize(filename: string): number
	var filesize = ''
	# TODO: Using system() slow down significantly the opening and the file preview
	if filereadable(filename)
		if has('win32')
			filesize = system('powershell -NoProfile -ExecutionPolicy Bypass -Command '
				.. $'"(Get-Item \"{filename}\").length"')
		elseif has('unix') && system('uname') =~ 'Darwin'
			filesize = system($'stat -f %z {escape(filename, " ")}')
		elseif has('unix')
			filesize = system($'stat --format=%s {escape(filename, "  ")}')
		else
			Echowarn($"Cannot determine the size of {filename}")
			filesize = "-2"
		endif
	else
		Echoerr($"File {filename} is not readable")
		filesize = "-1"
	endif
	return filesize->substitute('\n', '', 'g')->str2nr()
enddef

def LastReferenceLine(): number
	# Return the last occurrence of reference of the form '[32]: ...'
	const saved_curpos = getcursorcharpos()
	cursor('$', 1)
	# Search backwards line starting with e.g. '[32]: '
	const lastline = search('^\s*\[\d\+\]:\s\+', 'bW')
	setpos('.', saved_curpos)
	return lastline
enddef

export def RefreshLinksDict(): dict<string>
	# Generate the b:markdown_extras_links by parsing the 'references_comment'
	# Section.
	#
	# b:markdown_extras_links is a dict where the keys are numbers and the
	# values are valid URLs, e.g. https://, file://, ...
	#
	# Note that URLs starting with file:// are converted back and forth from URL
	# to local paths within the script.

	# Cleanup the current b:markdown_extras_links
	var links_dict = {}
	const references_line = search($'^{references_comment}', 'nw')
	# UBA to check
	const last_reference_line = LastReferenceLine()
	const lastline = last_reference_line == 0 ? line('$') : last_reference_line

	if references_line != 0
		for l in range(references_line + 1, lastline + 1)
			var ref = getline(l)
			if !empty(ref)
				var key = ref->matchstr('\[\zs\d\+\ze\]')
				if !empty(key)
					var value = ref->matchstr('\[\d\+]:\s*\zs.*')
					if empty(value)
						value = trim(getline(l + 1))
					endif
					# echom 'key:' key
					# echom 'value:' value
					links_dict[key] = value
				endif
			endif
		endfor
	endif
	return links_dict
enddef

export def SearchLink(backwards: bool = false)
	const pattern = LINK_OPEN_DICT['[']
	if !backwards
		search(pattern)
	else
		search(pattern, 'b')
	endif
enddef

def GetLinkID(): number
	# When user add a new link, it either create a new ID and return it or it
	# just return an existing ID if the link already exists

	b:markdown_extras_links = RefreshLinksDict()

	var current_wildmenu = &wildmenu
	set nowildmenu
	var link = input("Create new link (you can use 'tab'): ", '', 'file')
	if empty(link)
		&wildmenu = current_wildmenu
		return 0
	endif
	&wildmenu = current_wildmenu

	if !IsURL(link)
		link = PathToURL(fnamemodify(link, ':p'))
	endif
	var reference_line = search($'^{references_comment}', 'nw')
	if reference_line == 0
		append(line('$'), ['', references_comment])
	endif
	var link_line = search(link, 'nw')
	var link_id = 0
	if link_line == 0
		# Entirely new link
		link_id = keys(b:markdown_extras_links)->map('str2nr(v:val)')->max() + 1
		b:markdown_extras_links[$'{link_id}'] = link
		# If it is the first link ever, leave a blank line
		if link_id == 1
			append(line('$'), '')
		endif
		const last_reference_line = LastReferenceLine()
		const lastline = last_reference_line == 0 ? line('$') : last_reference_line
		if lastline != 0
			append(lastline, $'[{link_id}]: {link}' )
		endif
	else
		# Reuse existing link
		var tmp = getline(link_line)->substitute('\v^\[(\d*)\].*', '\1', '')
		link_id = str2nr(tmp)
	endif
	return link_id
enddef

export def IsURL(link: string): bool
	for url_prefix in URL_PREFIXES
		if link =~ $'^{url_prefix}'
			return true
		endif
	endfor
	return false
enddef

def LinksPopupCallback(type: string,
		popup_id: number,
		idx: number,
		match_id: number
		)
	if idx > 0
		const selection = getbufline(winbufnr(popup_id), idx)[0]
		var link_id = -1
		if selection == "Create new link"
			link_id = GetLinkID()
			if link_id == 0
				matchdelete(match_id)
				return
			endif
		else
			const keys_from_value =
				KeysFromValue(b:markdown_extras_links, selection)
			# For some reason, b:markdown_extras_links may be empty or messed up
			if empty(keys_from_value)
				Echoerr('Reference not found')
				matchdelete(match_id)
				return
			endif
			link_id = str2nr(keys_from_value[0])
		endif

		SurroundSmart("markdownLinkText", type)

		# add link value
		search(']')
		execute $'norm! a[{link_id}]'
		if selection == "Create new link"
			norm! F]h
			if b:markdown_extras_links[link_id] =~ '^file://'
					&& !filereadable(URLToPath(b:markdown_extras_links[link_id]))
				exe $'edit {b:markdown_extras_links[link_id]}'
				# write
			endif
		endif
	endif
	matchdelete(match_id)
enddef

export def IsLink(): dict<list<list<number>>>
	# If the word under cursor is a link, then it returns info about
	# it. Otherwise it won't return anything.
	const range_info = IsInRange()
	if !empty(range_info) && keys(range_info)[0] == 'markdownLinkText'
		return range_info
	elseif synIDattr(synID(line("."), charcol("."), 1), "name") == 'markdownUrl'
		# Find beginning of the URL
		var a = [line('.'), 1]
		var b = searchpos(' ', 'nbW')
		var start_pos = [0, 0]
		if IsLess(a, b) && b != [0, 0]
			start_pos = [b[0], b[1] + 1]
		else
			start_pos = a
		endif

		# Find end of the URL
		a = searchpos(' ', 'nW')
		b = [line('.'), charcol('$') - 1]
		var end_pos = [0, 0]
		if IsLess(a, b) && a != [0, 0]
			end_pos = [a[0], a[1] - 1]
		else
			end_pos = b
		endif
		return {'markdownUrl': [start_pos, end_pos]}
	else
		return {}
	endif
enddef

def IsBinary(link: string): bool
	# Check if a file is binary
	var is_binary = false

	# Override if binary and not too large
	if filereadable(link)
		# Large file: open in a new Vim instance if
		const file_type = system($'file --brief -mime "{link}"')
		if executable('file') && file_type !~ '^ASCII text' && file_type !~ '^empty'
			is_binary = true
		# In case 'file' is not available, like in Windows, search for the NULL
		# byte. Guard if the file is too large
		elseif !empty(readfile(link)->filter('v:val =~# "\\%u0000"'))
			is_binary = true
		endif
	else
		Echoerr($"File {link} is not readable")
	endif

	return is_binary
enddef

export def ConvertLinks()
	const references_line = search($'^{references_comment}', 'nw')
	if references_line == 0
		append(line('$'), ['', references_comment])
	endif

	b:markdown_extras_links = RefreshLinksDict()
	# TODO this pattern is a bit flaky
	const pattern = '\[*\]\s\?('
	const saved_view = winsaveview()
	cursor(1, 1)
	var lA = -1
	var cA = -1
	var curr_pos = [lA, -cA]
	while curr_pos != [0, 0]
		curr_pos = searchpos(pattern, 'W')
		lA = curr_pos[0]
		cA = curr_pos[1]
		if strpart(getline(lA), cA, 2) =~ '('
			norm! f(l
			var link = GetTextObject('i(').text
			var link_id = keys(b:markdown_extras_links)
				->map((_, val) => str2nr(val))->max() + 1
			# Fix current line
			exe $"norm! ca([{link_id}]"

			# Fix dict
			b:markdown_extras_links[link_id] = link
			const last_reference_line = LastReferenceLine()
			const lastline = last_reference_line == 0 ? line('$') : last_reference_line
			if lastline != 0
				append(lastline, $'[{link_id}]: {link}' )
			endif
			# TODO Find last proper line
			# var line = search('\s*#\+\s*References', 'n') + 2
			# var lastline = -1
			# while getline(line) =~ '^\s*\[*\]: ' && line <= line('$')
			#   echom line
			#   if line == line('$')
			#     lastline = line - 1
			#   elseif getline(line) !~ '^\[*\]: '
			#     lastline = line - 1
			#     break
			#   endif
			#   line += 1
			# endwhile
			# append(lastline, $'[{link_id}]: {link}')
		endif
	endwhile
	winrestview(saved_view)
enddef


export def RemoveLink(range_info: dict<list<list<number>>> = {})
	const link_info = empty(range_info) ? IsLink() : range_info
	# TODO: it may not be the best but it works so far
	if !empty(link_info) && keys(link_info)[0] != 'markdownUrl'
		const saved_curpos = getcurpos()
		# Start the search from the end of the text-link
		norm! f]
		# Find the closest between [ and (
		var symbol = ''
		if searchpos('[', 'nW') == [0, 0]
			symbol = '('
		elseif searchpos('(', 'nW') == [0, 0]
			symbol = '['
		else
			symbol = IsLess(searchpos('[', 'nW'), searchpos('(', 'nW'))
				? '['
				: '('
		endif

		# Remove actual link
		search(symbol)
		exe $'norm! "_da{symbol}'

		# Remove text link - it is always between square brackets
		search(']', 'bc')
		norm! "_x
		search('[', 'bc')
		norm! "_x
		setcharpos('.', saved_curpos)
	endif
enddef

def ClosePopups()
	# This function tear down everything
	# popup_close(main_id, -1)
	# popup_close(prompt_id, -1)
	# TODO: this will clear any opened popup
	popup_clear()
	# RestoreCursor()
	prop_type_delete('PopupToolsMatched')
enddef

export def PopupFilter(id: number,
		key: string,
		slave_id: number,
		results: list<string>,
		match_id: number = -1,
		): bool

	var maxheight = popup_getoptions(slave_id).maxheight

	if key == "\<esc>"
		if match_id != -1
			matchdelete(match_id)
		endif
		ClosePopups()
		return true
	endif

	echo ''
	# You never know what the user can type... Let's use a try-catch
	try
		if key == "\<CR>"
			popup_close(slave_id, getcurpos(slave_id)[1])
			ClosePopups()
		elseif index(["\<Right>", "\<PageDown>"], key) != -1
			win_execute(slave_id, 'normal! ' .. maxheight .. "\<C-d>")
		elseif index(["\<Left>", "\<PageUp>"], key) != -1
			win_execute(slave_id, 'normal! ' .. maxheight .. "\<C-u>")
		elseif key == "\<Home>"
			win_execute(slave_id, "normal! gg")
		elseif key == "\<End>"
			win_execute(slave_id, "normal! G")
		elseif index(["\<tab>", "\<C-n>", "\<Down>", "\<ScrollWheelDown>"], key)
				!= -1
			var ln = getcurpos(slave_id)[1]
			win_execute(slave_id, "normal! j")
			if ln == getcurpos(slave_id)[1]
				win_execute(slave_id, "normal! gg")
			endif
		elseif index(["\<S-Tab>", "\<C-p>", "\<Up>", "\<ScrollWheelUp>"], key) !=
				-1
			var ln = getcurpos(slave_id)[1]
			win_execute(slave_id, "normal! k")
			if ln == getcurpos(slave_id)[1]
				win_execute(slave_id, "normal! G")
			endif
		# The real deal: take a single, printable character
		elseif key =~ '^\p$' || keytrans(key) ==# "<BS>" || key == "\<c-u>"
			if key =~ '^\p$'
				prompt_text ..= key
			elseif keytrans(key) ==# "<BS>"
				if strchars(prompt_text) > 0
					prompt_text = prompt_text[: -2]
				endif
			elseif key == "\<c-u>"
				prompt_text = ""
			endif

			popup_settext(id, $'{prompt_sign}{prompt_text}{prompt_cursor}')

			# What you pass to popup_settext(slave_id, ...) is a list of strings with
			# text properties attached, e.g.
			#
			# [
			#   { "text": "filename.txt",
			#     "props": [ {"col": 2, "length": 1, "type": "PopupToolsMatched"},
			#     ... ]
			#   },
			#   { "text": "another_file.txt",
			#     "props": [ {"col": 1, "length": 1, "type": "PopupToolsMatched"},
			#     ... ]
			#   },
			#   ...
			# ]
			#
			var filtered_results_full = []
			var filtered_results: list<dict<any>>

			if !empty(prompt_text)
				if fuzzy_search
					filtered_results_full = results->matchfuzzypos(prompt_text)
					var pos = filtered_results_full[1]
					filtered_results = filtered_results_full[0]
						->map((ii, match) => ({
							text: match,
							props: pos[ii]->copy()->map((_, col) => ({
								col: col + 1,
								length: 1,
								type: 'PopupToolsMatched'
							}))}))
				else
					filtered_results_full = copy(results)
						->map((_, text) => matchstrpos(text,
									\ '\V' .. $"{escape(prompt_text, '\')}"))
			->map((idx, match_info) => [results[idx], match_info[1],
				match_info[2]])

					filtered_results = copy(filtered_results_full)
						->map((_, val) => ({
							text: val[0],
							props: val[1] >= 0 && val[2] >= 0
								? [{
									type: 'PopupToolsMatched',
									col: val[1] + 1,
									end_col: val[2] + 1
								}]
								: []
						}))
						->filter("!empty(v:val.props)")
				endif
			endif

			var opts = popup_getoptions(id)
			var num_hits = !empty(filtered_results)
				? len(filtered_results)
				: len(results)
			popup_setoptions(id, opts)

			if !empty(prompt_text)
				popup_settext(slave_id, filtered_results)
			else
				popup_settext(slave_id, results)
			endif
		else
			Echowarn('Unknown key')
		endif
	catch
		ClosePopups()
		Echoerr('Internal error')
	endtry

	return true
enddef

export def ShowPromptPopup(slave_id: number,
		links: list<string>,
		title: string,
		match_id: number = -1
		)
	# This is the UI thing
	var slave_id_core_line = popup_getpos(slave_id).core_line
	var slave_id_core_col = popup_getpos(slave_id).core_col
	var slave_id_core_width = popup_getpos(slave_id).core_width

	# var base_title = $'{search_type}:'
	var opts = {
		title: title,
		minwidth: slave_id_core_width,
		maxwidth: slave_id_core_width,
		line: slave_id_core_line - 3,
		col: slave_id_core_col - 1,
		borderchars: ['─', '│', '─', '│', '╭', '╮', '╯', '╰'],
		border: [1, 1, 0, 1],
		mapping: 0,
		scrollbar: 0,
		wrap: 0,
		drag: 0,
	}

	# Filter
	opts.filter = (id, key) => PopupFilter(id, key, slave_id, links, match_id)

	prompt_text = ""
	prompt_id = popup_create([prompt_sign .. prompt_cursor], opts)
enddef

export def CreateLink(type: string = '')
	if !empty(synID(line("."), charcol("."), 1)->synIDattr("name"))
		return
	endif

	const references_line = search($'^{references_comment}', 'nw')
	if references_line == 0
		append(line('$'), ['', references_comment])
	endif

	if getcharpos("'[") == getcharpos("']")
		return
	endif

	b:markdown_extras_links = RefreshLinksDict()

	# line and column of point A
	var lA = line("'[")
	var cA = type == 'line' ? 1 : col("'[")

	# line and column of point B
	var lB = line("']")
	var cB = type == 'line' ? strchars(getline(lB)) : col("']")

	if getregion(getcharpos("'["), getcharpos("']"))[0] =~ '^\s*$'
		return
	endif

	# The regex reads:
	# Take all characters, including newlines, from (l0,c0) to (l1,c1 + 1)'
	const match_pattern = $'\%{lA}l\%{cA}c\_.*\%{lB}l\%{cB + 1}c'
	const match_id = matchadd('Changed', match_pattern)
	redraw

	links_popup_opts.callback =
		(popup_id, idx) => LinksPopupCallback(type, popup_id, idx, match_id)

	var links = values(b:markdown_extras_links)->insert("Create new link")
	var popup_height = min([len(links), (&lines * 2) / 3])
	links_popup_opts.minheight = popup_height
	links_popup_opts.maxheight = popup_height
	main_id = popup_create(links, links_popup_opts)

	# if len(links) > 1
	ShowPromptPopup(main_id, links, " links: ", match_id)
	# endif
enddef

# -------- Preview functions --------------------------------
def PreviewWinFilterKey(previewWin: number, key: string): bool
	var keyHandled = false

	if key == "\<C-E>"
			|| key == "\<C-D>"
			|| key == "\<C-F>"
			|| key == "\<PageDown>"
			|| key == "\<C-Y>"
			|| key == "\<C-U>"
			|| key == "\<C-B>"
			|| key == "\<PageUp>"
			|| key == "\<C-Home>"
			|| key == "\<C-End>"
		# scroll the hover popup window
		win_execute(previewWin, $'normal! {key}')
		keyHandled = true
	endif

	if key == "\<Esc>"
		previewWin->popup_close()
		keyHandled = true
	endif

	return keyHandled
enddef

def GetFileContent(filename: string): list<string>
	var file_content = []
	if bufexists(filename)
		file_content = getbufline(filename, 1, '$')
	elseif filereadable($'{filename}')
		file_content = readfile($'{filename}')
	else
		file_content = ["Can't preview the file!", "Does the file exist?"]
	endif
	var title = [filename, '']
	return extend(title, file_content)
enddef

export def PreviewPopup()
	b:markdown_extras_links = RefreshLinksDict()

	var previewText = []
	var link_name = ''
	const saved_curpos = getcurpos()
	const link_info = IsLink()
	# CASE 1: on an alias
	if !empty(link_info) && keys(link_info)[0] != 'markdownUrl'
		# Search from the current cursor position to the end of line
		# Start the search from the end of the text-link
		norm! f]
		# Find the closest between [ and (
		var symbol = ''
		if searchpos('[', 'nW') == [0, 0]
			symbol = '('
		elseif searchpos('(', 'nW') == [0, 0]
			symbol = '['
		else
			symbol = IsLess(searchpos('[', 'nW'), searchpos('(', 'nW'))
				? '['
				: '('
		endif

		exe $"norm! f{symbol}l"

		var link_id = ''
		if symbol == '['
			b:markdown_extras_links = RefreshLinksDict()
			link_id = GetTextObject('i[').text
			link_name = b:markdown_extras_links[link_id]
		else
			link_name = GetTextObject('i(').text
		endif
	# CASE 2: on an actual link, like those in the reference Section
	elseif !empty(link_info) && keys(link_info)[0] == 'markdownUrl'
		const link_interval = values(link_info)[0]
		const start = link_interval[0][1] - 1
		const length = link_interval[1][1] - link_interval[0][1] + 1
		link_name = strcharpart(getline('.'), start, length)
	endif

	if !empty(link_name)
		# TODO At the moment only .md files have syntax highlight.
		var refFiletype = $'{fnamemodify(link_name, ":e")}' == 'md'
			? 'markdown'
			: 'text'
		const file_size = !IsURL(link_name) && large_files_threshold > 0
			? GetFileSize(link_name)
			: 0
		if link_name !~ '^file://'
				|| (filereadable(link_name) && file_size > large_files_threshold)
			previewText = [link_name]
			refFiletype = 'text'
		else
			previewText = GetFileContent(URLToPath(link_name))
		endif

		popup_clear()
		var winid = previewText->popup_atcursor({moved: 'any',
			close: 'click',
			fixed: true,
			maxwidth: 80,
			maxheight: (&lines * 2) / 3,
			border: [0, 1, 0, 1],
			borderchars: [' '],
			filter: PreviewWinFilterKey})

		# TODO: Set syntax highlight
		# if !IsURL(link_name)
		#   var old_synmaxcol = &synmaxcol
		#   &synmaxcol = 300
		#   var buf_extension = $'{fnamemodify(link_name, ":e")}'
		#   var found_filetypedetect_cmd =
		#     autocmd_get({group: 'filetypedetect'})
		#     ->filter($'v:val.pattern =~ "*\\.{buf_extension}$"')
		#   echom found_filetypedetect_cmd
		#   var set_filetype_cmd = ''
		#   if empty(found_filetypedetect_cmd)
		#     if index([$"{$HOME}/.vimrc", $"{$HOME}/.gvimrc"], expand(link_name)) != -1
		#      set_filetype_cmd = '&filetype = "vim"'
		#     else
		#      set_filetype_cmd = '&filetype = ""'
		#     endif
		#   else
		#     set_filetype_cmd = found_filetypedetect_cmd[0].cmd
		#   endif
		#   win_execute(winid, set_filetype_cmd)
		#   &synmaxcol = old_synmaxcol
		# endif

		win_execute(winid, $"setlocal ft={refFiletype}")
		setcharpos('.', saved_curpos)
	endif
enddef

def Echoerr(msg: string)
	echohl ErrorMsg | echom $'[markdown.vim] {msg}' | echohl None
enddef

def Echowarn(msg: string)
	echohl WarningMsg | echom $'[markdown.vim] {msg}' | echohl None
enddef

def KeysFromValue(dict: dict<string>, target_value: string): list<string>
	# Given a value, return all the keys associated to it
	return keys(filter(copy(dict), $'v:val == "{escape(target_value, "\\")}"'))
enddef

export def RemoveSurrounding(range_info: dict<list<list<number>>> = {})
	const style_interval = empty(range_info) ? IsInRange() : range_info
	if !empty(style_interval)
		const style = keys(style_interval)[0]
		const interval = values(style_interval)[0]

		# Remove left delimiter
		const lA = interval[0][0]
		const cA = interval[0][1]
		const lineA = getline(lA)
		var newline = strcharpart(lineA, 0,
					\ cA - 1 - strchars(TEXT_STYLES_DICT[style].open_delim))
					\ .. strcharpart(lineA, cA - 1)
		setline(lA, newline)

		# Remove right delimiter
		const lB = interval[1][0]
		var cB = interval[1][1]

		# Update cB.
		# If lA == lB, then The value of cB may no longer be valid since
		# we shortened the line
		if lA == lB
			cB = cB - strchars(TEXT_STYLES_DICT[style].open_delim)
		endif

		# Check if you hit a delimiter or a blank line OR if you hit a delimiter
		# but you also have a blank like
		# If you have open intervals (as we do), then cB < lenght_of_line, If
		# not, then don't do anything. This behavior is compliant with
		# vim-surround
		const lineB = getline(lB)
		if  cB < strchars(lineB)
			# You have delimters
			newline = strcharpart(lineB, 0, cB)
						\ .. strcharpart(lineB,
						\ cB + strchars(TEXT_STYLES_DICT[style].close_delim))
		else
			# You hit the end of paragraph
			newline = lineB
		endif
		setline(lB, newline)
	endif
enddef

export def SurroundSmart(style: string, type: string = '')
	# It tries to preserve the style.
	# In general, you may want to pass constant.TEXT_STYLES_DICT as a parameter.

	def RemoveDelimiters(to_overwrite: string): string
		# Used for removing all the delimiters between A and B.

		var overwritten = to_overwrite

		# This is needed to remove all existing text-styles between A and B, i.e. we
		# want to override existing styles.
		# Note that we don't want to remove links between A and B
		const styles_to_remove = keys(TEXT_STYLES_DICT)
			->filter("v:val !~ '\\v(markdownLinkText)'")

		for k in styles_to_remove
			# Remove existing open delimiters
			var regex = TEXT_STYLES_DICT[k].open_regex
			var to_remove = TEXT_STYLES_DICT[k].open_delim
			overwritten = overwritten
				->substitute(regex, (m) => substitute(m[0], $'\V{to_remove}', '', 'g'), 'g')

			# Remove existing close delimiters
			regex = TEXT_STYLES_DICT[k].close_regex
			to_remove = TEXT_STYLES_DICT[k].close_delim
			overwritten = overwritten
				->substitute(regex, (m) => substitute(m[0], $'\V{to_remove}', '', 'g'), 'g')
		endfor
		return overwritten
	enddef

	if getcharpos("'[") == getcharpos("']")
		return
	endif

	if index(keys(TEXT_STYLES_DICT), style) == -1
		Echoerr($'Style "{style}" not found in dict')
		return
	endif

	var open_delim = TEXT_STYLES_DICT[style].open_delim
	var open_regex = TEXT_STYLES_DICT[style].open_regex

	var close_delim = TEXT_STYLES_DICT[style].close_delim
	var close_regex = TEXT_STYLES_DICT[style].close_regex

	# line and column of point A
	var lA = line("'[")
	var cA = type == 'line' ? 1 : charcol("'[")

	# line and column of point B
	var lB = line("']")
	var cB = type == 'line' ? strchars(getline(lB)) : charcol("']")

	# -------- SMART DELIMITERS BEGIN ---------------------------
	# We check conditions like the following and we adjust the style
	# delimiters
	# We assume that the existing style ranges are (C,D) and (E,F) and we want
	# to place (A,B) as in the picture
	#
	# -E-------A------------
	# ------------F---------
	# ------------C------B--
	# --------D-------------
	#
	# We want to get:
	#
	# -E------FA------------
	# ----------------------
	# ------------------BC--
	# --------D-------------
	#
	# so that all the styles are visible

	# Check if A falls in an existing interval
	setcursorcharpos(lA, cA)
	var old_right_delimiter = ''
	var found_interval = IsInRange()
	if !empty(found_interval)
		var found_style = keys(found_interval)[0]
		old_right_delimiter = TEXT_STYLES_DICT[found_style].open_delim
	endif

	# Try to preserve overlapping ranges by moving the delimiters.
	# For example. If we have the pairs (C, D) and (E,F) as it follows:
	# ------C-------D------E------F
	#  and we want to add (A, B) as it follows
	# ------C---A---D-----E--B---F
	#  then the results becomes a mess. The idea is to move D before A and E
	#  after E, thus obtaining:
	# ------C--DA-----------BE----F
	#
	# TODO:
	# If you don't want to try to automatically adjust existing ranges, then
	# remove 'old_right_delimiter' and 'old_left_limiter' from what follows,
	# AND don't remove anything between A and B
	#
	# TODO: the following is specifically designed for markdown, so if you use
	# for other languages, you may need to modify it!
	#
	var toA = ''
	if !empty(found_interval) && old_right_delimiter != open_delim
		toA = strcharpart(getline(lA), 0, cA - 1)->substitute('\s*$', '', '')
			.. $'{old_right_delimiter} {open_delim}'
	elseif !empty(found_interval) && old_right_delimiter == open_delim
		# If the found interval is a text style equal to the one you want to set,
		# i.e. you would end up in adjacent delimiters like ** ** => Remove both
		toA = strcharpart(getline(lA), 0, cA - 1)
	else
		# Force space
		toA = strcharpart(getline(lA), 0, cA - 1) .. open_delim
	endif

	# Check if B falls in an existing interval
	setcursorcharpos(lB, cB)
	var old_left_delimiter = ''
	found_interval = IsInRange()
	if !empty(found_interval)
		var found_style = keys(found_interval)[0]
		old_left_delimiter = TEXT_STYLES_DICT[found_style].close_delim
	endif

	var fromB = ''
	if !empty(found_interval) && old_left_delimiter != close_delim
		# Move old_left_delimiter "outside"
		fromB = $'{close_delim} {old_left_delimiter}'
			.. strcharpart(getline(lB), cB)->substitute('^\s*', '', '')
	elseif !empty(found_interval) && old_left_delimiter == close_delim
		fromB = strcharpart(getline(lB), cB)
	else
		fromB = close_delim .. strcharpart(getline(lB), cB)
	endif

	# ------- SMART DELIMITERS PART END -----------
	# We have compute the partial strings until A and the partial string that
	# leaves B. Existing delimiters are set.
	# Next, we have to adjust the text between A and B, by removing all the
	# possible delimiters left between them.


	# If on the same line
	if lA == lB
		# Overwrite everything that is in the middle
		var A_to_B = ''
		A_to_B = strcharpart(getline(lA), cA - 1, cB - cA + 1)

		# Overwrite existing styles in the middle by removing old delimiters
		if style != 'markdownCode'
			A_to_B = RemoveDelimiters(A_to_B)
		endif

		# Set the whole line
		setline(lA, toA .. A_to_B .. fromB)
	else
		# Set line A
		var afterA = strcharpart(getline(lA), cA - 1)

		if style != 'markdownCode'
			afterA = RemoveDelimiters(afterA)
		endif

		var lineA = toA .. afterA
		setline(lA, lineA)

		# Set line B
		var beforeB = strcharpart(getline(lB), 0, cB)

		if style != 'markdownCode'
			beforeB = RemoveDelimiters(beforeB)
		endif

		var lineB = beforeB .. fromB
		setline(lB, lineB)

		# Fix intermediate lines
		var ii = 1
		while lA + ii < lB
			var middleline = getline(lA + ii)

			if style != 'markdownCode'
				middleline = RemoveDelimiters(middleline)
			endif

			setline(lA + ii, middleline)
			ii += 1
		endwhile
	endif

enddef

export def IsLess(l1: list<number>, l2: list<number>): bool
	# Lexicographic comparison on common prefix, i.e.for two vectors in N^n and
	# N^m you compare their projections onto the smaller subspace.

	var min_length = min([len(l1), len(l2)])
	var result = false

	for ii in range(min_length)
		if l1[ii] < l2[ii]
			result = true
			break
		elseif l1[ii] > l2[ii]
			result = false
			break
		endif
	endfor
	return result
enddef

export def IsGreater(l1: list<number>, l2: list<number>): bool
	# Lexicographic comparison on common prefix, i.e.for two vectors in N^n and
	# N^m you compare their projections onto the smaller subspace.

	var min_length = min([len(l1), len(l2)])
	var result = false

	for ii in range(min_length)
		if l1[ii] > l2[ii]
			result = true
			break
		elseif l1[ii] < l2[ii]
			result = false
			break
		endif
	endfor
	return result
enddef

export def IsEqual(l1: list<number>, l2: list<number>): bool
	var min_length = min([len(l1), len(l2)])
	return l1[: min_length - 1] == l2[: min_length - 1]
enddef

export def IsBetweenMarks(A: string, B: string): bool
	var cursor_pos = getcharpos(".")
	var A_pos = getcharpos(A)
	var B_pos = getcharpos(B)

	if IsGreater(A_pos, B_pos)
		var tmp = B_pos
		B_pos = A_pos
		A_pos = tmp
	endif

	# Check 'A_pos <= cursor_pos <= B_pos'
	var result = (IsGreater(cursor_pos, A_pos) || IsEqual(cursor_pos, A_pos))
		&& (IsGreater(B_pos, cursor_pos) || IsEqual(B_pos, cursor_pos))

	return result
enddef

export def IsInRange(): dict<list<list<number>>>
	# Return a dict like {'markdownCode': [[21, 19], [22, 21]]}.
	# The returned intervals are open.
	#
	# NOTE: Due to that bundled markdown syntax file returns 'markdownItalic' and
	# 'markdownBold' regardless is the delimiters are '_' or '*', we need the
	# StarOrUnrescore() function

	def StarOrUnderscore(text_style: string): string
		var text_style_refined = ''

		var tmp_star = $'TEXT_STYLES_DICT.{text_style}.open_regex'
		const star_delim = eval(tmp_star)
		const pos_star = searchpos(star_delim, 'nbW')

		const tmp_underscore = $'TEXT_STYLES_DICT.{text_style}U.open_regex'
		const underscore_delim = eval(tmp_underscore)
		const pos_underscore = searchpos(underscore_delim, 'nbW')

		if pos_star == [0, 0]
			text_style_refined = text_style .. "U"
		elseif pos_underscore == [0, 0]
			text_style_refined = text_style
		elseif IsGreater(pos_underscore, pos_star)
			text_style_refined = text_style .. "U"
		else
			text_style_refined = text_style
		endif
		return text_style_refined
	enddef

	def SearchPosChar(pattern: string, options: string): list<number>
		# Like 'searchpos()' but the column is converted in char index
		var [l, c] = searchpos(pattern, options)
		var c_char = charidx(getline(l), c - 1) + 1
		return [l, c_char]
	enddef

	# ================================
	# Main function start here
	# ================================
	# TODO: text_style comes from vim-markdown. If vim-markdown changes, this will.
	# It is not enough to find separators, but such separators must be
	# named '*Delimiter' according to synIDAttr()
	const text_style = synIDattr(synID(line("."), col("."), 1), "name")
	const text_style_adjusted =
		text_style == 'markdownItalic' || text_style == 'markdownBold'
		? StarOrUnderscore(synIDattr(synID(line("."), col("."), 1), "name"))
		: synIDattr(synID(line("."), col("."), 1), "name")
	var return_val = {}

	if !empty(text_style_adjusted)
			&& index(keys(TEXT_STYLES_DICT), text_style_adjusted) != -1

		const saved_curpos = getcursorcharpos()

		# Search start delimiter
		const open_delim =
			eval($'TEXT_STYLES_DICT.{text_style_adjusted}.open_delim')

		var open_delim_pos = SearchPosChar($'\V{open_delim}', 'bW')

		var current_style = synIDattr(synID(line("."), col("."), 1), "name")
		# We search for a markdown delimiter or an htmlTag.
		while current_style != $'{text_style}Delimiter'
				&& current_style != 'htmlTag'
				&& open_delim_pos != [0, 0]
			open_delim_pos = SearchPosChar($'\V{open_delim}', 'bW')
			current_style = synIDattr(synID(line("."), col("."), 1), "name")
		endwhile

		# To avoid infinite loops if some weird delimited text is highlighted
		if open_delim_pos == [0, 0]
			return {}
		endif
		open_delim_pos[1] += strchars(open_delim)

		# ----- Search end delimiter. -------
		# The end delimiter may be a blank line, hence
		# things become a bit cumbersome.
		setcursorcharpos(saved_curpos[1 : 2])
		const close_delim =
			eval($'TEXT_STYLES_DICT.{text_style_adjusted}.close_delim')
		var close_delim_pos = SearchPosChar($'\V{close_delim}', 'nW')
		var blank_line_pos = SearchPosChar('^$', 'nW')
		var first_met = [0, 0]
		current_style = synIDattr(synID(line("."), col("."), 1), "name")

		# The while loop is to robustify because you ultimately want to get a
		# '*Delimiter' text-style, like for example 'markdownBoldDelimiter' and
		# not just land on a '**'.
		while current_style != $'{text_style}Delimiter'
				&& current_style != 'htmlEndTag'
				&& getline(line('.')) !~ '^$'
			close_delim_pos = SearchPosChar($'\V{close_delim}', 'W')
			blank_line_pos = SearchPosChar('^$', 'W')
			if close_delim_pos == [0, 0]
				first_met = blank_line_pos
			elseif blank_line_pos == [0, 0]
				first_met = close_delim_pos
			else
				first_met = IsLess(close_delim_pos, blank_line_pos)
					? close_delim_pos
					: blank_line_pos
			endif
			setcursorcharpos(first_met)
			current_style = synIDattr(synID(line("."), col("."), 1), "name")
		endwhile

		# If we hit a blank line, then we take the previous line and last column,
		# to keep consistency in returning open-intervals
		if getline(line('.')) =~ '^$'
			first_met[0] = first_met[0] - 1
			first_met[1] = strchars(getline(first_met[0]))
		else
			first_met[1] -= 1
		endif

		setcursorcharpos(saved_curpos[1 : 2])
		return_val =  {[text_style_adjusted]: [open_delim_pos, first_met]}
	endif

	return return_val
enddef

export def SetBlock(type: string = '')
	# TODO: you may want to make this feature 'Smart' like 'SurroundSmart'. At
	# the moment is more like 'SurroundSimple'.
	#
	# If we are overlapping another thing, don't do anything
	const syn_info = synIDattr(synID(line("."), charcol("."), 1), "name")
	if !empty(IsInRange())
			|| syn_info == 'markdownCodeDelimiter'
			|| syn_info == 'markdownCodeBlock'
		return
	endif

	# Put the selected text between open_block and close_block.
	var label = input('Enter code-block language: ')

	const open_block = CODEBLOCK_OPEN_DICT
	const close_block = CODEBLOCK_CLOSE_DICT

	# We set cA=1 and cB = len(geline(B)) so we pretend that we are working
	# always line-wise
	var lA = line("'[")
	var cA = 1

	var lB = line("']")
	var cB = strchars(getline(lB))

	var firstline = getline(lA)
	var lastline = getline(lB)

	if firstline == lastline
		append(lA - 1, $'{keys(open_block)[0] .. label}')
		lA += 1
		lB += 1
		setline(lA, "  " .. getline(lA)->substitute('^\s*', '', ''))
		append(lA, $'{keys(open_block)[0] .. label}')
	else
		# Set first part
		setline(lA, strcharpart(getline(lA), 0, cA - 1))
		append(lA, [$'{keys(open_block)[0] .. label}',
	  "  " .. strcharpart(firstline, cA - 1)])
			lA += 2
		lB += 2

		# Set intermediate part
		var ii = 1
		while lA + ii <= lB
			setline(lA + ii, "  " .. getline(lA + ii)->substitute('^\s*', '', ''))
			ii += 1
		endwhile

		# Set last part
		setline(lB, $'  {lastline}')
		append(lB, [$'{keys(close_block)[0]}', ''])
	endif
enddef

export def UnsetBlock(syn_info: string = '')
	const syn_str = empty(syn_info)
		? synIDattr(synID(line("."), charcol("."), 1), "name")
		: syn_info
	if syn_str == 'markdownCodeBlock'
		const pos_start = searchpos(values(CODEBLOCK_OPEN_DICT)[0], 'nbW')
		const pos_end = searchpos(values(CODEBLOCK_CLOSE_DICT)[0], 'nW')

		const lA = pos_start[0]
		const lB = pos_end[0]
		deletebufline('%', lA - 1)
		deletebufline('%', lA - 1)
		deletebufline('%', lB - 2)
		deletebufline('%', lB - 2)

		for line in range(lA - 1, lB - 2)
			setline(line, getline(line)->substitute('^\s*', '', 'g'))
		endfor
	endif
enddef

export def SetQuoteBlock(type: string = '')

	# We set cA=1 and cB = strchars(geline(B)) so we pretend that we are working
	# always line-wise
	var lA = line("'[")
	var lB = line("']")

	for line_nr in range(lA, lB)
		setline(line_nr, $'> {getline(line_nr)}')
	endfor
enddef

export def UnsetQuoteBlock()
	const open_regex = values(QUOTEBLOCK_OPEN_DICT)[0]
	# Line that starts with everything but '\s*>'-ish
	const close_regex = values(QUOTEBLOCK_CLOSE_DICT)[0]

	const saved_curpos = getcurpos()
	var line_nr = saved_curpos[1]
	var line_content = getline(line_nr)

	if line_content !~ open_regex
		return
	endif

	# Moving up
	while line_content !~ close_regex && line_nr > 0
		setline(line_nr, line_content->substitute('>\s', '', ''))
		line_nr -= 1
		line_content = getline(line_nr)
	endwhile

	# Moving down
	setcharpos('.', saved_curpos)
	line_nr = line('.') + 1
	line_content = getline(line_nr)
	while line_content !~ close_regex && line_nr <= line('$')
		setline(line_nr, line_content->substitute('>\s', '', ''))
		line_nr += 1
		line_content = getline(line_nr)
	endwhile
	setcharpos('.', saved_curpos)
enddef

export def GetTextObject(textobject: string): dict<any>
	# You pass a text object like 'iw' and it returns the text
	# associated to it along with the start and end positions.
	#
	# Note that when you yank some text, the registers '[' and ']' are set, so
	# after call this function, you can retrieve start and end position of the
	# text-object by looking at such marks.
	#
	# The function also work with motions.

	# Backup the content of register t (arbitrary choice, YMMV) and marks
	var oldreg = getreg("t")
	var saved_A = getcharpos("'[")
	var saved_B = getcharpos("']")
	# silently yank the text covered by whatever text object
	# was given as argument into register t. Yank also set marks '[ and ']
	noautocmd execute 'silent normal "ty' .. textobject

	var text = getreg("t")
	var start_pos = getcharpos("'[")
	var end_pos = getcharpos("']")

	# restore register t and marks
	setreg("t", oldreg)
	setcharpos("'[", saved_A)
	setcharpos("']", saved_B)

	return {text: text, start: start_pos, end: end_pos}
enddef
var visited_buffers = []

export def GoToPrevVisitedBuffer()
	if len(visited_buffers) > 1
		remove(visited_buffers, -1)
		exe $"buffer {visited_buffers[-1]}"
	endif
	# echom visited_buffers
enddef

export def ToggleMark() # Toggle checkbox marks in todo lists
	const line = getline('.')
	if line->match('- \[ \]') != -1
		line->substitute('- \[ \]', '- [x]', '')->setline('.')
	elseif line->match('- \[[-?!xX]\]') != -1
		line->substitute('- \[[-?!xX]\]', '- [ ]', '')->setline('.')
	endif
enddef

export def CR_Hacked()
	# Needed for hacking <CR> when you are writing a list
	#
	# Check if the current line starts with '- [ ]' or '- '
	# OBS! If there are issues, check 'formatlistpat' value for markdown
	# filetype
	# OBS! The following scan the current line through the less general regex (a
	# regex can be contained in another regex)
	var variant_1 = '-\s\[\(\s*\|x\)*\]\s\+' # - [ ] bla bla bla
	var variant_2 = '-\s\+\(\[\)\@!' # - bla bla bla
	var variant_3 = '\*\s\+' # * bla bla bla
	var variant_4 = '\d\+\.\s\+' # 123. bla bla bla
	var variant_5 = '>\s\+' # Quoted block

	def GetItemSymbol(current_line: string): string
		var item_symbol = ''
		if current_line =~ $'^\s*{variant_1}'
			# If - [x], the next item should be - [ ] anyway.
			item_symbol = $"{current_line->matchstr($'^\s*{variant_1}')
						\ ->substitute('x', ' ', 'g')}"
		elseif current_line =~ $'^\s*{variant_2}'
			item_symbol = $"{current_line->matchstr($'^\s*{variant_2}')}"
		elseif current_line =~ $'^\s*{variant_3}'
			item_symbol = $"{current_line->matchstr($'^\s*{variant_3}')}"
		elseif current_line =~ $'^\s*{variant_5}'
			item_symbol = $"{current_line->matchstr($'^\s*{variant_5}')}"
		elseif current_line =~ $'^\s*{variant_4}'
			# Get rid of the trailing '.' and convert to number
			var curr_nr = str2nr(
				$"{current_line->matchstr($'^\s*{variant_4}')->matchstr('\d\+')}"
			)
			item_symbol = $"{current_line->matchstr($'^\s*{variant_4}')
						\ ->substitute(string(curr_nr), string(curr_nr + 1), '')}"
		endif
		return item_symbol
	enddef

	# Break line at cursor position
	var this_line = getline('.')->strpart(0, col('.') - 1)
	var next_line = getline('.')->strpart(col('.') - 1)


	# Handle different cases if the current line is an item of a list
	var line_nr = line('.')
	var current_line = getline(line_nr)
	var item_symbol = GetItemSymbol(current_line)
	if current_line =~ '^\s\{2,}'
		while current_line !~ '^\s*$' && line_nr != 0 && empty(item_symbol)
			line_nr -= 1
			current_line = getline(line_nr)
			item_symbol = GetItemSymbol(current_line)
			# echom item_symbol
			if !empty(item_symbol)
				break
			endif
		endwhile
	endif

	# if item_symbol = '' it may still mean that we are not in an item list but
	# yet we have an indendent line, hence, we must preserve the leading spaces
	if empty(item_symbol)
		item_symbol = $"{getline('.')->matchstr($'^\s\+')}"
	endif

	# The following is in case the cursor is on the lhs of the item_symbol
	if col('.') < strwidth(item_symbol)
		if current_line =~ $'^\s*{variant_4}'
			this_line = $"{current_line->matchstr($'^\s*{variant_4}')}"
			next_line = current_line->strpart(strwidth(item_symbol))
		else
			this_line = item_symbol
			next_line = current_line->strpart(strwidth(item_symbol))
		endif
	endif

	# double <cr> equal to finish the itemization
	if getline('.') == item_symbol || getline('.') =~ '^\s*\d\+\.\s*$'
		this_line = ''
		item_symbol = ''
	endif

	# Add the correct lines
	setline(line('.'), this_line)
	append(line('.'), item_symbol .. next_line)
	cursor(line('.') + 1, strchars(item_symbol) + 1)
enddef

export def RemoveAllStyle()
	# TODO could be refactored to increase speed, but it may not be necessary
	const range_info = IsInRange()
	const syn_info = synIDattr(synID(line("."), charcol("."), 1), "name")
	const is_quote_block = getline('.') =~ '^>\s'

	# If on plain text, do nothing
	if empty(range_info)
			&& syn_info != 'markdownCodeBlock' && !is_quote_block
		return
	endif

	# Check markdownCodeBlocks
	if syn_info == 'markdownCodeBlock'
		UnsetBlock(syn_info)
		return
	endif

	# Text styles removal setup
	if !empty(range_info)
		const target = keys(range_info)[0]
		var text_styles = copy(TEXT_STYLES_DICT)
		unlet text_styles['markdownLinkText']

		if index(keys(text_styles), target) != -1
			RemoveSurrounding(range_info)
		elseif target == 'markdownLinkText'
			RemoveLink()
		endif
		return
	endif

	if is_quote_block
		UnsetQuoteBlock()
	endif
enddef

# ---- auto-completion --------------
export def OmniFunc(findstart: number, base: string): any
	# Define the dictionary
	b:markdown_links = RefreshLinksDict()

	if findstart == 1
		# Find the start of the word
		var line = getline('.')
		var start = charcol('.')
		while start > 1 && getline('.')[start - 1] =~ '\d'
			start -= 1
		endwhile
		return start
	else
		var matches = []
		for key in keys(b:markdown_links)
			add(matches, {word: $'{key}]', menu: b:markdown_links[key]})
		endfor
		return {words: matches}
	endif
enddef

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

export def Make()
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

export def Pandoc(format: string = 'html')
	compiler pandoc
	var output_file = $'{expand('%:p:r')}.{format}'
	var cmd = execute($'make {format}')
	# TIP: use g< to show all the echoed messages since now
	# TIP2: redraw! is used to avoid the "PRESS ENTER" thing
	echo cmd->matchstr('.*\ze2>&1') | redraw!

	# TODO: pandoc compiler returns v:shell_error = 0 even if there are
	# errors. Add a condition on v:shell_error once pandoc compiler is fixed.
	if exists(':Open') != 0
		exe 'Open' output_file
	endif
enddef

var complete_cache: string

augroup MarkdownAutoCmds
	au!
	au CmdlineEnter : complete_cache = null_string
augroup END

# Command definition
export def PandocComplete(_, _, _): string
	if empty(complete_cache)
		complete_cache = system('pandoc --list-output-formats')
	endif
	return complete_cache
enddef
defcompile
