vim9script
# Check after/plugin/if_loaded.vim for settings that depends on plugin existence
# Plugin settings

packadd comment
# packadd editexisting
packadd editorconfig
packadd helptoc
packadd hlyank
packadd matchit
packadd nohlsearch

g:popup_borderchars = ['─', '│', '─', '│', '╭', '╮', '╯', '╰']
g:popup_borderchars_t = ['─', '│', '─', '│', '├', '┤', '╯', '╰']
g:hlyank_duration = 200

g:loaded_netrw       = 1
g:loaded_netrwPlugin = 1
nmap - <Cmd>Dir<CR>

if executable("ctags")
	silent! packadd vim-gutentags
	g:gutentags_exclude_filetypes = ['help']
endif

nmap <silent> <LocalLeader>tt <Cmd>TestNearest<CR>
nmap <silent> <LocalLeader>tf <Cmd>TestFile<CR>
nmap <silent> <LocalLeader>ts <Cmd>TestSuite<CR>
nmap <silent> <LocalLeader>tl <Cmd>TestLast<CR>
nmap <silent> <LocalLeader>tv <Cmd>TestVisit<CR>
g:test#strategy = "vimterminal"

nmap <Leader>u <Cmd>UndotreeToggle<CR>
g:undotree_SetFocusWhenToggle = true

g:competitest_configs = {
	# multiple_testing: 1,
	output_compare_method: (output: string, expout: string) => {
		def TrimString(str: string): string
			return str
				->substitute('\s*\n', '\n', 'g') # 去除行尾空格
				->substitute('^\s*', '', '')     # 删除开头的所有空白字符
				->substitute('\s*$', '', '')     # 删除结尾的所有空白字符
		enddef
		return TrimString(output) == TrimString(expout)
	},
	testcases_input_file_format: "$(FNOEXT)$(TCNUM).in",
	testcases_output_file_format: "$(FNOEXT)$(TCNUM).ans",
	template_file: "D:/Competitive-Programming/template/template.$(FEXT)",
	evaluate_template_modifiers: true,
	received_problems_path: (task, file_extension): string => {
		var hyphen = stridx(task.group, " - ")
		var judge: string
		var contest: string
		if hyphen == -1
			judge = task.group
			contest = "problems"
		else
			judge = strpart(task.group, 0, hyphen)
			contest = strpart(task.group, hyphen + 3)
		endif

		const safe_contest = substitute(substitute(contest, '[<>:"/\\|?*]', '_', 'g'), '#', '', 'g')
		const safe_name = substitute(substitute(task.name, '[<>:"/\\|?*]', '_', 'g'), '#', '', 'g')

		return printf(
			"D:/Competitive-Programming/%s/%s/%s/_.%s",
			judge,
			safe_contest,
			safe_name,
			file_extension
		)
	},
	received_contests_directory: "D:/Competitive-Programming/$(JUDGE)/$(CONTEST)",
	received_contests_problems_path: "$(PROBLEM)/_.$(FEXT)",
}
