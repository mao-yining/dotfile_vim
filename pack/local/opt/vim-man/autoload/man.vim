vim9script
# GetPage {{{
var man_tag_depth = -1
var man_tag_bufs: dict<number>
var man_tag_lins: dict<number>
var man_tag_cols: dict<number>
export def GetPage(split_type: string, ...args: list<any>)
	var sect: string
	var page: string
	if len(args) == 0
		HandleNroffFileOrError(split_type)
		return
	elseif len(args) == 1
		sect = ''
		page = args[0]
	else
		sect = args[0]
		page = args[1]
	endif

	if sect != null_string && !ManpageExists(sect, page)
		sect = null_string
	endif
	if !ManpageExists(sect, page)
		Error("No manual entry for '" .. page .. "'.")
		return
	endif

	UpdateManTagVariables()
	GetNewOrExistingManWindow(split_type)
	SetManpageBufferName(page, sect)
	echom page sect
	LoadManpageText(page, sect)
enddef

def ManpageExists(sect: string, page: string): bool
	if empty(page)
		return false
	endif

	var cmd = g:vim_man_cmd .. ' ' .. find_arg .. ' ' .. GetCmdArg(sect, page)
	var where = system(cmd)

	if match(where, '^\s*/') == -1
		return false
	else
		return true
	endif
enddef

# handles :Man command invocation with zero arguments
def HandleNroffFileOrError(split_type: string)
	# :Man command can be invoked in 'nroff' files to convert it to a manpage
	if &filetype == 'nroff'
		if filereadable(expand('%'))
			GetNroffPage(split_type, expand('%:p'))
		else
			Error("Can't open file " .. expand('%'))
		endif
	else
		# simulating vim's error when not enough args provided
		Error('E471: Argument required')
	endif
enddef

# open a nroff file as a manpage
def GetNroffPage(split_type: string, nroff_file: string)
	UpdateManTagVariables()
	GetNewOrExistingManWindow(split_type)
	silent execute 'edit' nroff_file->fnamemodify(':t') .. '\ manpage\ (from\ nroff)'
	LoadManpageText(nroff_file, '')
enddef

export def GetPageFromCword(split_type: string)
	var sect: string
	var page: string

	if v:count == 0
		var old_isk = &iskeyword
		if &filetype == 'man'
			# when in a manpage try determining section from a word like this 'printf(3)'
			setlocal iskeyword+=(,),:
		endif

		var str = expand('<cword>')
		&l:iskeyword = old_isk

		page = matchstr(str, '\(\k\|:\)\+')
		sect = matchstr(str, '(\zs[^)]*\ze)')

		if sect !~ '^[0-9nlpo][a-z]*$' || sect == page
			sect = ''
		endif
	else
		sect = string(v:count)
		var old_isk = &iskeyword
		setlocal iskeyword+=:
		page = expand('<cword>')
		&l:iskeyword = old_isk
	endif

	GetPage(split_type, sect, page)
enddef

export def PopPage()
	if man_tag_depth < 1
		return
	endif
	const depth  = man_tag_depth - 1
	const line   = man_tag_lins->get(depth, 1)
	const column = man_tag_cols->get(depth, 1)
	const buf    = man_tag_bufs->get(depth, -1)

	if bufexists(buf)
		exe 'buffer' buf
		cursor(line, column)
	endif
	man_tag_bufs->remove(depth)
	man_tag_lins->remove(depth)
	man_tag_cols->remove(depth)
	man_tag_depth = depth
enddef

def UpdateManTagVariables()
	man_tag_bufs[man_tag_depth] = bufnr()
	man_tag_lins[man_tag_depth] = line('.')
	man_tag_cols[man_tag_depth] = col('.')
	man_tag_depth += 1
enddef

def GetNewOrExistingManWindow(split_type: string)
	if &filetype != 'man'
		var thiswin = winnr()
		wincmd b

		if winnr() > 1
			win_getid(thiswin)->win_gotoid()
			while true
				if &filetype == 'man'
					break
				endif
				wincmd w
				if thiswin == winnr()
					break
				endif
			endwhile
		endif

		if &filetype != 'man'
			if split_type == 'vertical'
				vnew
			elseif split_type == 'tab'
				tabnew
			else
				new
			endif
		endif
	endif
enddef
# }}}
# Helpers {{{

var section_arg = ''
var find_arg = '-w'

try
	if !has('win32') && $OSTYPE !~ 'cygwin\|linux' && system('uname -s') =~ 'SunOS' && system('uname -r') =~ '^5'
		section_arg = '-s'
		find_arg = '-l'
	endif
catch /E145:/
	# Ignore the error in restricted mode
endtry

export def SectionArg(): string
	return section_arg
enddef

export def Error(str: string)
	echohl ErrorMsg
	echomsg str
	echohl None
enddef

export def GetCmdArg(sect: string, page: string): string
	if empty(sect)
		return page
	else
		return SectionArg() .. ' ' .. sect .. ' ' .. page
	endif
enddef

export def SetManpageBufferName(page: string, section: string)
	silent execute 'edit' ManpageBufferName(page, section)
enddef

def ManpageBufferName(page: string, section: string): string
	if !empty(section)
		return page .. '(' .. section .. ')\ manpage'
	else
		return page .. '\ manpage'
	endif
enddef

export def LoadManpageText(page: string, section: string)
	setlocal modifiable
	silent keepjumps normal! 1GdG
	$MANWIDTH = string(Manwidth())

	execute($'r!{g:vim_man_cmd} {GetCmdArg(section, page)} 2>/dev/null | col -b')
	RemoveBlankLinesFromTopAndBottom()

	setlocal filetype=man
	setlocal nomodifiable
enddef

def RemoveBlankLinesFromTopAndBottom()
	while line('$') > 1 && getline(1) =~ '^\s*$'
		silent keepjumps normal! ggdd
	endwhile
	while line('$') > 1 && getline('$') =~ '^\s*$'
		silent keepjumps normal! Gdd
	endwhile
	silent keepjumps normal! gg
enddef

# Default manpage width is the width of the screen. Change this with
# 'g:man_width'. Example: 'let g:man_width = 120'.
export def Manwidth(): number
	if exists('g:man_width')
		return g:man_width
	else
		return winwidth(0)
	endif
enddef

export def ExtractPermittedSectionValue(section: string): string
	if section =~# '^*$'
		# matches all dirs with a glob 'man*'
		return section
	elseif section =~# '^\d[xp]\?$'
		# matches dirs: man1, man1x, man1p
		return section
	elseif section =~# '^[nlpo]$'
		# matches dirs: mann, manl, manp, mano
		return section
	elseif section =~# '^\d\a\+$'
		# take only first digit, sections 3pm, 3ssl, 3tiff, 3tcl are searched in man3
		return matchstr(section, '^\d')
	else
		return ''
	endif
enddef

# first strips the directory name from the match, then the extension
def StripDirnameAndExtension(manpage_path: string): string
	return StripExtension(manpage_path->fnamemodify(':t'))
enddef

# Public function so it can be used for testing.
# Check 'manpage_extension_stripping_test.vim' for example input and output
# this regex produces.
def StripExtension(filename: string): string
	return substitute(filename, '\.\(\d\a*\|n\|ntcl\)\(\.\a*\|\.bz2\)\?$', '', '')
enddef

# fetches a colon separated list of paths where manpages are stored
var manpath_cache: string = ''

export def Manpath(): string
	# We don't expect manpath to change, so after first invocation it's
	# saved/cached in a script variable to speed things up on later invocations.
	if empty(manpath_cache)
		# perform a series of commands until manpath is found
		manpath_cache = $MANPATH
		if empty(manpath_cache)
			manpath_cache = system('manpath 2>/dev/null')
			if empty(manpath_cache)
				manpath_cache = system('man ' .. find_arg .. ' 2>/dev/null')
			endif
		endif
		# strip trailing newline for output from the shell
		manpath_cache = substitute(manpath_cache, '\n$', '', '')
	endif
	return manpath_cache
enddef
# }}}
# SectionMove {{{
export def SectionMove(cnt: number, direction = null_string)
	normal! m'
	var i = 0
	while i < cnt
		i += 1
		const col  = col('.')
		const line = line('.')
		if search('^\a\+', 'W' .. direction) == 0
			cursor(line, col)
			return
		endif
	endwhile
enddef
# }}}
# Completion {{{
var man_pages: string
export def Complete(_, _, _): string
	if empty(man_pages)
		man_pages = system("man -k . | cut -d ' ' -f1 | sort -u")
	endif
	return man_pages
enddef
# }}}
# Grep {{{
export def GrepRun(bang: bool, ...args: list<string>)
	# argument handling and sanitization
	var grep_case_insensitive: bool
	var section: string = '1'  # default section
	var pattern: string

	if len(args) == 1
		# just the pattern is provided
		pattern = args[0]
	elseif len(args) == 2
		# section + pattern OR grep `-i` flag + pattern
		if args[0] == '-i'
			# grep `-i` flag + pattern
			grep_case_insensitive = true
			pattern = args[1]
		else
			# section + pattern
			section = ExtractPermittedSectionValue(args[0])
			if empty(section)
				# don't run an expensive grep on *all* sections if a user made a typo
				Error('Unknown man section ' .. args[0])
				return
			endif
			pattern = args[1]
		endif
	elseif len(args) == 3
		# grep `-i` flag + section + pattern
		if args[0] != '-i'
			Error('Unknown Mangrep argument ' .. args[0])
			return
		endif
		grep_case_insensitive = true
		section = ExtractPermittedSectionValue(args[1])
		if empty(section)
			# don't run an expensive grep on *all* sections if a user made a typo
			Error('Unknown man section ' .. args[1])
			return
		endif
		pattern = args[2]
	elseif len(args) >= 4
		Error('Too many arguments')
		return
	endif

	var manpath = Manpath()
	if empty(trim(manpath))
		return
	endif

	# create new quickfix list
	setqflist([], ' ')
	JobRun(bang, grep_case_insensitive, pattern, manpath->tr(':', ' '))
enddef

def QuickfixGetPage(name: string)
	setlocal nobuflisted
	# TODO: switch to existing 'man' window or create a split
	SetManpageBufferName(name, "")
	LoadManpageText(name, "")
enddef

def CreateEmptyBuffer(bufnr: number)
	var bufname = bufname(bufnr)
	var name = bufname->tr('\', '/')->fnamemodify(':t')
	[{
		bufnr: bufnr,
		event: 'BufEnter',
		cmd: $'QuickfixGetPage("{name}")',
		replaces: true
	}]->autocmd_add()
	return
enddef
# }}}
# AsyncGrep {{{
var job: job
var grep_not_bang: bool
var grep_opened_first_result: number

export def JobRun(bang: bool, insensitive: bool, pattern: string, path_glob: string)
	echo 'Mangrep command started in background'
	if job != null_job
		job_stop(job)
	endif

	grep_opened_first_result = 0
	grep_not_bang = !bang

	var manwidth = Manwidth()
	$MANWIDTH = string(manwidth)

	var i = insensitive ? '-i' : ''

	var command = $'rg {i} --vimgrep "{pattern}" {path_glob}'

	job = command->job_start({
		out_cb: (_, msg) => {
			setqflist([], 'a', {lines: [msg]})
		},
		close_cb: (_) => {
			echo 'Mangrep command done'
			const qflist = getqflist()
			const bufs = qflist->mapnew((_, v) => v.bufnr)->uniq()
			for buf in bufs
				CreateEmptyBuffer(buf)
			endfor
			if empty(qflist)
				echo "No matches found"
			else
				echo printf("Found %d matches", len(qflist))
				if grep_not_bang && grep_opened_first_result == 0
					copen
				endif
			endif
		}
	})

	if job->job_status() == 'fail'
		echoerr "Failed to start Mangrep job"
	endif
enddef
# }}}
# vim:fdm=marker
