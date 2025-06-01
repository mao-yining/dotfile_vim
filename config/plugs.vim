vim9script

packadd! comment
packadd! editexisting
packadd! editorconfig
packadd! nohlsearch
packadd! hlyank
packadd! helptoc
packadd! matchit
nnoremap <LocalLeader>t <Cmd>HelpToc<CR>
tnoremap <C-t><C-t> <Cmd>HelpToc<CR>

call plug#begin()
Plug 'catppuccin/vim', { 'as': 'catppuccin' }
Plug 'stillwwater/wincap.vim'
Plug 'yianwillis/vimcdoc'

# coding [[[
Plug 'Eliot00/auto-pairs'         # Vim9
Plug 'kshenoy/vim-signature'      # show marks
Plug 'kana/vim-textobj-user'
Plug 'kana/vim-textobj-syntax'
Plug 'kana/vim-textobj-indent'
Plug 'kana/vim-textobj-function', { 'for': ['c', 'cpp', 'vim', 'java'] }
Plug 'sgur/vim-textobj-parameter' # `a,` `i,`
Plug 'bps/vim-textobj-python', {'for': 'python'}
Plug 'jceb/vim-textobj-uri'
Plug 'andymass/vim-matchup'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-speeddating'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-characterize'     # 'ga' improve
Plug 'tpope/vim-surround'
Plug 'sheerun/vim-polyglot'
g:polyglot_disabled = ['sensible', 'markdown']
g:markdown_fenced_languages = ['html', 'python', 'bash', 'c', 'cpp', 'shell=sh', 'tex', 'dosbatch']
g:markdown_minlines = 500
Plug 'tpope/vim-eunuch'
Plug 'girishji/vimbits'
g:vimbits_highlightonyank = false
Plug 'AndrewRadev/switch.vim'
g:speeddating_no_mappings = 1
nnoremap <Plug>SpeedDatingFallbackUp <c-a>
nnoremap <Plug>SpeedDatingFallbackDown <c-x>
nnoremap <silent><c-a> <cmd>if !switch#Switch() <bar> call speeddating#increment(v:count1) <bar> endif<cr>
nnoremap <silent><c-x> <cmd>if !switch#Switch({'reverse': 1}) <bar> call speeddating#increment(-v:count1) <bar> endif<cr>
Plug 'itchyny/calendar.vim', { 'on': 'Calendar' }
# ]]]

# ui [[[
Plug 'luochen1990/rainbow' # 彩虹括号
g:rainbow_conf = { 'guifgs': ['#da70d6', '#87cefa', ' #ffd700'] }
g:rainbow_active = 1

Plug 'mhinz/vim-startify'
autocmd User Startified setlocal cursorline
g:startify_enable_special      = 0
g:startify_files_number        = 5
g:startify_relative_path       = 1
g:startify_change_to_dir       = 1
g:startify_update_oldfiles     = 1
g:startify_session_autoload    = 1
g:startify_session_persistence = 1
g:startify_session_dir = $v .. '/sessions'
g:startify_skiplist = [ "COMMIT_EDITMSG", "/data/repo/neovim/runtime/doc", "/Temp/", "/plugged/.*/doc/" ]
g:startify_bookmarks = [ { 'c': $VIMRC } ]
g:startify_custom_footer = ["", "   Vim is charityware. Please read ':help uganda'.", ""]

# ]]]

Plug 'skywind3000/vim-terminal-help'
g:terminal_list = 0
if has('win32')
	g:terminal_shell = 'pwsh -NoProfile'
endif
tnoremap <c-\> <c-\><c-n>
tnoremap <m-H> <c-_>h
tnoremap <m-L> <c-_>l
tnoremap <m-J> <c-_>j
tnoremap <m-K> <c-_>k

Plug 't9md/vim-choosewin', { 'on': '<Plug>(choosewin)' }
nmap <m-w> <Plug>(choosewin)
imap <m-w> <esc><Plug>(choosewin)
tnoremap <m-w> <c-\><c-n><Plug>(choosewin)

Plug 'liuchengxu/vim-which-key', { 'on': ['WhichKey', 'WhichKey!'] }
nnoremap <silent><nowait> <Leader>      <Cmd>WhichKey '<Space>'<CR>
nnoremap <silent><nowait> <LocalLeader> <Cmd>WhichKey ';'<CR>

Plug 'vim-scripts/DrawIt', { 'on': 'DIstart' }
noremap <localleader>di <cmd>DIstart<cr>

Plug 'habamax/vim-dir', { 'on': 'Dir' }
nnoremap <silent>- <cmd>Dir<cr>

Plug 'lilydjwg/colorizer', { 'on': 'ColorHighlight' }
noremap =c <cmd>ColorHighlight<cr>
noremap \c <cmd>ColorClear<cr>

Plug 'liuchengxu/vista.vim', { 'on': 'Vista' }
nnoremap <silent><localleader>v <cmd>Vista!!<cr>

Plug 'dstein64/vim-startuptime', {'on': 'StartupTime'}

Plug 'itchyny/lightline.vim'
g:lightline = {
	"colorscheme": "catppuccin_mocha",
	"active": {
		"left": [
			[ "mode", "paste" ],
			[ "gitbranch", "readonly", "filename", "modified" ] ]
	},
	"component_function": {
		"gitbranch": "FugitiveHead"
	},
}

# gutentags 管理 tags 文件[[[
Plug 'ludovicchabant/vim-gutentags', { 'on': 'GutentagsToggleEnabled' }
Plug 'skywind3000/gutentags_plus', { 'on': 'GscopeFind' }
# gutentags 搜索工程目录的标志当前文件路径向上递归直到碰到这些文件/目录名
g:gutentags_project_root = ['.root', '.svn', '.git', '.hg', '.project']
g:gutentags_ctags_tagfile = '.tags'   # 所生成的数据文件的名称
g:gutentags_modules = []              # 同时开启 ctags 和 gtags 支持
if executable('ctags')
	g:gutentags_modules += ['ctags']
endif
if executable('gtags-cscope') && executable('gtags')
	g:gutentags_modules += ['gtags_cscope']
endif
g:gutentags_cache_dir = expandcmd('~/.cache/tags')
g:gutentags_ctags_extra_args = [
	'--fields=+niazS',
	'--extra=+q',                     # ctags 的参数，Exuberant-ctags 不能有 --extra=+q
	'--c++-kinds=+px',
	'--c-kinds=+px',
	'--output-format=e-ctags'         # 若用 universal ctags 需加，Exuberant-ctags 不加
]
g:gutentags_auto_add_gtags_cscope = 0 # 禁用 gutentags 自动加载 gtags 数据库
g:gutentags_plus_switch = 1
# ]]]

#  asynctasks [[[
Plug 'skywind3000/asyncrun.vim'
Plug 'skywind3000/asynctasks.vim'
g:asynctasks_term_pos = 'tab' # quickfix | vim | tab | bottom | external
# ‘vim' 时无法运行路径中有空格的情况
g:asyncrun_open = 6
g:asyncrun_save = 1
noremap <silent><f7> <cmd>AsyncTask file-run<cr>
noremap <silent><f8> <cmd>AsyncTask file-build<cr>
noremap <silent><f9> <cmd>AsyncTask project-run<cr>
noremap <silent><f10> <cmd>AsyncTask project-build<cr>
inoremap <silent><f7> <esc><cmd>AsyncTask file-run<cr>
inoremap <silent><f8> <esc><cmd>AsyncTask file-build<cr>
inoremap <silent><f9> <esc><cmd>AsyncTask project-run<cr>
inoremap <silent><f10> <esc><cmd>AsyncTask project-build<cr>
#  ]]]

Plug 'sbdchd/neoformat', { 'on': 'Neoformat' }
noremap <localleader>f <cmd>Neoformat<cr>
g:neoformat_basic_format_align = 1 # Enable alignment
g:neoformat_basic_format_retab = 1 # Enable tab to spaces conversion
g:neoformat_basic_format_trim = 1  # Enable trimmming of trailing whitespace
g:neoformat_cpp_clangformat = { 'exe': 'clang-format', 'args': [ expandcmd('-assume-filename=%') ], 'stdin': 1 }
g:neoformat_tex_texfmt = { "exe": "tex-fmt", "args": [ "--stdin" ], "stdin": 1 }
g:neoformat_enabled_tex = [ "texfmt" ]

Plug 'mbbill/undotree', { 'on': 'UndotreeToggle' } # 撤销树
noremap <leader>u <cmd>UndotreeToggle<cr>

Plug 'girishji/devdocs.vim'
nnoremap <leader>df <Cmd>DevdocsFind<CR>
nnoremap <leader>di <Cmd>DevdocsInstall<CR>
nnoremap <leader>du <Cmd>DevdocsUninstall<CR>

#  Git [[[
Plug 'tpope/vim-fugitive'
Plug 'junegunn/gv.vim', { 'on': ['GV', 'GV!'] }
nnoremap <leader>gg <cmd>Git<cr>
nnoremap <leader>gl <cmd>GV<cr>
nnoremap <leader>gcc <cmd>Git commit<cr>
nnoremap <leader>gca <cmd>Git commit --amend<cr>
nnoremap <leader>gce <cmd>Git commit --amend --no-edit<cr>
nnoremap <leader>gs :Git switch<space>
nnoremap <leader>gS :Git stash<space>
nnoremap <leader>gco :Git checkout<space>
nnoremap <leader>gcp :Git cherry-pick<space>
nnoremap <leader>gm :Git merge<space>
nnoremap <leader>gcb <cmd>Git branch<cr>
nnoremap <leader>gp <cmd>Git! pull<cr>
nnoremap <leader>gP <cmd>Git! push<cr>
nnoremap <leader>gM <cmd>Git mergetool<cr>
nnoremap <leader>gd <cmd>Git diff<cr>
nnoremap <leader>gD <cmd>Git difftool<cr>
nnoremap <leader>gB <cmd>Git branch<cr>
nnoremap <leader>gb <cmd>Git blame<cr>
nnoremap <leader>gr <cmd>Gread<cr>
nnoremap <leader>gw <cmd>Gwrite<cr>
Plug 'airblade/vim-gitgutter'
nmap <localleader>hw <Plug>(GitGutterStageHunk)
nmap <localleader>hr <Plug>(GitGutterUndoHunk)
nmap <localleader>hp <Plug>(GitGutterPreviewHunk)
omap ih <Plug>(GitGutterTextObjectInnerPending)
omap ah <Plug>(GitGutterTextObjectOuterPending)
xmap ih <Plug>(GitGutterTextObjectInnerVisual)
xmap ah <Plug>(GitGutterTextObjectOuterVisual)
nmap ]h <Plug>(GitGutterNextHunk)
nmap [h <Plug>(GitGutterPrevHunk)
g:gitgutter_map_keys = 0
g:gitgutter_preview_win_floating = 1
Plug 'Eliot00/git-lens.vim'
Plug 'rhysd/conflict-marker.vim'
Plug 'mhinz/vim-signify', { 'on': 'SignifyEnable' }
g:signify_sign_add               = '+'
g:signify_sign_delete            = '_'
g:signify_sign_delete_first_line = '‾'
g:signify_sign_change            = '~'
g:signify_sign_changedelete      = g:signify_sign_change
#  ]]]

Plug 'vim-utils/vim-man', { 'on': ['Man', 'Mangrep']}
Plug 'jamessan/vim-gnupg'
Plug 'vimwiki/vimwiki', { 'for': 'vimwiki' }
Plug 'romainl/vim-qf', { 'for': 'qf' }
Plug 'bfrg/vim-qf-preview', { 'for': 'qf' }
Plug 'ubaldot/vim-replica', { 'on': '<Plug>ReplicaConsoleToggle' } # jupyter
Plug 'chenxuan520/vim-go-highlight', {'for': 'go'}
Plug 'ubaldot/vim-conda-activate', { 'on': 'CondaActivate' }
Plug 'ubaldot/vim-microdebugger', { 'on': 'MicroDebug' }
Plug 'bfrg/vim-cmake-help', { 'for': 'cmake' }
Plug 'jceb/vim-orgmode', { 'for': 'org' }
Plug 'lervag/vimtex', { 'for': 'tex', 'on': ['VimtexInverseSearch', 'VimtexDocPackage']}
Plug 'junegunn/vim-easy-align', { 'on': '<Plug>(EasyAlign)' }
xmap <localleader>a <Plug>(EasyAlign)
nmap <localleader>a <Plug>(EasyAlign)
Plug 'ferrine/md-img-paste.vim', { 'for': 'markdown' }
Plug 'nathangrigg/vim-beancount', { 'for': 'bean' }
Plug 'puremourning/vimspector'
g:vimspector_enable_mappings = 'HUMAN'
g:vimspector_install_gadgets = [ 'debugpy', 'vscode-cpptools', 'CodeLLDB' ]
nmap <LocalLeader><F11> <Plug>VimspectorUpFrame
nmap <LocalLeader><F12> <Plug>VimspectorDownFrame
nmap <LocalLeader>B     <Plug>VimspectorBreakpoints
nmap <LocalLeader>D     <Plug>VimspectorDisassemble

source $v/config/coc.vim
source $v/config/ale.vim

call plug#end()
# vim:fdm=marker:fmr=[[[,]]]:ft=vim
