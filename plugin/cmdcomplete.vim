vim9script

# command line completion
set wildmode=noselect:lastused,full
set wildmenu wildoptions=pum,fuzzy wildcharm=<Tab> pumheight=12
set wildignore+=*.o,*.obj,*.bak,*.exe,*.swp,tags,*.cmx,*.cmi
set wildignore+=*~,*.py[co],__pycache__
set wildignore+=*.obsidian,*.svg

cnoremap <expr> <Up> wildmenumode() ? "\<C-e>\<Up>" : "\<Up>"
cnoremap <expr> <Down> wildmenumode() ? "\<C-e>\<Down>" : "\<Down>"
cnoremap <expr> <Left> wildmenumode() ? "\<C-e>\<Left>" : "\<Left>"
cnoremap <expr> <Right> wildmenumode() ? "\<C-e>\<Right>" : "\<Right>"

def CmdCompleteSelectFirst()
	# If @: is pressed v:char is \n, exit here, allowing the command to be executed.
	# Otherwise, if command-line was cancelled, clear it and exit the function.
	if v:char == "\n"
		return
	elseif v:char != "\<CR>" && has("patch-9.1.1679")
		setcmdline('')
		return
	endif

	var info = cmdcomplete_info()
	if empty(get(info, 'cmdline_orig', ''))
			|| empty(info.matches) || !info.pum_visible
		return
	endif

	var cmd = info.cmdline_orig->split()
	# Do not accept first element of completion for just commands:
	# :e<CR> should not be expanded to :edit<CR>
	if getcmdcompltype() == 'command' && cmd->len() == 1
		return
	endif

	# Do not accept first element of completion if there are multiple arguments
	if cmd->len() > 2
		return
	endif

	# Commands to accept first element of completion if no selection is made and
	# completion is visible.
	# :e newfile<CR> should always edit newfile, not the first element of completion
	var commands = [
		'sfind', 'find', 'tabfind', 'buffer', 'sbuffer',
		'colorscheme', 'highlight',
		'Recent', 'SRecent', 'Bookmark', 'SBookmark',
		'Project', 'Help',
		'LoadSession', 'InsertTemplate', 'Colorscheme', 'Unicode',
		'help', 'AsyncTask', 'SLoad', 'compiler'
	]

	# fullcommand() can't figure out `:vertical sbuffer` or `:horizontal sbuffer`,
	var cmd_orig = substitute(info.cmdline_orig, '\v^%(%(ver%[tical])|%(hor%[izontal]))', '', '')
	var cmd_len = len(cmd_orig) == len(info.cmdline_orig) ? 0 : 1
	if commands->index(fullcommand(cmd_orig)) == -1
		return
	endif

	var selected = info.matches[info.selected == -1 ? 0 : info.selected]
	if fullcommand(cmd_orig) != "Help"
		selected = selected->escape('#%')
	endif
	setcmdline($'{cmd[ : cmd_len]->join()} {selected}')
enddef

def EditDirectoryHelper()
	var info = cmdcomplete_info()

	if empty(info) || getcmdcompltype() != 'file'
		return
	endif

	var cmdline = getcmdline()
	if getcmdpos() - 1 != getcmdline()->len()
		return
	endif

	if info.pum_visible
			&& info.selected == 0
			&& len(info.matches) == 1
			&& info.matches[0] =~ '\([\\/]\)$'
		timer_start(0, (_) => {
			var slash = has("win32") ? '\' : '/'
			feedkeys(slash, 'nt')
		})
	else
		if cmdline =~ "://*$"
			return
		endif
		setcmdline(cmdline->substitute('\([\\/]\)\+$', '\1', ''))
	endif
enddef

def CmdComplete()
	if getcmdcompltype() =~# 'customlist'
		return
	endif

	EditDirectoryHelper()
	# :! and :term completion is very slow on Windows and WSL, disable it there.
	if !((has("win32") || exists("$WSLENV")) && getcmdcompltype() == 'shellcmd')
		wildtrigger()
	endif
enddef

augroup CmdComplete
	au!
	autocmd CmdlineChanged : CmdComplete()
	autocmd CmdlineLeavePre : CmdCompleteSelectFirst()
augroup END
