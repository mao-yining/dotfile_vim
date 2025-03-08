vim9script

packadd comment

call plug#begin()
Plug 'catppuccin/vim', { 'as': 'catppuccin' }
Plug 'stillwwater/wincap.vim'
Plug 'yianwillis/vimcdoc'

# coding [[[
Plug 'Eliot00/auto-pairs'                                                       # Vim9
Plug 'kshenoy/vim-signature'                                                    # show marks
Plug 'kana/vim-textobj-user'
Plug 'kana/vim-textobj-syntax'
Plug 'kana/vim-textobj-indent'
Plug 'kana/vim-textobj-function', { 'for': ['c', 'cpp', 'vim', 'java'] }
Plug 'sgur/vim-textobj-parameter'
Plug 'bps/vim-textobj-python', {'for': 'python'}
Plug 'jceb/vim-textobj-uri'
Plug 'andymass/vim-matchup'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-speeddating'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-characterize' # ga
Plug 'tpope/vim-surround'
Plug 'sheerun/vim-polyglot'
g:polyglot_disabled = ['sensible', 'markdown']
Plug 'tpope/vim-eunuch'
Plug 'girishji/vimbits'
Plug 'bootleq/vim-cycle', { 'on': '<Plug>CycleNext' }
Plug 'itchyny/calendar.vim', { 'on': 'Calendar' }
nmap <localleader>c <cmd>Calendar<cr>
nmap <silent> <c-s-a> <Plug>CycleNext
vmap <silent> <c-s-a> <Plug>CycleNext
# ]]]

# ui [[[
Plug 'mhinz/vim-startify'
autocmd User Startified setlocal cursorline
g:startify_enable_special      = 0
g:startify_files_number        = 5
g:startify_relative_path       = 1
g:startify_change_to_dir       = 1
g:startify_update_oldfiles     = 1
g:startify_session_autoload    = 1
g:startify_session_persistence = 1
g:startify_skiplist = [
	\ 'COMMIT_EDITMSG',
	\ '/data/repo/neovim/runtime/doc',
	\ '/Temp/',
	\ '/plugged/.*/doc/',
	\ ]

g:startify_bookmarks = [
	\ { 'c': $VIMRC },
	\ ]

g:startify_custom_footer =
   \ ['', "   Vim is charityware. Please read ':help uganda'.", '']

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
nnoremap <silent> <leader>      :<c-u>WhichKey '<Space>'<CR>
nnoremap <silent> <localleader> :<c-u>WhichKey  ';'<CR>
# nnoremap <silent> = :<c-u>WhichKey  '='<CR>

Plug 'vim-scripts/DrawIt', { 'on': 'DIstart' }
noremap <localleader>di <cmd>DIstart<cr>

Plug 'habamax/vim-dir', { 'on': [ 'Dir' ] }
nnoremap <silent>- <cmd>Dir<cr>

Plug 'lilydjwg/colorizer', { 'on': 'ColorHighlight' }
noremap =c <cmd>ColorHighlight<cr>
noremap \c <cmd>ColorClear<cr>

Plug 'liuchengxu/vista.vim', { 'on': 'Vista' }
nnoremap <silent><leader>cs <cmd>Vista!!<cr>

Plug 'dstein64/vim-startuptime', {'on': 'StartupTime'}

Plug 'itchyny/lightline.vim'
g:lightline = {
	  \ 'colorscheme': 'catppuccin_mocha',
	  \ 'active': {
	  \   'left': [ [ 'mode', 'paste' ],
	  \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
	  \ },
	  \ 'component_function': {
	  \   'gitbranch': 'FugitiveHead'
	  \ },
	  \ }

#  gutentags [[[
Plug 'ludovicchabant/vim-gutentags'                                             # 管理 tags 文件
Plug 'skywind3000/gutentags_plus', { 'on': 'GscopeFind' }
#  gutentags 搜索工程目录的标志，当前文件路径向上递归直到碰到这些文件/目录名
g:gutentags_project_root = ['.root', '.svn', '.git', '.hg', '.project']

#  所生成的数据文件的名称
g:gutentags_ctags_tagfile = '.tags'

#  同时开启 ctags 和 gtags 支持：
g:gutentags_modules = []
if executable('ctags')
	g:gutentags_modules += ['ctags']
endif
if executable('gtags-cscope') && executable('gtags')
	g:gutentags_modules += ['gtags_cscope']
endif

g:gutentags_cache_dir = expandcmd('~/.cache/tags') # 不要使用 expand()

#  配置 ctags 的参数，老的 Exuberant-ctags 不能有 --extra=+q，注意
g:gutentags_ctags_extra_args = ['--fields=+niazS', '--extra=+q']
g:gutentags_ctags_extra_args += ['--c++-kinds=+px']
g:gutentags_ctags_extra_args += ['--c-kinds=+px']

#  如果使用 universal ctags 需要增加下面一行，老的 Exuberant-ctags 不能加下一行
g:gutentags_ctags_extra_args += ['--output-format=e-ctags']

#  禁用 gutentags 自动加载 gtags 数据库的行为
g:gutentags_auto_add_gtags_cscope = 0

# change focus to quickfix window after search (optional).
g:gutentags_plus_switch = 1
#  ]]]

#  asynctasks [[[
Plug 'skywind3000/asyncrun.vim'
Plug 'skywind3000/asynctasks.vim'
g:asynctasks_term_pos = 'tab' # quickfix | vim | tab | bottom | external
# ‘vim' 时无法运行路径中有空格的情况
g:asyncrun_open = 6
noremap <silent><f7> <cmd>AsyncTask file-run<cr>
noremap <silent><f8> <cmd>AsyncTask file-build<cr>
noremap <silent><f9> <cmd>AsyncTask project-run<cr>
noremap <silent><f10> <cmd>AsyncTask project-build<cr>
#  ]]]

Plug 'vim-autoformat/vim-autoformat', { 'on': 'Autoformat' }
noremap <localleader>f <cmd>Autoformat<cr>
g:autoformat_autoindent = 0
g:autoformat_retab = 0
g:autoformat_remove_trailing_spaces = 0

g:formatdef_clangformat = "'clang-format -lines='.a:firstline.':'.a:lastline.' --assume-filename=\"'.expand('%:p').'\" --style=D:/Competitive-Programming/.clang-format'"
g:python3_host_prog = 'python'
Plug 'mbbill/undotree', { 'on': 'UndotreeToggle' } # 撤销树
noremap <leader>u <cmd>UndotreeToggle<cr>

Plug 'girishji/devdocs.vim'
nnoremap <leader>df :DevdocsFind<CR>
nnoremap <leader>di :DevdocsInstall<CR>
nnoremap <leader>du :DevdocsUninstall<CR>

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
Plug 'lervag/vimtex', { 'for': 'tex', 'on': 'VimtexInverseSearch' }
Plug 'dhruvasagar/vim-table-mode', { 'for': ['tex', 'markdown'] }
g:table_mode_corner = '|'
g:table_mode_always_active = 1
Plug 'junegunn/vim-easy-align', { 'on': '<Plug>(EasyAlign)' }
xmap <localleader>a <Plug>(EasyAlign)
nmap <localleader>a <Plug>(EasyAlign)
Plug 'ferrine/md-img-paste.vim', { 'for': 'markdown' }
Plug 'nathangrigg/vim-beancount', { 'for': 'bean' }

source $v/config/coc.vim

# Plug 'ZSaberLv0/ZFVimIM'
# Plug 'ZSaberLv0/ZFVimJob' # 可选, 用于提升词库加载性能
# Plug 'ZSaberLv0/ZFVimGitUtil' # 可选, 如果你希望定期自动清理词库 push 历史
# Plug 'github/copilot.vim', {'on': 'Copilot'}
# Plug 'exafunction/codeium.vim', {'on': 'Codeium'}
# Plug 'chenxuan520/vim-ai-doubao', {'on': ['AIChat', 'AI', 'AIEdit', 'AIConfigEdit']}
call plug#end()
# vim:fdm=marker:fmr=[[[,]]]:ft=vim
