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

if executable("ctags")
	silent! packadd vim-gutentags
	g:gutentags_define_advanced_commands = true
	g:gutentags_project_root = ['.root', '.svn', '.git', '.hg', '.project']
	g:gutentags_ctags_tagfile = '.tags'   # 所生成的数据文件的名称
	g:gutentags_ctags_extra_args = [
		'--fields=+niazS',
		'--extra=+q',                     # ctags 的参数，Exuberant-ctags 不能有 --extra=+q
		'--c++-kinds=+px',
		'--c-kinds=+px',
		'--output-format=e-ctags'         # 若用 universal ctags 需加，Exuberant-ctags 不加
	]
endif
