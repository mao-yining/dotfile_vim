vim9script
# Name: autoload\pack.vim Author: Mao-Yining <mao.yining@outlook.com>
# Desc: Manage Vim plugins via git with batch update/install functionality
#       Supports parallel processing and visual progress tracking
# Usage:
#
# 1. Create plugin list file: $MYVIMDIR/pack/packs
#    Format: <plugin-name><Tab><git-repo-url>
#    Example:
#    # vim: ts=35 sw=0 noet cc=35
#    devel	git@github.com:lifepillar/vim-devel.git
#    mine/opt/fugitive	git@github.com:tpope/vim-fugitive.git
#
# 2. Import and define command in vimrc:
#    import autoload "pack.vim"
#    command! -nargs=* -complete=custom,pack.Complete PackUpdate pack.Update(<f-args>)
#
# 3. Commands:
#    :PackUpdate                  # Update all plugins
#    :PackUpdate plugin1 plugin2  # Update specific plugins (tab-completion available)
#
# Features:
# - Batch update/install plugins via git
# - Progress popup with visual indicators
# - Post-update changelog display
# - Parallel processing (up to 10 concurrent jobs)
# - Tab completion for plugin names
#
# Status Indicators:
#   ○ → ● : Plugin update (pending → complete)
#   ⬠ → ⬟ : Plugin install (pending → complete)

const popup_borderchars = get(g:, "popup_borderchars", ['─', '│', '─', '│', '┌', '┐', '┘', '└'])
const popup_borderhighlight = get(g:, "popup_borderhighlight", ['Normal'])
const popup_highlight = get(g:, "popup_highlight", 'Normal')
const UPD1 = "○"
const UPD2 = "●"
const INST1 = "⬠"
const INST2 = "⬟"
const MAX_JOBS = 10

var packages_cache: list<string>

augroup CmdCompleteResetPack
	au!
	au CmdlineEnter : packages_cache = null_list
augroup END

export def Complete(_, _, _): string
	if empty(packages_cache)
		packages_cache = Packages()->mapnew((_, v) => v[0]->escape(' '))
	endif
	return packages_cache->join("\n")
enddef

def Packages(): list<tuple<string, string>>
	const pack_list = $'{$MYVIMDIR}pack/packs'
	if !filereadable(pack_list)
		return null_list
	endif
	var packages: list<tuple<string, string>>
	for pinfo in readfile(pack_list)
		if pinfo =~ '^\s*#' || pinfo =~ '^\s*$'
			continue
		endif
		const [name, url] = pinfo->split("\t")
		if empty(name) || empty(url)
			continue
		endif
		packages->add((name, url))
	endfor
	return packages
enddef

var pack_jobs: list<job>
var pack_msg: dict<string>

def IsRunning(): bool
	return pack_jobs->reduce((acc, val) => acc || job_status(val) == 'run', false)
enddef

# Update or install plugins listed in packs
export def Update(...args: list<string>)
	if IsRunning()
		echow "Previous update is not finished yet!"
		return
	endif

	pack_jobs = null_list
	pack_msg = null_dict

	var packages = Packages()
	if !empty(args)
		packages->filter((_, v) => args->index(v[0]) != -1)
	endif
	if empty(packages)
		echow "No packages to install or update!"
		return
	endif

	const [winid, bufnr] = CreatePopup((id) => {
		win_execute(id, $"syn match PackUpdateDone '^{UPD2}'")
		win_execute(id, $"syn match PackInstallDone '^{INST2}'")
		hi def link PackUpdateDone Added
		hi def link PackInstallDone Changed
	})

	timer_start(1000, (t) => {
		if !IsRunning()
			timer_stop(t)
			popup_close(winid)
			helptags ALL
			ShowChangelog()
		endif
	}, {repeat: -1})

	timer_start(100, (t) => {
		if empty(packages)
			timer_stop(t)
			return
		endif
		pack_jobs->filter((_, v) => job_status(v) == 'run')
		if pack_jobs->len() >= MAX_JOBS
			return
		endif
		const [name, url] = packages->remove(0)
		const path = $"{$MYVIMDIR}/pack/{name}"
		if isdirectory(path)
			if empty(getbufoneline(bufnr, 1))
				setbufline(bufnr, 1, $"{UPD1} {name}")
			else
				appendbufline(bufnr, '$', $"{UPD1} {name}")
			endif
			pack_msg[name] = ""
			const job = job_start([&shell, &shellcmdflag, 'git fetch -q && git log HEAD..@{u} && git reset --hard -q @{u} && git clean -dfx -q'], {
				cwd: path,
				out_cb: (ch, msg) => {
					pack_msg[name] ..= $"{msg}\n"
				},
				close_cb: (_) => {
					const buftext = bufnr->getbufline(1, '$')
						->map((_, v) =>  v == $"{UPD1} {name}" ? $"{UPD2} {name}" : v)
					winid->popup_settext(buftext)
				}}
			)
			pack_jobs->add(job)
		else
			if empty(getbufoneline(bufnr, 1))
				setbufline(bufnr, 1, $"{INST1} {name}")
			else
				appendbufline(bufnr, '$', $"{INST1} {name}")
			endif
			const job = job_start($'git clone {url} {path}', {
				cwd: $MYVIMDIR,
				close_cb: (_) => {
					var buftext = getbufline(bufnr, 1, '$')
					buftext = buftext->mapnew((_, v) => {
						if v == $"{INST1} {name}"
							return $"{INST2} {name}"
						else
							return v
						endif
					})
					pack_msg[name] = "Installed.\n"
					popup_settext(winid, buftext)
				}}
			)
			pack_jobs->add(job)
		endif
	}, {"repeat": -1})
enddef

def CreatePopup(Setup: func(number)): tuple<number, number>
	const winid = ""->popup_create({
		title: " Plugins ",
		pos: 'botright',
		col: &columns,
		line: &lines,
		padding: [0, 1, 0, 1],
		border: [1, 1, 1, 1],
		mapping: 1,
		tabpage: -1,
		borderchars: popup_borderchars,
		borderhighlight: popup_borderhighlight,
		highlight: popup_highlight,
	})

	if Setup != null_function
		Setup(winid)
	endif

	return (winid, getwininfo(winid)[0].bufnr)
enddef

def ShowChangelog()
	var lines: list<string>
	for [name, msg] in pack_msg->items()
		if !empty(msg)
			lines->add(name)
			lines->add("="->repeat(strlen(name)))
			lines += [''] + msg->split("\n") + ['', '']
		endif
	endfor
	if empty(lines)
		"All plugins are up to date."->popup_notification({
			title: " Plugins ",
			borderchars: popup_borderchars,
			line: &lines - 4,
			col: &columns - 20
		})
		return
	endif
	new
	setl nobuflisted noswapfile buftype=nofile
	nnoremap <buffer> gq <Cmd>bd!<CR>
	set syntax=git
	syn match H1 "^.\+\n=\+$"
	hi! link H1 Title
	lines[ : -3]->setline(1)
enddef
