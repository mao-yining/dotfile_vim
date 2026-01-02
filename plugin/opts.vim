vim9script
# Plugin settings

if !"comment"->getcompletion("packadd")->empty()
	packadd comment
endif
# if !"editexisting"->getcompletion("packadd")->empty()
# 	packadd editexisting
# endif
if !"editorconfig"->getcompletion("packadd")->empty()
	packadd editorconfig
endif
if !"helptoc"->getcompletion("packadd")->empty()
	packadd helptoc
	tnoremap <C-t><C-t> <Cmd>HelpToc<CR>
	g:helptoc = {shell_prompt: '^\(PS \)\?\f\+>\s'}
endif
if !"hlyank"->getcompletion("packadd")->empty()
	packadd hlyank
	g:hlyank_duration = 200
endif
if !"matchit"->getcompletion("packadd")->empty()
	packadd matchit
endif
if !"nohlsearch"->getcompletion("packadd")->empty()
	packadd nohlsearch
endif

if !"vimcdoc"->getcompletion("packadd")->empty()
	packadd vimcdoc
endif

g:popup_borderchars   = ['─', '│', '─', '│', '╭', '╮', '╯', '╰']
g:popup_borderchars_t = ['─', '│', '─', '│', '├', '┤', '╯', '╰']

g:loaded_netrw        = 1
g:loaded_netrwPlugin  = 1
nmap - <Cmd>Dir<CR>

if executable("ctags") && !"vim-gutentags"->getcompletion("packadd")->empty()
	silent! packadd vim-gutentags
	g:gutentags_exclude_filetypes = ['help']
	if executable('rg')
		g:gutentags_file_list_command = 'rg --files'
	elseif executable('git')
		g:gutentags_file_list_command = 'git ls-files'
	endif
endif

if executable("man") && !"vim-man"->getcompletion("packadd")->empty()
	silent! packadd vim-man
endif

nmap s <plug>(SubversiveSubstitute)
nmap ss <plug>(SubversiveSubstituteLine)
nmap S <plug>(SubversiveSubstituteToEndOfLine)
xmap s <plug>(SubversiveSubstitute)

nmap =d <Cmd>DIstart<CR>
nmap \d <Cmd>DIstop<CR>

g:vista#renderer#enable_icon = false
nmap <LocalLeader>v <Cmd>Vista!!<CR>

g:asynctasks_term_pos = "tab"
g:asyncrun_open       = 9
g:asyncrun_save       = true
g:asyncrun_bell       = true
if has("win32")
	g:asyncrun_encs = "cp936"
endif
map <silent><F7> <Esc><Cmd>AsyncTask file-run<CR>
map <silent><F8> <Esc><Cmd>AsyncTask file-build<CR>
map <silent><F9> <Esc><Cmd>AsyncTask project-run<CR>
map <silent><F10> <Esc><Cmd>AsyncTask project-build<CR>
imap <silent><F7> <Esc><Cmd>AsyncTask file-run<CR>
imap <silent><F8> <Esc><Cmd>AsyncTask file-build<CR>
imap <silent><F9> <Esc><Cmd>AsyncTask project-run<CR>
imap <silent><F10> <Esc><Cmd>AsyncTask project-build<CR>

nmap <Home> <Plug>(qf_qf_previous)
nmap <End>  <Plug>(qf_qf_next)
nmap <C-Home> <Plug>(qf_loc_previous)
nmap <C-End>  <Plug>(qf_loc_next)
nmap <M-s> <Plug>(qf_qf_switch)
nmap <Leader>q <Plug>(qf_qf_toggle)
nmap <Leader>l <Plug>(qf_loc_toggle)

xmap <Tab> <Plug>(EasyAlign)

nmap <Leader>u <Cmd>UndotreeToggle<CR>
g:undotree_SetFocusWhenToggle = true

def PackCommands(packname: string, command: string)
	execute($"command -nargs=? {command} delc {command} <Bar> packa {packname} <Bar> {command} <f-args>")
enddef

PackCommands("undotree", "UndotreeToggle")
PackCommands("vim-startuptime", "StartupTime")
PackCommands("vim9asm", "Disassemble")
PackCommands("vim-pio", "PIO")

PackCommands("vim-test", "TestNearest")
PackCommands("vim-test", "TestFile")
PackCommands("vim-test", "TestSuite")
nmap <silent> <LocalLeader>tt <Cmd>TestNearest<CR>
nmap <silent> <LocalLeader>tf <Cmd>TestFile<CR>
nmap <silent> <LocalLeader>ts <Cmd>TestSuite<CR>
nmap <silent> <LocalLeader>tl <Cmd>TestLast<CR>
nmap <silent> <LocalLeader>tv <Cmd>TestVisit<CR>
g:test#strategy = "vimterminal"

g:competitest_configs = {
	# multiple_testing: 1,
	testcases_input_file_format: "$(FNOEXT)$(TCNUM).in",
	testcases_output_file_format: "$(FNOEXT)$(TCNUM).ans",
	template_file: "D:/Competitive-Programming/template/template.$(FEXT)",
	evaluate_template_modifiers: true,
	received_problems_path: (task, file_extension): string => {
		const hyphen = stridx(task.group, " - ") # Codeforces' contest
		var judge: string
		var contest: string
		if hyphen == -1
			judge = task.group
			contest = "problems"
		else
			judge = strpart(task.group, 0, hyphen)
			contest = strpart(task.group, hyphen + 3)
				->substitute('[<>:"/\\|?*#]', '_', 'g')
		endif
		return printf(
			"D:/Competitive-Programming/%s/%s/%s/_.%s",
			judge,
			contest,
			task.name->split(' ')[0]->substitute('[#.]', '', 'g'),
			file_extension
		)
	},
	received_contests_directory: "D:/Competitive-Programming/$(JUDGE)/$(CONTEST)",
	received_contests_problems_path: "$(PROBLEM)/_.$(FEXT)",
}
