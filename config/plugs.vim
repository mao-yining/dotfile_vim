vim9script

packadd comment
if has('win32')
	packadd wincap.vim
	g:wincap_plugin_exe = $v .. '/pack/ui/opt/wincap.vim/bin/wincap.exe'
endif

call plug#begin()
Plug 'yianwillis/vimcdoc'
Plug 'mhinz/vim-startify'
Plug 'Eliot00/auto-pairs'                                                       # Vim9
Plug 'kshenoy/vim-signature'                                                    # show marks
Plug 'kana/vim-textobj-user'
Plug 'kana/vim-textobj-syntax'
Plug 'kana/vim-textobj-indent'
Plug 'kana/vim-textobj-function', { 'for': ['c', 'cpp', 'vim', 'java'] }
Plug 'sgur/vim-textobj-parameter'
Plug 'bps/vim-textobj-python', {'for': 'python'}
Plug 'jceb/vim-textobj-uri'
Plug 'skywind3000/vim-terminal-help'
Plug 't9md/vim-choosewin', { 'on': '<Plug>(choosewin)' }
Plug 'andymass/vim-matchup'
Plug 'liuchengxu/vim-which-key', { 'on': ['WhichKey', 'WhichKey!'] }
# Plug 'tpope/vim-obsession'
# Plug 'dhruvasagar/vim-prosession'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-speeddating'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-sleuth'
Plug 'tpope/vim-eunuch'
Plug 'girishji/vimbits'
Plug 'vim-scripts/DrawIt', { 'on': 'DIstart' }
Plug 'lambdalisue/vim-fern', { 'on': 'Fern' }
Plug 'lambdalisue/fern-git-status.vim', { 'on': 'Fern' }
Plug 'lambdalisue/fern-renderer-nerdfont.vim', { 'on': 'Fern' }
Plug 'lambdalisue/glyph-palette.vim', { 'on': 'Fern' }
Plug 'lambdalisue/vim-nerdfont'
Plug 'dense-analysis/ale'
Plug 'ludovicchabant/vim-gutentags'                                             # 管理 tags 文件
Plug 'skywind3000/gutentags_plus', { 'on': 'GscopeFind' }
Plug 'catppuccin/vim', { 'as': 'catppuccin' }
Plug 'lilydjwg/colorizer', { 'on': 'ColorHighlight' }
Plug 'luochen1990/rainbow'                                                      # 彩虹括号
Plug 'liuchengxu/vista.vim', { 'on': 'Vista' }
Plug 'dstein64/vim-startuptime', {'on': 'StartupTime'}
Plug 'itchyny/lightline.vim'
Plug 'skywind3000/asyncrun.vim', { 'on': ['AsyncRun', 'AsyncStop'] }
Plug 'skywind3000/asynctasks.vim', { 'on': ['AsyncTask', 'AsyncTaskMacro', 'AsyncTaskList', 'AsyncTaskEdit'], 'for': 'taskini' }
Plug 'vim-autoformat/vim-autoformat', { 'on': 'Autoformat' }
Plug 'mbbill/undotree', { 'on': 'UndotreeToggle' }                              # 撤销树
Plug 'vim-utils/vim-man', { 'on': ['Man', 'Mangrep']}
Plug 'jamessan/vim-gnupg'
Plug 'tbastos/vim-lua', { 'for': 'lua' }
Plug 'vimwiki/vimwiki', { 'for': 'vimwiki' }
Plug 'romainl/vim-qf', { 'for': 'qf' }
Plug 'bfrg/vim-qf-preview', { 'for': 'qf' }
Plug 'tpope/vim-fugitive', { 'on': ['Git', 'GV', 'GV!', 'Gread', 'Gwrite', 'Gclog', 'Flog']}
Plug 'rbong/vim-flog', { 'on': [ "Flog", "Flogsplit", "Floggit" ], }
Plug 'junegunn/gv.vim', { 'on': ['Git', 'GV', 'GV!']}
Plug 'airblade/vim-gitgutter'                                                   # 在侧边显示 Git 文件修改信息
Plug 'mhinz/vim-signify', { 'on': 'SignifyEnable' }
Plug 'ubaldot/vim-replica', { 'on': '<Plug>ReplicaConsoleToggle' }              # jupyter
Plug 'octol/vim-cpp-enhanced-highlight', { 'for': 'cpp' }
Plug 'chenxuan520/vim-go-highlight', {'for': 'go'}
Plug 'kh3phr3n/python-syntax', {'for': 'python'}
Plug 'ubaldot/vim-conda-activate', { 'on': 'CondaActivate' }
Plug 'ubaldot/vim-microdebugger', { 'on': 'MicroDebug' }
Plug 'bfrg/vim-cmake-help', { 'for': 'cmake' }
Plug 'jceb/vim-orgmode', { 'for': 'org' }
Plug 'lervag/vimtex', { 'for': 'tex', 'on': 'VimtexInverseSearch' }
Plug 'dhruvasagar/vim-table-mode', { 'for': ['tex', 'markdown'] }
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
Plug 'godlygeek/tabular', { 'on': 'Tabularize' }
Plug 'preservim/vim-markdown', { 'for': 'markdown' }
Plug 'ferrine/md-img-paste.vim', { 'for': 'markdown' }
Plug 'preservim/vim-pencil', { 'for': [ 'text', 'markdown', 'tex' ] }
Plug 'chrisbra/csv.vim', { 'for': 'csv' }
Plug 'nathangrigg/vim-beancount', { 'for': 'bean' }
Plug 'yegappan/lsp'
# Plug 'jessepav/vim-boxdraw'
Plug 'Donaldttt/fuzzyy'
Plug 'girishji/devdocs.vim'

# Plug 'ZSaberLv0/ZFVimIM'
# Plug 'ZSaberLv0/ZFVimJob' # 可选, 用于提升词库加载性能
# Plug 'ZSaberLv0/ZFVimGitUtil' # 可选, 如果你希望定期自动清理词库 push 历史
# Plug 'leafOfTree/vim-project'
Plug 'girishji/vimcomplete'
# Plug 'girishji/vimsuggest'
Plug 'girishji/ngram-complete.vim'
Plug 'girishji/devdocs.vim'
# Plug 'girishji/scope.vim'
Plug 'hrsh7th/vim-vsnip'
Plug 'hrsh7th/vim-vsnip-integ'
Plug 'rafamadriz/friendly-snippets'
# copilot
# Plug 'github/copilot.vim', {'on': 'Copilot'}
# Plug 'exafunction/codeium.vim', {'on': 'Codeium'}
# vim-ai
# Plug 'chenxuan520/vim-ai-doubao', {'on': ['AIChat', 'AI', 'AIEdit', 'AIConfigEdit']}
call plug#end()

g:prosession_dir = expandcmd('~/.cache/sessions/')
nmap <m-w> <Plug>(choosewin)
imap <m-w> <esc><Plug>(choosewin)
tnoremap <m-w> <c-\><c-n><Plug>(choosewin)
# g:startify_disable_at_vimenter = 1
g:startify_session_dir = '~/.cache/sessions'
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
	\ ]

g:startify_bookmarks = [
	\ { 'c': $VIMRC },
	\ ]

g:startify_custom_footer =
   \ ['', "   Vim is charityware. Please read ':help uganda'.", '']

hi StartifyBracket ctermfg=240
hi StartifyFile    ctermfg=147
hi StartifyFooter  ctermfg=240
hi StartifyHeader  ctermfg=114
hi StartifyNumber  ctermfg=215
hi StartifyPath    ctermfg=245
hi StartifySlash   ctermfg=240
hi StartifySpecial ctermfg=240
nnoremap <silent> <leader>      :<c-u>WhichKey '<Space>'<CR>
nnoremap <silent> <localleader> :<c-u>WhichKey  ';'<CR>
# nnoremap <silent> = :<c-u>WhichKey  '='<CR>
noremap =c <cmd>ColorHighlight<cr>
noremap \c <cmd>ColorClear<cr>
noremap <localleader>di <cmd>DIstart<cr>
# UI [[[
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
g:rainbow_conf = { 'guifgs': ['#da70d6', '#87cefa', ' #ffd700'] }
g:rainbow_active = 1
nnoremap <silent>- <cmd>Fern %:h -reveal=%<cr>
nnoremap <silent><leader>e <cmd>Fern . -reveal=%<cr>
nnoremap <leader>e <cmd>Fern . -reveal=% -drawer<cr><cmd>setlocal nonumber<cr>
g:fern#renderer = "nerdfont"
#  ]]]

#  Leaderf [[[
nnoremap <leader>df :DevdocsFind<CR>
nnoremap <leader>di :DevdocsInstall<CR>
nnoremap <leader>du :DevdocsUninstall<CR>
nnoremap <silent> <localleader>b :FuzzyBuffers<CR>
nnoremap <silent> <leader>: :FuzzyCommands<CR>
nnoremap <silent> <leader>f :FuzzyFiles<CR>
nnoremap <silent> <leader><space> :FuzzyFiles<CR>
nnoremap <silent> <leader>sg :FuzzyGrep<CR>
nnoremap <silent> <leader>h :FuzzyHelp<CR>
nnoremap <silent> <leader>/ :FuzzyInBuffer<CR>
nnoremap <silent> <leader>m :FuzzyMru<CR>
nnoremap <silent> <leader>r :FuzzyMruCwd<CR>
nnoremap <silent> <leader>fb :FuzzyBuffers<CR>
nnoremap <silent> <leader>fc :FuzzyCommands<CR>
nnoremap <silent> <leader>ff :FuzzyFiles<CR>
nnoremap <silent> <leader>fg :FuzzyGrep<CR>
nnoremap <silent> <leader>fh :FuzzyHelp<CR>
nnoremap <silent> <leader>fi :FuzzyInBuffer<CR>
nnoremap <silent> <leader>fm :FuzzyMru<CR>
nnoremap <silent> <leader>fr :FuzzyMruCwd<CR>
#  ]]]

#  Git [[[
g:signify_sign_add               = '+'
g:signify_sign_delete            = '_'
g:signify_sign_delete_first_line = '‾'
g:signify_sign_change            = '~'
g:signify_sign_changedelete      = g:signify_sign_change
g:gitgutter_map_keys = 0
g:gitgutter_preview_win_floating = 1
nmap <localleader>hs <Plug>(GitGutterStageHunk)
nmap <localleader>hu <Plug>(GitGutterUndoHunk)
nmap <localleader>hp <Plug>(GitGutterPreviewHunk)
omap ih <Plug>(GitGutterTextObjectInnerPending)
omap ah <Plug>(GitGutterTextObjectOuterPending)
xmap ih <Plug>(GitGutterTextObjectInnerVisual)
xmap ah <Plug>(GitGutterTextObjectOuterVisual)
nmap ]h <Plug>(GitGutterNextHunk)
nmap [h <Plug>(GitGutterPrevHunk)
nnoremap <leader>gg <cmd>Git<cr>
nnoremap <leader>gl <cmd>Flog<cr>
nnoremap <localleader>gb <cmd>Git blame<cr>
nnoremap <localleader>gr <cmd>Gread<cr>
nnoremap <localleader>gw <cmd>Gwrite<cr>
#  ]]]

#  cpp [[[
g:cpp_class_scope_highlight = 1
g:cpp_class_decl_highlight = 1
g:cpp_member_variable_highlight = 1
g:cpp_posix_standard = 1
g:cpp_experimental_simple_template_highlight = 1
g:cpp_concepts_highlight = 1
#  ]]]

#  gutentags [[[
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
g:vista_executive_for = {
			\ 'c': 'ale',
			\ 'cpp': 'ale',
			\ 'markdown': 'ale',
			\ }
#  ]]]


#  ALE [[[
g:vimcomplete_tab_enable = 1
var lspServers = [
	# {
	# 	name: 'typescriptls',
	# 	filetype: ['javascript', 'typescript'],
	# 	path: '/usr/local/bin/typescript-language-server',
	# 	args: ['--stdio']
	# },
	{
		name: 'pyright',
		filetype: 'python',
		path: 'pyright-langserver',
		args: ['--stdio'],
		workspaceConfig: {
		  python: {
			pythonPath: '/usr/bin/python3.10'
		}}
	},
	{
		name: 'clangd',
		filetype: ['c', 'cpp'],
		path: 'clangd',
		args: ['--background-index', '--clang-tidy', '--header-insertion=iwyu', '--completion-style=detailed', '--function-arg-placeholders', '--fallback-style=llvm' ]
	},
	# {
	# 	name: 'golang',
	# 	filetype: ['go', 'gomod', 'gohtmltmpl', 'gotexttmpl'],
	# 	path: '/path/to/.go/bin/gopls',
	# 	args: [],
	# 	syncInit: true,
	# },
	{
		name: 'rustls',
		filetype: ['rust'],
		path: 'rust-analyzer',
		args: [],
		syncInit: true,
	},
	# {
	# 	name: 'bashls',
	# 	filetype: 'sh',
	# 	path: '/usr/local/bin/bash-language-server',
	# 	args: ['start']
	# },
	{
		name: 'vimls',
		filetype: ['vim'],
		path: 'vim-language-server',
		args: ['--stdio']
	},
	# {
	# 	name: 'phpls',
	# 	filetype: ['php'],
	# 	path: '/usr/local/bin/intelephense',
	# 	args: ['--stdio'],
	# 	syncInit: true,
	# 	initializationOptions: {
	# 		licenceKey: 'xxxxxxxxxxxxxxx'
	# 	}
	# }
]
var lspOpts = {
	aleSupport: false,
	autoComplete: true,
	autoHighlight: false,
	autoHighlightDiags: true,
	completionMatcher: 'case',
	completionMatcherValue: 1,
	diagSignErrorText: 'E>',
	diagSignHintText: 'H>',
	diagSignInfoText: 'I>',
	diagSignWarningText: 'W>',
	echoSignature: false,
	hideDisabledCodeActions: false,
	highlightDiagInline: true,
	hoverInPreview: false,
	ignoreMissingServer: false,
	keepFocusInDiags: true,
	keepFocusInReferences: true,
	completionTextEdit: true,
	diagVirtualTextAlign: 'above',
	diagVirtualTextWrap: 'default',
	noNewlineInCompletion: false,
	omniComplete: null,
	outlineOnRight: false,
	outlineWinSize: 20,
	semanticHighlight: true,
	showDiagInBalloon: true,
	showDiagInPopup: true,
	showDiagOnStatusLine: false,
	showDiagWithSign: true,
	showDiagWithVirtualText: false,
	showInlayHints: false,
	showSignature: true,
	snippetSupport: true,
	ultisnipsSupport: true,
	useBufferCompletion: false,
	usePopupInCodeAction: false,
	useQuickfixForLocations: false,
	vsnipSupport: true,
	bufferCompletionTimeout: 100,
	customCompletionKinds: false,
	completionKinds: {},
	filterCompletionDuplicates: false,
}
autocmd User LspSetup call LspOptionsSet(lspOpts)
autocmd User LspSetup call LspAddServer(lspServers)
noremap <leader>cr <cmd>LspRename<cr>
noremap <leader>cR <cmd>ALEFileRename<cr>
noremap gr <cmd>LspPeekReferences<cr>
noremap gd <cmd>LspGotoDefinition<cr>
noremap gD <cmd>LspGotoDeclaration<cr>
noremap gI <cmd>LspGotoImpl<cr>
noremap gy <cmd>LspGotoTypeDef<cr>
noremap K <cmd>LspHover<cr>
au Filetype vim noremap <buffer>K K
noremap gK <cmd>LspSymbolSearch<cr>
noremap <leader>ca <cmd>LspCodeAction<cr>
noremap <leader>cA <cmd>LspCodeLens<cr>
noremap ]d <Plug>(ale_previous_wrap)
noremap [d <Plug>(ale_next_wrap)
#  g:ale_sign_column_always = 1
g:ale_sign_error = "\ue009"
g:ale_echo_msg_format = '[%linter%] %code: %%s'
g:ale_lsp_suggestions = 1
g:ale_detail_to_floating_preview = 1
g:ale_hover_to_preview = 1
g:ale_floating_preview = 1
g:ale_lint_on_text_changed = "normal"
g:ale_lint_on_insert_leave = 1

#  asynctasks [[[
g:asynctasks_term_pos = 'vim' # quickfix | vim | tab | bottom | external
g:asyncrun_open = 6
noremap <silent><f7> <cmd>AsyncTask file-run<cr>
noremap <silent><f8> <cmd>AsyncTask file-build<cr>
noremap <silent><f9> <cmd>AsyncTask project-run<cr>
noremap <silent><f10> <cmd>AsyncTask project-build<cr>
noremap <silent><leader>o <cmd>Leaderf --nowrap task<cr>
#  ]]]

#  plugins misc keymaps [[[
nnoremap <silent><leader>cs <cmd>Vista!!<cr>
noremap <leader>T :Tabularize /
xnoremap <leader>T :Tabularize /
noremap <leader>cf <cmd>Autoformat<cr>
noremap <leader>u <cmd>UndotreeToggle<cr>
#  ]]]


g:autoformat_autoindent = 0
g:autoformat_retab = 0
g:autoformat_remove_trailing_spaces = 0

g:formatdef_clangformat = "'clang-format -lines='.a:firstline.':'.a:lastline.' --assume-filename=\"'.expand('%:p').'\" --style=D:/Competitive-Programming/.clang-format'" 
g:python3_host_prog = 'python'

# vim:fdm=marker:fmr=[[[,]]]:ft=vim

