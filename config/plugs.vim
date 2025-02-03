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
Plug 'kana/vim-textobj-function'
Plug 'sgur/vim-textobj-parameter'
Plug 'skywind3000/vim-terminal-help'
Plug 'andymass/vim-matchup'
Plug 'liuchengxu/vim-which-key', { 'on': ['WhichKey', 'WhichKey!'] }
Plug 'tpope/vim-obsession'
Plug 'dhruvasagar/vim-prosession'
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
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'laixintao/asyncomplete-gitcommit'
Plug 'prabirshrestha/asyncomplete-file.vim'
Plug 'prabirshrestha/asyncomplete-ultisnips.vim'
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'prabirshrestha/asyncomplete-necovim.vim'
Plug 'Shougo/neco-vim'
Plug 'prabirshrestha/asyncomplete-tags.vim'
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
# Plug 'Yggdroot/LeaderF', { 'do': ':LeaderfInstallCExtension', 'on': 'Leaderf' }
Plug 'vim-utils/vim-man', { 'on': ['Man', 'Mangrep']}
Plug 'jamessan/vim-gnupg'
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
Plug 'kh3phr3n/python-syntax', {'for': 'py'}
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
Plug 'Donaldttt/fuzzyy'
Plug 'girishji/devdocs.vim'

# Plug 'ZSaberLv0/ZFVimIM'
# Plug 'ZSaberLv0/ZFVimJob' # 可选, 用于提升词库加载性能
# Plug 'ZSaberLv0/ZFVimGitUtil' # 可选, 如果你希望定期自动清理词库 push 历史
# copilot
# Plug 'github/copilot.vim', {'on': 'Copilot'}
# Plug 'exafunction/codeium.vim', {'on': 'Codeium'}
# vim-ai
# Plug 'chenxuan520/vim-ai-doubao', {'on': ['AIChat', 'AI', 'AIEdit', 'AIConfigEdit']}
call plug#end()

g:prosession_dir = expandcmd('~/.cache/sessions/')
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

#  fuzzy [[[
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
#  ]]]

#  Git [[[
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
noremap ]d <Plug>(ale_previous_wrap)
noremap [d <Plug>(ale_next_wrap)
noremap <leader>cr <cmd>ALERename<cr>
noremap <leader>cR <cmd>ALEFileRename<cr>
noremap gr <cmd>ALEFindReferences<cr>
noremap gd <cmd>ALEGoToDefinition<cr>
noremap gI <cmd>ALEGoToImplementation<cr>
noremap gy <cmd>ALEGoToTypeDefinition<cr>
noremap K <cmd>ALEHover<cr>
au Filetype vim noremap <buffer>K K
noremap gK <cmd>ALESymbolSearch<cr>
noremap <leader>ca <cmd>ALECodeAction<cr>
#  g:ale_sign_column_always = 1
g:ale_lsp_suggestions = 1
g:ale_detail_to_floating_preview = 1
g:ale_hover_to_preview = 1
g:ale_floating_preview = 1
g:ale_lint_on_text_changed = "normal"
g:ale_lint_on_insert_leave = 1
g:ale_completion_symbols = {
			\ 'text': '󰉿',
			\ 'method': '󰆧',
			\ 'function': '󰊕',
			\ 'constructor': '',
			\ 'field': '󰜢',
			\ 'variable': '󰀫',
			\ 'class': '󰠱',
			\ 'interface': '',
			\ 'module': '',
			\ 'property': '󰜢',
			\ 'unit': '󰑭',
			\ 'value': '󰎠',
			\ 'enum': '',
			\ 'keyword': '󰌋',
			\ 'snippet': '',
			\ 'color': '󰏘',
			\ 'file': '󰈙',
			\ 'reference': '󰈇',
			\ 'folder': '󰈇',
			\ 'enum_member': '',
			\ 'constant': '󰏿',
			\ 'struct': '󰙅',
			\ 'event': '',
			\ 'operator': '󰆕',
			\ 'type_parameter': 'p',
			\ '<default>': 'v'
			\ }
#  ]]]

#  complete [[[
#  au User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#emoji#get_source_options({
#			\ 'name': 'emoji',
#			\ 'allowlist': ['*'],
#			\ 'completor': function('asyncomplete#sources#emoji#completor'),
#			\ }))
call asyncomplete#register_source(asyncomplete#sources#ultisnips#get_source_options({
			\ 'name': 'ultisnips',
			\ 'allowlist': ['*'],
			\ 'priority': 20,
			\ 'completor': function('asyncomplete#sources#ultisnips#completor'),
			\ }))
#  inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
#  inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <cr>    pumvisible() ? asyncomplete#close_popup() : "\<cr>"
au User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#file#get_source_options({
			\ 'name': 'file',
			\ 'allowlist': ['*'],
			\ 'priority': 10,
			\ 'completor': function('asyncomplete#sources#file#completor')
			\ }))
au User asyncomplete_setup call asyncomplete#register_source({
			\ 'name': 'gitcommit',
			\ 'whitelist': ['gitcommit'],
			\ 'priority': 10,
			\ 'completor': function('asyncomplete#sources#gitcommit#completor')
			\ })
au User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#necovim#get_source_options({
			\ 'name': 'necovim',
			\ 'allowlist': ['vim'],
			\ 'completor': function('asyncomplete#sources#necovim#completor'),
			\ }))
au User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#tags#get_source_options({
			\ 'name': 'tags',
			\ 'allowlist': ['c'],
			\ 'completor': function('asyncomplete#sources#tags#completor'),
			\ 'config': {
			\    'max_file_size': 50000000,
			\  },
			\ }))
au User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#ale#get_source_options({
			\ 'priority': 10,
			\ }))
#  ]]]

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

