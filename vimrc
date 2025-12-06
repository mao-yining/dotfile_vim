vim9script
# options {{{
g:mapleader = " "
g:maplocalleader = ";"

filetype plugin indent on
syntax enable
set nocompatible
set t_Co=256
set termguicolors

set hidden confirm
set belloff=all shortmess+=cC
set nolangremap

set helplang=cn spelllang=en_gb,cjk

set history=10000 updatetime=400 tabpagemax=50 termwinscroll=40000
set display=lastline smoothscroll
set scrolloff=5
set colorcolumn=81
set conceallevel=2

set formatoptions+=mMjn
# set laststatus=2
set noshowmode
set matchpairs+=<:>
set showmatch
set ruler
set splitbelow splitright
set autoindent smartindent smarttab
set foldopen+=jump,insert
set jumpoptions=stack
set ttimeout ttimeoutlen=50
set autowrite autoread
set hlsearch incsearch ignorecase smartcase
set number relativenumber cursorline cursorlineopt=number signcolumn=number
set breakindent linebreak nojoinspaces
set list listchars=tab:›\ ,nbsp:␣,trail:·,extends:…,precedes:…
set fillchars=vert:│,fold:·,foldsep:│
set virtualedit=block
set nostartofline
set switchbuf=uselast
set sidescroll=1 sidescrolloff=3
set nrformats=bin,hex,unsigned
set sessionoptions=buffers,options,curdir,help,tabpages,winsize,slash,terminal
set viewoptions=cursor,folds,curdir,slash
set diffopt+=algorithm:histogram,linematch:60,inline:word
set completeopt=menuone,popup,fuzzy
set completepopup=border:off,shadow:on pumborder=
set autocomplete complete=o^9,.^9,w^5,b^5,t^3,u^2
set complete+=Fvsnip#completefunc^9
set complete+=Fcompletor#Path^10,Fcompletor#Abbrev^3,Fcompletor#Register^3
set mouse=a mousemodel=extend
set clipboard^=unnamed

if has("sodium") && has("patch-9.0.1481")
	set cryptmethod=xchacha20v2
else
	set cryptmethod=blowfish2
endif

# }}}

# packs {{{
plugpac#Begin({
	progress_open: "tab",
	status_open: "vertical",
})

Pack "catppuccin/vim", { name: "catppuccin" }
Pack "k-takata/minpac", { type: "opt" }
Pack "yianwillis/vimcdoc"

# coding {{{
Pack "kshenoy/vim-signature"      # show marks
Pack "wellle/targets.vim"         # text-object
Pack "tpope/vim-repeat"
Pack "tpope/vim-speeddating"
Pack "tpope/vim-unimpaired"
Pack "tpope/vim-characterize"     # "ga" improve
Pack "tpope/vim-surround"
Pack "tpope/vim-sleuth"
Pack "svermeulen/vim-subversive"
nmap s <plug>(SubversiveSubstitute)
nmap ss <plug>(SubversiveSubstituteLine)
nmap S <plug>(SubversiveSubstituteToEndOfLine)
xmap s <plug>(SubversiveSubstitute)
Pack "Andrewradev/switch.vim"
g:switch_mapping = null_string
g:speeddating_no_mappings = 1
nnoremap <Plug>SpeedDatingFallbackUp <C-A>
nnoremap <Plug>SpeedDatingFallbackDown <C-X>
nnoremap <C-A> <Cmd>if !switch#Switch() <Bar> call speeddating#increment(v:count1) <Bar> endif<CR>
nnoremap <C-X> <Cmd>if !switch#Switch({"reverse": 1}) <Bar> call speeddating#increment(-v:count1) <Bar> endif<CR>
Pack "voldikss/vim-browser-search", { on: ["<Plug>SearchNormal", "<Plug>SearchVisual"] }
g:browser_search_default_engine = "bing"
nmap <LocalLeader>S <Plug>SearchNormal
vmap <LocalLeader>S <Plug>SearchVisual
# }}}

# ui {{{
Pack "mhinz/vim-startify"
g:startify_enable_special      = 0
g:startify_relative_path       = 1
g:startify_change_to_dir       = 1
g:startify_update_oldfiles     = 1
g:startify_fortune_use_unicode = 1
g:startify_files_number        = 3
g:startify_session_sort        = 1
g:startify_custom_header       = "startify#pad(startify#fortune#boxed())"
g:startify_session_autoload    = 1
g:startify_session_persistence = 1
g:startify_change_to_vcs_root  = 1
g:startify_session_delete_buffers = 1
g:startify_lists = [
	{ type: "files",     header: ["   MRU"]       },
	{ type: "sessions",  header: ["   Sessions"]  },
	{ type: "bookmarks", header: ["   Bookmarks"] },
	{ type: "commands",  header: ["   Commands"]  },
]
if !isdirectory($MYVIMDIR .. "/sessions")
	mkdir($MYVIMDIR .. "/sessions", "p")
endif
g:startify_session_dir = $MYVIMDIR .. "/sessions"
g:startify_skiplist = [ "runtime/doc/", "/plugged/.*/doc/", "/.git/" ]
g:startify_skiplist += [ "\\Temp\\", "fugitiveblame$", "dir://" ]
g:startify_bookmarks = [ { "c": $MYVIMRC } ]
g:startify_bookmarks += [ { "b": "~/Documents/vault/projects/accounts/main.bean" } ]
g:startify_custom_footer = ["", "   Vim is charityware. Please read \":help uganda\".", ""]

Pack "Bakudankun/qline.vim"
Pack "vim-airline/vim-airline"
g:loaded_qline = 1
g:loaded_airline = 1
g:qline_config = {
	colorscheme: "airline:catppuccin",
	active: {
		left: [
			["mode", "paste"],
			["gitbranch", "gitgutter"],
			["filename"],
		],
		right: [
			["lineinfo"],
			["percent"],
			["filetype", "fileencoding", "fileformat", "tasks"]
		]
	},
	inactive: {
		left: [["filename", "gitbranch", "gitgutter"], ["bufstate"]],
		right: [["filetype"], ["fileinfo"]],
		separator: {left: "", right: "", margin: " "},
		subseparator: {left: "|", right: "|", margin: " "},
	},
	component: {
		tasks: () => g:asyncrun_status
		->matchstr('\(running\|success\|failure\)')
		->substitute("^success$", "%#Added#success%*", "")
		->substitute("^failure$", "%#Removed#failure%*", ""),
		gitbranch: () => fugitive#statusline()->matchstr("(\\zs[^)]*\\ze)"),
		gitgutter: {
		content: () =>
			g:GitGutterGetHunkSummary()
			->mapnew((idx, val) => !val ? null_string : ["+", "~", "-"][idx] .. val)
			->filter((_, val) => !!val)
			->join(),
			visible_condition: () => g:GitGutterGetHunks(),
		},
	},
} # }}}

Pack "lacygoill/vim9asm", { on: "Disassemble" } # vim9 asm plugin

Pack "vim-scripts/DrawIt", { on: "DIstart" }
nmap =d <Cmd>DIstart<CR>
nmap \d <Cmd>DIstop<CR>

g:loaded_netrw       = 1
g:loaded_netrwPlugin = 1
Pack "habamax/vim-dir"
nmap - <Cmd>Dir<CR>

Pack "lilydjwg/colorizer", { on: "ColorHighlight" }
nmap =c <Cmd>ColorHighlight<CR>
nmap \c <Cmd>ColorClear<CR>

Pack "liuchengxu/vista.vim"
g:vista#renderer#enable_icon = false
nmap <LocalLeader>v <Cmd>Vista!!<CR>

Pack "dstein64/vim-startuptime", {on: "StartupTime"}

#  asynctasks {{{
Pack "tpope/vim-dispatch"
Pack "skywind3000/asyncrun.vim"
Pack "skywind3000/asynctasks.vim"
g:asynctasks_term_pos = "tab" # quickfix | vim | tab | bottom | external
g:asyncrun_status = "stopped"
g:asyncrun_open = 6
g:asyncrun_save = true
g:asyncrun_bell = true
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
#  }}}

Pack "sbdchd/neoformat", { on: "Neoformat"} # Neoformat {{{
# nmap <LocalLeader>f <Cmd>Neoformat<CR>
g:neoformat_basic_format_align = 1 # Enable alignment
g:neoformat_basic_format_retab = 1 # Enable tab to spaces conversion
g:neoformat_basic_format_trim = 1  # Enable trimmming of trailing whitespace
g:neoformat_cpp_clangformat = { exe: "clang-format", args: [ expandcmd('-assume-filename="%"') ], stdin: 1 }
g:neoformat_c_clangformat = { exe: "clang-format", args: [ expandcmd('-assume-filename="%"') ], stdin: 1 }
g:neoformat_tex_texfmt = { exe: "tex-fmt", args: [ "--stdin" ], stdin: 1 }
g:neoformat_pandoc_prettier = {
	exe: 'prettier',
	args: ['--stdin-filepath', '"%:p"'],
	stdin: 1,
	try_node_exe: 1,
}
g:neoformat_enabled_tex = [ "texfmt" ]
# }}}

Pack "mbbill/undotree", { on: "UndotreeToggle" } # 撤销树
nmap <Leader>u <Cmd>UndotreeToggle<CR>
g:undotree_SetFocusWhenToggle = true

Pack "girishji/devdocs.vim", { on: [ "DevdocsFind", "DevdocsInstall" ] }
nmap <Leader>D <Cmd>DevdocsFind<CR>

#  Git {{{
Pack "tpope/vim-fugitive", { type: "opt" }
Pack "tpope/vim-rhubarb", { type: "opt" }
Pack "junegunn/gv.vim", { type: "opt" }
Pack "airblade/vim-gitgutter", { type: "opt" }
Pack "rhysd/conflict-marker.vim", { type: "opt" }
if executable("git")
	packadd! vim-fugitive
	packadd! vim-gitgutter
	packadd! conflict-marker.vim
	nmap <Leader>gg <Cmd>Git<CR>
	nmap <Leader>gl <Cmd>GV<CR>
	nmap <Leader>g<Space> :Git<Space>
	nmap <Leader>gc<Space> :Git commit<Space>
	nmap <Leader>gcc <Cmd>Git commit -v<CR>
	nmap <Leader>gcs <Cmd>Git commit -s -v<CR>
	nmap <Leader>gca <Cmd>Git commit --amend -v<CR>
	nmap <Leader>gce <Cmd>Git commit --amend --no-edit -v<CR>
	nmap <Leader>gb <Cmd>Git branch<CR>
	nmap <Leader>gs :Git switch<Space>
	nmap <Leader>gS :Git stash<Space>
	nmap <Leader>gco :Git checkout<Space>
	nmap <Leader>gcp :Git cherry-pick<Space>
	nmap <Leader>gM :Git merge<Space>
	nmap <Leader>gp <Cmd>Git! pull<CR>
	nmap <Leader>gP <Cmd>Git! push<CR>
	nmap <Leader>gm <Cmd>Git mergetool<CR>
	nmap <Leader>gd <Cmd>Git difftool<CR>
	nmap <Leader>gr <Cmd>Gread<CR>
	nmap <Leader>gw <Cmd>Gwrite<CR>
	nmap <Leader>gB <Cmd>GBrowse<CR>
	nmap <LocalLeader>gl <Cmd>GV!<CR>
	nmap <LocalLeader>gd <Cmd>Git diff %<CR>
	nmap <LocalLeader>gD <Cmd>Gdiffsplit<CR>
	nmap <LocalLeader>gb <Cmd>Git blame<CR>
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
endif
#  }}}

# ftplugins {{{
Pack "vim-utils/vim-man", { on: ["Man", "Mangrep"]}
Pack "jamessan/vim-gnupg"
Pack "vimwiki/vimwiki", { for: "vimwiki" }
Pack "romainl/vim-qf"
nmap <Home> <Plug>(qf_qf_previous)
nmap <End>  <Plug>(qf_qf_next)
nmap <C-Home> <Plug>(qf_loc_previous)
nmap <C-End>  <Plug>(qf_loc_next)
nmap <M-s> <Plug>(qf_qf_switch)
nmap <Leader>q <Plug>(qf_qf_toggle)
nmap <Leader>l <Plug>(qf_loc_toggle)
Pack "mao-yining/vim-log-highlighting", { type: "opt" }
au! BufNewFile,BufRead *.log	setfiletype log
Pack "ubaldot/vim-conda-activate", { on: "CondaActivate" }
Pack "bfrg/vim-cmake-help", { for: "cmake" }
Pack "lervag/vimtex", { type: "opt" }
Pack "junegunn/vim-easy-align", { on: "<Plug>(EasyAlign)" }
xmap <LocalLeader><Tab> <Plug>(EasyAlign)
nmap <LocalLeader><Tab> <Plug>(EasyAlign)
Pack "nathangrigg/vim-beancount", { for: "opt" }
au BufNewFile,BufRead *.bean,*.beancount ++once packadd vim-beancount
Pack "normen/vim-pio", { on: "PIO" }
Pack "tpope/vim-scriptease", { on: "PP" }
Pack "chrisbra/csv.vim", { for: "csv" }
Pack "tpope/vim-dadbod", { on: "DB" }
Pack "kristijanhusak/vim-dadbod-ui", { on: [ "DBUI", "DBUIToggle" ] }
# }}}

Pack "puremourning/vimspector", { type: "opt" }

# test {{{
Pack "vim-test/vim-test", { on: [ "TestNearest", "TestFile", "TestSuite" ] }
nmap <silent> <LocalLeader>tt <Cmd>TestNearest<CR>
nmap <silent> <LocalLeader>tf <Cmd>TestFile<CR>
nmap <silent> <LocalLeader>ts <Cmd>TestSuite<CR>
nmap <silent> <LocalLeader>tl <Cmd>TestLast<CR>
nmap <silent> <LocalLeader>tv <Cmd>TestVisit<CR>
g:test#strategy = "vimterminal"
Pack "junegunn/vader.vim", { for: "vader", on: "Vader" }
autocmd BufRead,BufNewFile *.vader setfiletype vader
# }}}

# competitest {{{
Pack "mao-yining/competitest.vim"
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
# }}}

Pack "vim/colorschemes"

# vim9lsp {{{
Pack 'yegappan/lsp', { type: "opt" }
Pack 'hrsh7th/vim-vsnip', { type: "opt" }
Pack 'hrsh7th/vim-vsnip-integ', { type: "opt" }
Pack 'rafamadriz/friendly-snippets', { type: "opt" }
packadd! lsp
packadd! vim-vsnip
packadd! vim-vsnip-integ
packadd! friendly-snippets
Pack 'girishji/scope.vim', { on: 'Scope', type: "opt" } # {{{
nmap <Leader>s <Cmd>Scope LspDocumentSymbol<CR>
# }}}

var lspOpts = { # {{{
	autoComplete: false, # Use OmniComplete
	autoPopulateDiags: true,
	completionMatcher: 'fuzzy',
	diagVirtualTextAlign: 'after',
	filterCompletionDuplicates: true,
	ignoreMissingServer: false,
	popupBorder: true,
	semanticHighlight: true,
	showDiagWithVirtualText: false,
	useQuickfixForLocations: true, # For LspShowReferences
	usePopupInCodeAction: true,
}
autocmd User LspSetup g:LspOptionsSet(lspOpts)
# }}}

var lspServers = [
	{ filetype: ["c", "cpp"], path: "clangd", args: ['--background-index', '--clang-tidy'] },
	{ filetype: ["python"], path: "pyright-langserver.cmd", args: ["--stdio"], workspaceConfig: { python: { pythonPath: "python" } } },
	{ filetype: ["tex", "bib"], path: "texlab"},
	{ filetype: ["rust"], path: "rust-analyzer", syncInit: true },
	{ filetype: ["markdown", "pandoc"], path: "marksman", args: ["server"], syncInit: true },
	# { filetype: ['markdown', 'pandoc'], path: 'vscode-markdown-language-server.cmd', args: ['--stdio'] }
]

autocmd User LspSetup g:LspAddServer(lspServers)

inoremap <expr> <C-l>   vsnip#expandable()  ? "<Plug>(vsnip-expand)"         : "<C-j>"
snoremap <expr> <C-l>   vsnip#expandable()  ? "<Plug>(vsnip-expand)"         : "<C-j>"
inoremap <expr> <C-j>   vsnip#available(1)  ? "<Plug>(vsnip-expand-or-jump)" : "<C-l>"
snoremap <expr> <C-j>   vsnip#available(1)  ? "<Plug>(vsnip-expand-or-jump)" : "<C-l>"
inoremap <expr> <Tab>   vsnip#jumpable(1)   ? "<Plug>(vsnip-jump-next)"      : "<Tab>"
snoremap <expr> <Tab>   vsnip#jumpable(1)   ? "<Plug>(vsnip-jump-next)"      : "<Tab>"
inoremap <expr> <S-Tab> vsnip#jumpable(-1)  ? "<Plug>(vsnip-jump-prev)"      : "<S-Tab>"
snoremap <expr> <S-Tab> vsnip#jumpable(-1)  ? "<Plug>(vsnip-jump-prev)"      : "<S-Tab>"
nmap     <C-S>   <Plug>(vsnip-select-text)
xmap     <C-S>   <Plug>(vsnip-select-text)
nmap     <C-S-S> <Plug>(vsnip-cut-text)
xmap     <C-S-S> <Plug>(vsnip-cut-text)
# }}}

plugpac#End() # }}}

colorscheme catppuccin
# vim:fdm=marker
