vim9script
g:popup_borderchars   = ['─', '│', '─', '│', '╭', '╮', '╯', '╰']
g:popup_borderchars_t = ['─', '│', '─', '│', '├', '┤', '╯', '╰']

g:loaded_netrw        = 1
g:loaded_netrwPlugin  = 1
nmap - <Cmd>Dir<CR>
g:dir_change_cwd = true
g:dir_actions = [
	{text: 'Share with 0x0.st', Action: (items) => {
		var urls = []
		for item in items
			var path = $"{b:dir_cwd}/{item.name}"
			if item.type != 'dir' && filereadable(path)
				var url = systemlist($'curl -A "Vim Paste" -F file=@"{path}" http://0x0.st')[-1]
				add(urls, url)
			endif
		endfor
		setreg("@", urls->join("\n"))
		setreg("+", urls->join("\n"))
		echom urls->join("\n")
	}},
	{text: 'Convert to gif', Action: (items) => {
		if len(items) > 1
			return
		endif
		var input = items[0].name
		if fnamemodify(input, ":e") != "mkv"
			echom "Should only work for MKV file!"
			return
		endif
		var output = fnamemodify(input, ":r") .. ".gif"
		var gs_cmd = 'ffmpeg -i "%s" -vf "split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" "%s"'
		term_start(printf(gs_cmd, input, output), {term_finish: "close"})
	# if v:shell_error
	#     echom $"Couldn't convert {input}"
	# else
	#     :Dir
	# endif
	}},
	{text: 'Optimize PDF', Action: (items) => {
		if len(items) > 1
			return
		endif
		var input = items[0].name
		if fnamemodify(input, ":e") != "pdf"
			echom "Should only work for PDF file!"
			return
		endif
		var output = fnamemodify(input, ":r") .. "_opt.pdf"
		var gs_cmd = 'gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/ebook -dNOPAUSE -dQUIET -dBATCH -sOutputFile="%s" "%s"'
		system(printf(gs_cmd, output, input))
		if v:shell_error
			echom $"Couldn't optimize {input}"
		else
			exe "Dir"
		endif
	}},
]

silent! packadd comment
# silent! packadd editexisting
silent! packadd editorconfig
silent! packadd helptoc
tnoremap <C-t><C-t> <Cmd>HelpToc<CR>
g:helptoc = {shell_prompt: '^\(PS \)\?\f\+>\s'}
silent! packadd hlyank
g:hlyank_duration = 200
g:hlyank_hlgroup = 'Search'
silent! packadd matchit
silent! packadd nohlsearch
silent! packadd vimcdoc

if executable("git")
	g:gitgutter_map_keys = 0
	g:gitgutter_preview_win_floating = 1
	nmap <LocalLeader>hw <Plug>(GitGutterStageHunk)
	nmap <LocalLeader>hr <Plug>(GitGutterUndoHunk)
	nmap <LocalLeader>hp <Plug>(GitGutterPreviewHunk)
	omap ih <Plug>(GitGutterTextObjectInnerPending)
	omap ah <Plug>(GitGutterTextObjectOuterPending)
	xmap ih <Plug>(GitGutterTextObjectInnerVisual)
	xmap ah <Plug>(GitGutterTextObjectOuterVisual)
	nmap ]h <Plug>(GitGutterNextHunk)
	nmap [h <Plug>(GitGutterPrevHunk)
	silent! packadd fugitive
	silent! packadd gitgutter
	silent! packadd gv
	silent! packadd conflict-marker
endif

if executable("ctags")
	g:gutentags_exclude_filetypes = ['help']
	if executable('rg')
		g:gutentags_file_list_command = 'rg --files'
	elseif executable('git')
		g:gutentags_file_list_command = 'git ls-files'
	endif
	silent! packadd gutentags
endif

if executable("man")
	silent! packadd man
endif

if executable("gpg")
	silent! packadd gnupg
endif

if executable("pio")
	silent! packadd pio
endif

nmap =d <Cmd>DIstart<CR>
nmap \d <Cmd>DIstop<CR>

nmap <LocalLeader>v <Cmd>Vista!!<CR>

g:asynctasks_term_pos = "tab"
g:asyncrun_open       = 9
g:asyncrun_save       = true
g:asyncrun_bell       = true
if has("win32")
	g:asyncrun_encs   = "cp936"
endif
map  <silent><F7>  <Esc><Cmd>AsyncTask file-run<CR>
imap <silent><F7>  <Esc><Cmd>AsyncTask file-run<CR>
map  <silent><F8>  <Esc><Cmd>AsyncTask file-build<CR>
imap <silent><F8>  <Esc><Cmd>AsyncTask file-build<CR>
map  <silent><F9>  <Esc><Cmd>AsyncTask project-run<CR>
imap <silent><F9>  <Esc><Cmd>AsyncTask project-run<CR>
map  <silent><F10> <Esc><Cmd>AsyncTask project-build<CR>
imap <silent><F10> <Esc><Cmd>AsyncTask project-build<CR>

nmap <Leader>u <Cmd>UndotreeToggle<CR>
g:undotree_SetFocusWhenToggle = true

g:html_font = ["Fira Code", "Consolas"]

xmap gl <Plug>(EasyAlign)
nmap gl <Plug>(EasyAlign)

omap i, <Plug>(swap-textobject-i)
xmap i, <Plug>(swap-textobject-i)
omap a, <Plug>(swap-textobject-a)
xmap a, <Plug>(swap-textobject-a)

command -nargs=? StartupTime delc StartupTime | packa startuptime | StartupTime

runtime macros/sandwich/keymap/surround.vim

nmap <C-=> <Plug>(GUIFontSizeInc)
nmap <C-_> <Plug>(GUIFontSizeDec)
nmap <C--> <Plug>(GUIFontSizeDec)
nmap <C-0> <Plug>(GUIFontSizeRestore)

g:dispatch_no_maps = 1
nmap `! :Dispatch!
nmap `<CR> <Cmd>Dispatch<CR>
nmap `<Space> :Dispatch<Space>
nmap `? <Cmd>FocusDispatch<CR>
nmap m! :Make!
nmap m<CR> <Cmd>Make<CR>
nmap m<Space> :Make<Space>
nmap m? <Cmd>set makeprg?<CR>

g:competitest_configs = {
	# multiple_testing: 1,
	testcases_input_file_format: "$(FNOEXT)$(TCNUM).in",
	testcases_output_file_format: "$(FNOEXT)$(TCNUM).ans",
	template_file: "D:/Competitive-Programming/templates/template.$(FEXT)",
	evaluate_template_modifiers: true,
	received_problems_path: (task, file_extension): string => {
		const parts = task.group->split(" - ") # Codeforces' contest
		return printf(
			"D:/Competitive-Programming/%s/%s/%s/_.%s",
			parts[0]->substitute('[<>:"/\\|?*#]', '_', 'g'), # judge platform
			parts->get(1, 'problems')->substitute('[<>:"/\\|?*#]', '_', 'g'),
			task.name->split()[0]->substitute('[#.]', '', 'g'),
			file_extension
		)
	},
	received_contests_directory: "D:/Competitive-Programming/$(JUDGE)/$(CONTEST)",
	received_contests_problems_path: "$(PROBLEM)/_.$(FEXT)",
}
