vim9script
g:popup_borderchars   = ['─', '│', '─', '│', '╭', '╮', '╯', '╰']
g:popup_borderchars_t = ['─', '│', '─', '│', '├', '┤', '╯', '╰']

g:loaded_netrw        = 1
g:loaded_netrwPlugin  = 1
nmap - <Cmd>Dir<CR>

silent! packadd comment
silent! packadd editexisting
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

xmap <M-x> <Plug>(CheckboxToggleOp)
nmap <M-x> <Plug>(CheckboxToggleOp)
omap <M-x> <Plug>(CheckboxToggleOp)

if executable("ctags")
	g:gutentags_exclude_filetypes = ['help']
	if executable('rg')
		g:gutentags_file_list_command = 'rg --files'
	elseif executable('git')
		g:gutentags_file_list_command = 'git ls-files'
	endif
	silent! packadd vim-gutentags
endif

if executable("man")
	silent! packadd vim-man
endif

if executable("gpg")
	silent! packadd vim-gnupg
endif

if executable("pio")
	silent! packadd vim-pio
endif

nmap =d <Cmd>DIstart<CR>
nmap \d <Cmd>DIstop<CR>

nmap <LocalLeader>v <Cmd>Vista!!<CR>

g:asynctasks_term_pos = "tab"
g:asyncrun_open       = 9
g:asyncrun_save       = true
g:asyncrun_bell       = true
if has("win32")
	g:asyncrun_encs = "cp936"
endif
map  <silent><F7>  <Esc><Cmd>AsyncTask file-run<CR>
imap <silent><F7>  <Esc><Cmd>AsyncTask file-run<CR>
map  <silent><F8>  <Esc><Cmd>AsyncTask file-build<CR>
imap <silent><F8>  <Esc><Cmd>AsyncTask file-build<CR>
map  <silent><F9>  <Esc><Cmd>AsyncTask project-run<CR>
imap <silent><F9>  <Esc><Cmd>AsyncTask project-run<CR>
map  <silent><F10> <Esc><Cmd>AsyncTask project-build<CR>
imap <silent><F10> <Esc><Cmd>AsyncTask project-build<CR>

xmap <Tab> <Plug>(EasyAlign)

nmap <Leader>u <Cmd>UndotreeToggle<CR>
g:undotree_SetFocusWhenToggle = true

g:html_font = ["Fira Code", "Consolas"]
omap i, <Plug>(swap-textobject-i)
xmap i, <Plug>(swap-textobject-i)
omap a, <Plug>(swap-textobject-a)
xmap a, <Plug>(swap-textobject-a)

command -nargs=? StartupTime delc StartupTime | packa vim-startuptime | StartupTime

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
