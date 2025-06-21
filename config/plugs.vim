vim9script

packadd! comment
packadd! editexisting
packadd! editorconfig
packadd! nohlsearch
packadd! hlyank
packadd! helptoc
packadd! matchit
nnoremap <LocalLeader>t <Cmd>HelpToc<CR>
tnoremap <C-T><C-T> <Cmd>helptoc<CR>

call plug#begin()
Plug 'catppuccin/vim', { 'as': 'catppuccin' }
Plug 'stillwwater/wincap.vim'
Plug 'yianwillis/vimcdoc'

# coding [[[
Plug 'Eliot00/auto-pairs'         # vim9
Plug 'kshenoy/vim-signature'      # show marks
Plug 'wellle/targets.vim'
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
Plug 'Andrewradev/switch.vim'
g:speeddating_no_mappings = 1
nnoremap <Plug>SpeedDatingFallbackUp <C-A>
nnoremap <Plug>SpeedDatingFallbackDown <C-X>
nnoremap <silent><C-A> <Cmd>if !switch#Switch() <Bar> call speeddating#increment(v:count1) <Bar> endif<CR>
nnoremap <silent><C-X> <Cmd>if !switch#Switch({'reverse': 1}) <Bar> call speeddating#increment(-v:count1) <Bar> endif<CR>
Plug 'itchyny/calendar.vim', { 'on': 'Calendar' }
Plug 'voldikss/vim-browser-search', { 'on': ['<Plug>SearchNormal', '<Plug>SearchVisual'] }
g:browser_search_default_engine = "bing"
nmap <silent> <LocalLeader>s <Plug>SearchNormal
vmap <silent> <LocalLeader>s <Plug>SearchVisual
# ]]]

# ui [[[
Plug 'luochen1990/rainbow' # 彩虹括号
g:rainbow_conf = { 'guifgs': ['#da70d6', '#87cefa', ' #ffd700'] }
g:rainbow_active = 1

Plug 'mhinz/vim-startify'
autocmd user startified setlocal cursorline
g:startify_enable_special      = 0
g:startify_files_number        = 5
g:startify_relative_path       = 1
g:startify_change_to_dir       = 1
g:startify_update_oldfiles     = 1
g:startify_session_autoload    = 1
g:startify_session_persistence = 1
g:startify_session_dir = $v .. '/sessions'
g:startify_skiplist = [ "commit_editmsg", "/data/repo/neovim/runtime/doc", "/temp/", "/Plugged/.*/doc/" ]
g:startify_bookmarks = [ { 'c': $vimrc } ]
g:startify_custom_footer = ["", "   vim is charityware. please read ':help uganda'.", ""]

Plug 'itchyny/lightline.vim'
g:lightline = {
	"colorscheme": "catppuccin_mocha",
	"active": {
		"left": [
			[ "mode", "paste" ],
			[ "gitbranch", "readonly", "filename", "modified" ] ]
	},
	"component_function": {
		"gitbranch": "fugitivehead"
	},
}
# ]]]

Plug 'skywind3000/vim-terminal-help'
g:terminal_list = 0
if has('win32')
	g:terminal_shell = 'nu'
endif
tnoremap <C-\> <C-\><C-N>
tnoremap <M-H> <C-_>h
tnoremap <M-L> <C-_>l
tnoremap <M-J> <C-_>j
tnoremap <M-K> <C-_>k

Plug 't9md/vim-choosewin', { 'on': '<Plug>(choosewin)' }
nmap <M-w> <Plug>(choosewin)
imap <M-w> <Esc><Plug>(choosewin)
tnoremap <M-w> <C-\><C-n><Plug>(choosewin)

Plug 'liuchengxu/vim-which-key', { 'on': ['WhichKey', 'WhichKey!'] }
nnoremap <silent><nowait> <Leader>      <Cmd>WhichKey '<Space>'<CR>
nnoremap <silent><nowait> <LocalLeader> <Cmd>WhichKey ';'<CR>

Plug 'vim-scripts/DrawIt', { 'on': 'DIstart' }
noremap <LocalLeader>di <Cmd>DIstart<CR>

Plug 'habamax/vim-dir', { 'on': 'Dir' }
nnoremap <silent>- <Cmd>Dir<CR>

Plug 'lilydjwg/colorizer', { 'on': 'ColorHighlight' }
noremap =c <Cmd>ColorHighlight<CR>
noremap \c <Cmd>ColorClear<CR>

Plug 'liuchengxu/vista.vim', { 'on': 'Vista' }
nnoremap <silent><LocalLeader>v <Cmd>Vista!!<CR>

Plug 'dstein64/vim-startuptime', {'on': 'StartupTime'}

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
noremap <silent><f7> <Esc><Cmd>AsyncTask file-run<CR>
noremap <silent><f8> <Esc><Cmd>AsyncTask file-build<CR>
noremap <silent><f9> <Esc><Cmd>AsyncTask project-run<CR>
noremap <silent><f10> <Esc><Cmd>AsyncTask project-build<CR>
inoremap <silent><f7> <Esc><Cmd>AsyncTask file-run<CR>
inoremap <silent><f8> <Esc><Cmd>AsyncTask file-build<CR>
inoremap <silent><f9> <Esc><Cmd>AsyncTask project-run<CR>
inoremap <silent><f10> <Esc><Cmd>AsyncTask project-build<CR>
#  ]]]

Plug 'sbdchd/neoformat', { 'on': 'Neoformat' }
noremap <LocalLeader>f <Cmd>Neoformat<CR>
g:neoformat_basic_format_align = 1 # Enable alignment
g:neoformat_basic_format_retab = 1 # Enable tab to spaces conversion
g:neoformat_basic_format_trim = 1  # Enable trimmming of trailing whitespace
g:neoformat_cpp_clangformat = { 'exe': 'clang-format', 'args': [ expandcmd('-assume-filename="%"') ], 'stdin': 1, }
g:neoformat_tex_texfmt = { "exe": "tex-fmt", "args": [ "--stdin" ], "stdin": 1 }
g:neoformat_enabled_tex = [ "texfmt" ]

Plug 'mbbill/undotree', { 'on': 'UndotreeToggle' } # 撤销树
noremap <Leader>u <Cmd>UndotreeToggle<CR>

Plug 'girishji/devdocs.vim'
nnoremap <Leader>df <Cmd>DevdocsFind<CR>
nnoremap <Leader>di <Cmd>DevdocsInstall<CR>
nnoremap <Leader>du <Cmd>DevdocsUninstall<CR>

#  Git [[[
Plug 'tpope/vim-fugitive'
Plug 'junegunn/gv.vim', { 'on': ['GV', 'GV!'] }
nnoremap <Leader>gg <Cmd>Git<CR>
nnoremap <Leader>gl <Cmd>GV<CR>
nnoremap <Leader>gcc <Cmd>Git commit<CR>
nnoremap <Leader>gca <Cmd>Git commit --amend<CR>
nnoremap <Leader>gce <Cmd>Git commit --amend --no-edit<CR>
nnoremap <Leader>gs :Git switch<Space>
nnoremap <Leader>gS :Git stash<Space>
nnoremap <Leader>gco :Git checkout<Space>
nnoremap <Leader>gcp :Git cherry-pick<Space>
nnoremap <Leader>gm :Git merge<Space>
nnoremap <Leader>gcb <Cmd>Git branch<CR>
nnoremap <Leader>gp <Cmd>Git! pull<CR>
nnoremap <Leader>gP <Cmd>Git! push<CR>
nnoremap <Leader>gM <Cmd>Git mergetool<CR>
nnoremap <Leader>gd <Cmd>Git diff<CR>
nnoremap <Leader>gD <Cmd>Git difftool<CR>
nnoremap <Leader>gB <Cmd>Git branch<CR>
nnoremap <Leader>gb <Cmd>Git blame<CR>
nnoremap <Leader>gr <Cmd>Gread<CR>
nnoremap <Leader>gw <Cmd>Gwrite<CR>
Plug 'airblade/vim-gitgutter'
nmap <LocalLeader>hw <Plug>(GitGutterStageHunk)
nmap <LocalLeader>hr <Plug>(GitGutterUndoHunk)
nmap <LocalLeader>hp <Plug>(GitGutterPreviewHunk)
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
Plug 'ubaldot/vim-conda-activate', { 'on': 'CondaActivate' }
Plug 'bfrg/vim-cmake-help', { 'for': 'cmake' }
Plug 'lervag/vimtex', { 'for': 'tex', 'on': ['VimtexInverseSearch', 'VimtexDocPackage']}
Plug 'junegunn/vim-easy-align', { 'on': '<Plug>(EasyAlign)' }
xmap <LocalLeader>a <Plug>(EasyAlign)
nmap <LocalLeader>a <Plug>(EasyAlign)
Plug 'ferrine/md-img-paste.vim', { 'for': 'markdown' }
Plug 'nathangrigg/vim-beancount', { 'for': 'bean' }
Plug 'editorconfig/editorconfig-vim'
Plug 'normen/vim-pio'

# vimspector [[[
Plug 'puremourning/vimspector'
g:vimspector_install_gadgets = [ 'debugpy', 'vscode-cpptools', 'CodeLLDB' ]
nnoremap <F5>          <Plug>VimspectorContinue
nnoremap <F3>          <Plug>VimspectorToggleBreakpoint
nnoremap <Leader><F3>  <Plug>VimspectorRunToCursor
nnoremap <F4>          <Plug>VimspectorAddFunctionBreakpoint
nnoremap <Leader><F4>  <Plug>VimspectorToggleConditionalBreakpoint
g:vimspector_enable_winbar = 0
autocmd User VimspectorDebugEnded g:UnLoadVimspectorMaps()
autocmd User VimspectorUICreated g:LoadVimspectorMaps()
def g:LoadVimspectorMaps()
	nnoremap <Leader><F5>  <Plug>VimspectorStop
	nnoremap <F6>          <Plug>VimspectorStepOver
	nnoremap <F7>          <Plug>VimspectorStepInto
	nnoremap <F8>          <Plug>VimspectorStepOut
	nnoremap <F9>          <Plug>VimspectorPause
	nnoremap <F10>         <Plug>VimspectorRestart
	nnoremap <Leader><F11> <Plug>VimspectorUpFrame
	nnoremap <Leader><F12> <Plug>VimspectorDownFrame
	nnoremap <Leader>B     <Plug>VimspectorBreakpoints
	nnoremap <Leader>D     <Plug>VimspectorDisassemble
enddef
def g:UnLoadVimspectorMaps()
	if exists('<Leader><F5>')|nunmap <Leader><F5>|endif
	if exists('<F6>')|nunmap <F6>|endif
	nnoremap <silent><F7> <Esc><Cmd>AsyncTask file-run<CR>
	nnoremap <silent><F8> <Esc><Cmd>AsyncTask file-build<CR>
	nnoremap <silent><F9> <Esc><Cmd>AsyncTask project-run<CR>
	nnoremap <silent><F10> <Esc><Cmd>AsyncTask project-build<CR>
	if exists('<Leader><F11>')|nunmap <Leader><F11>|endif
	if exists('<Leader><F12>')|nunmap <Leader><F12>|endif
	if exists('<Leader>B')|nunmap <Leader>B|endif
	if exists('<Leader>D')|nunmap <Leader>D|endif
enddef
# ]]]

source $v/config/coc.vim
source $v/config/ale.vim

call plug#end()
# vim:fdm=marker:fmr=[[[,]]]:ft=vim
