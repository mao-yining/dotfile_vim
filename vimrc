vim9script

g:mapleader = " "
g:maplocalleader = ";"

# options {{{
filetype plugin indent on
syntax enable
set nocompatible
set t_Co=256
set termguicolors

set hidden confirm
set belloff=all shortmess+=cC
set nolangremap

set spelllang=en_gb,cjk
set langmenu=zh_CN.UTF-8
set helplang=cn
set termencoding=utf-8
set encoding=utf-8

set history=10000
set display=lastline smoothscroll
set scrolloff=5
set colorcolumn=81
set conceallevel=2

set formatoptions+=mMjn
set laststatus=2
set noshowmode
set matchpairs+=<:>
set showmatch

set splitbelow splitright
set autoindent smartindent smarttab

set foldopen+=jump,insert
set jumpoptions=stack

set grepprg=rg\ --vimgrep\ --smart-case\ \"$*\"
set grepformat=%f:%l:%c:%m
set ruler

set ttimeout ttimeoutlen=50
set updatetime=400
set tags=./tags;,tags
set tabpagemax=50

set undofile nobackup nowritebackup
set autowrite autoread

set hlsearch incsearch ignorecase smartcase
set number relativenumber cursorline cursorlineopt=number signcolumn=number
set breakindent linebreak nojoinspaces
set list listchars=tab:›\ ,nbsp:␣,trail:·,extends:…,precedes:…
set fillchars=vert:│,fold:·,foldsep:│
set virtualedit=block
set nostartofline
set switchbuf=uselast
set fileformat=unix fileformats=unix,dos
set sidescroll=1 sidescrolloff=3
set nrformats=bin,hex,unsigned
set sessionoptions=buffers,options,curdir,help,tabpages,winsize,slash,terminal,unix
set diffopt+=algorithm:histogram,linematch:60,inline:word
set completeopt=menuone,popup,fuzzy
set complete=o^10,Fvsnip#completefunc^9,.^8,b^6,w^5,t^3,u^2
set completefuzzycollect=keyword
set autocomplete
set mouse=a
set mousemodel=extend

set wildmenu wildoptions=pum,tagfile wildcharm=<Tab>
set wildignore+=*.o,*.obj,*.bak,*.exe,*.swp,tags,*.cmx,*.cmi
set wildignore+=*~,*.py[co],__pycache__
set wildignore+=*.obsidian,*.svg
set wildignorecase
set viewoptions=cursor,folds,curdir,slash,unix

set clipboard^=unnamed

if has("sodium") && has("patch-9.0.1481")
	set cryptmethod=xchacha20v2
else
	set cryptmethod=blowfish2
endif

if !empty($SUDO_USER) && $USER !=# $SUDO_USER
	setglobal viminfo=
	setglobal directory-=~/tmp
	setglobal backupdir-=~/tmp
elseif exists("+undodir") && !has("nvim-0.5")
	if !empty($XDG_DATA_HOME)
		$DATA_HOME = substitute($XDG_DATA_HOME, "/$", "", "") . "/vim/"
	elseif has("win32")
		$DATA_HOME = expand("~/AppData/Local/vim/")
	else
		$DATA_HOME = expand("~/.local/share/vim/")
	endif
	&undodir   = $DATA_HOME .. "undo/"
	&directory = $DATA_HOME .. "swap/"
	&backupdir = $DATA_HOME .. "backup/"
	if !isdirectory(&undodir)   | mkdir(&undodir, "p")   | endif
	if !isdirectory(&directory) | mkdir(&directory, "p") | endif
	if !isdirectory(&backupdir) | mkdir(&backupdir, "p") | endif
endif
# }}}

# keymaps {{{

# move lines
xnoremap <M-j> :sil! m '>+1<CR>gv
xnoremap <M-k> :sil! m '<-2<CR>gv

nnoremap <expr> k v:count == 0 ? "gk" : "k"
nnoremap <expr> j v:count == 0 ? "gj" : "j"
xnoremap <expr> k v:count == 0 ? "gk" : "k"
xnoremap <expr> j v:count == 0 ? "gj" : "j"
nnoremap <silent><expr> <CR> &buftype ==# "quickfix" ? "\r" : ":\025confirm " .. (&buftype !=# "terminal" ? (v:count ? "write" : "update") : &modified <Bar><Bar> exists("*jobwait") && jobwait([&channel], 0)[0] == -1 ? "normal! i" : "bdelete!") .. "\r"

# buffer delete {{{
nmap =b <Cmd>enew<CR>
nmap \b <ScriptCmd>CloseBuf()<CR>
def CloseBuf()
	if &bt != null_string || &ft == "netrw"|bd|return|endif
	var buf_now = bufnr()
	var buf_jump_list = getjumplist()[0]
	var buf_jump_now = getjumplist()[1] - 1
	while buf_jump_now >= 0
		var last_nr = buf_jump_list[buf_jump_now]["bufnr"]
		var last_line = buf_jump_list[buf_jump_now]["lnum"]
		if buf_now != last_nr && bufloaded(last_nr) && getbufvar(last_nr, "&bt") == null_string
			execute ":buffer " .. last_nr
			execute ":bd " .. buf_now
			return
		else
			buf_jump_now -= 1
		endif
	endwhile
	bp|while &bt != null_string|bp|endwhile
	execute "bd " .. buf_now
enddef
# }}}

# source vimscript (operator)
def SourceVim(...args: list<any>): string
	if len(args) == 0
		&opfunc = matchstr(expand('<stack>'), '[^. ]*\ze[')
		return 'g@'
	endif
	if getline(nextnonblank(1) ?? 1) =~ '^\s*vim9script\s*$'
		vim9cmd :'[,']source
	else
		:'[,']source
	endif
	return ''
enddef
nnoremap <silent> <expr> <space>S SourceVim()
xnoremap <silent> <expr> <space>S SourceVim()

# change window width
map <C-Up> <C-W>+
map <C-Down> <C-W>-
map <C-Left> <C-W><
map <C-Right> <C-W>>

# change window in normal
nmap <Leader>w <C-w>
map  <M-S-K> <C-w>k
map  <M-S-J> <C-w>j
map  <M-S-H> <C-w>h
map  <M-S-L> <C-w>l
tmap <M-S-H> <C-_>h
tmap <M-S-L> <C-_>l
tmap <M-S-J> <C-_>j
tmap <M-S-K> <C-_>k

tnoremap <C-\> <C-\><C-N>

nmap L gt
nmap H gT
nmap =<Tab> <Cmd>tabnew<CR>

for i in range(10)
	execute($"map <M-{i}> <Cmd> tabn {i == 0 ? 10 : i}<CR>")
endfor

def Tab_MoveLeft()
	var tabnr = tabpagenr() - 2
	if tabnr >= 0
		exec 'tabmove ' .. tabnr
	endif
enddef
def Tab_MoveRight()
	var tabnr = tabpagenr() + 1
	if tabnr <= tabpagenr('$')
		exec 'tabmove ' .. tabnr
	endif
enddef
map <M-Left> <ScriptCmd>Tab_MoveLeft()<CR>
map <M-Right> <ScriptCmd>Tab_MoveRight()<CR>

# select search / substitute
xmap g/ "sy/<C-R>s
xmap gs "sy:%s/<C-R>s/

omap A <Cmd>normal! ggVG<CR>
xmap A :<C-U>normal! ggVG<CR>
# visual-block
autocmd ModeChanged *:[\x16] xunmap A
autocmd ModeChanged [\x16]:* xmap A :<C-U>normal! ggVG<CR>

# sudo to write file
cab w!! w !sudo tee % >/dev/null

# quick to change dir
cab cdn cd <C-R>=expand("%:p:h")<CR>
cab cdr cd <C-R>=FindRoot()<CR>
def g:FindRoot(): string
	var gitdir = finddir(".git", getcwd() .. ";")
	if !empty(gitdir)
		if gitdir == ".git"
			gitdir = getcwd()
		else
			gitdir = strpart(gitdir, 0, strridx(gitdir, "/"))
		endif
		return gitdir
	endif
	return null_string
enddef

nmap U <C-R>
nmap Y y$
map Q @@
sunmap Q
nmap gf gF
nnoremap & :&&<CR>
xnoremap & :&&<CR>

cnoremap <C-A> <Home>
cnoremap <C-B> <Left>
cnoremap <C-D> <Del>
cnoremap <C-E> <End>
cnoremap <C-F> <Right>
cnoremap <C-N> <Down>
cnoremap <C-P> <Up>
cnoremap <C-S-B> <S-Left>
cnoremap <C-S-F> <S-Right>
cnoremap <expr> %% getcmdtype( ) == ':' ? expand('%:h') .. '/' : '%%'

inoremap <CR> <C-G>u<CR>
inoremap <C-U> <C-G>u<C-U>
command DiffOrig {
	vert new
	set bt=nofile
	r ++edit %%
	:0delete
	diffthis
	wincmd p
	diffthis
}
# }}}

# autocmds {{{
augroup CustomAutocmds
	autocmd!
	autocmd BufReadPost * {
		var line = line("'\"")
		if line >= 1 && line <= line("$") && &filetype !~# 'commit'
				&& index(['xxd', 'gitrebase', 'tutor'], &filetype) == -1
				&& !&diff
			execute "normal! g`\""
		endif
	}

	autocmd TermResponse * {
		if v:termresponse == "\e[>0;136;0c"
			set bg=dark
		endif
	}

	# vim -b : 用 xxd-格式编辑二进制文件！
	autocmd BufReadPre  *.bin,*.exe,*.dll set binary
	autocmd BufReadPost *bin,*exe,*dll {
		if &binary
			silent :%!xxd -c 32
			set filetype=xxd
			redraw
		endif
	}
	autocmd BufWritePre *bin,*exe,*dll {
		if &binary
			b:view = winsaveview()
			silent :%!xxd -r -c 32
		endif
	}
	autocmd BufWritePost *bin,*exe,*dll {
		if &binary
			undojoin
			silent :%!xxd -c 32
			set nomodified
			winrestview(b:view)
			redraw
		endif
	}

	# 自动去除尾随空格
	autocmd BufWritePre *.py :%s/[ \t\r]\+$//e

	# 软换行
	autocmd FileType tex,markdown,text set wrap

	# 设置 q 来退出窗口
	autocmd FileType startuptime,fugitive,qf,help,git,fugitiveblame,gitcommit map <buffer>q <Cmd>q<CR>

	# 在 gitcommit 中自动进入插入模式
	# autocmd FileType gitcommit :1 | startinsert

	# QuickFixCmdPost
	autocmd QuickFixCmdPost * cwindow

	def QfMakeConv()
		var qflist = getqflist()
		for i in qflist
			i.text = iconv(i.text, "cp936", "utf-8")
		endfor
		setqflist(qflist)
	enddef

	autocmd QuickfixCmdPost make QfMakeConv()

	autocmd User TermdebugStartPost {
		nmap <nowait> <LocalLeader>g <Cmd>Gdb<CR>
		nmap <nowait> <LocalLeader>p <Cmd>Program<CR>
		nmap <nowait> <LocalLeader>s <Cmd>Source<CR>
		nmap <nowait> <LocalLeader>a <Cmd>Asm<CR>
		nmap <nowait> <LocalLeader>v <Cmd>Var<CR>
		nmap <nowait> <F3> <Cmd>ToggleBreak<CR>
		nmap <nowait> <F5> <Cmd>RunOrContinue<CR>
		nmap <nowait> <LocalLeader><F5> <Cmd>Stop<CR>
		nmap <nowait> <Leader><F5> <Cmd>Run<CR>
		nmap <nowait> <F6> <Cmd>Step<CR>
		nmap <nowait> <F7> <Cmd>Over<CR>
		nmap <nowait> <F8> <Cmd>Finish<CR>
	}
	autocmd User TermdebugStopPost {
		nunmap <LocalLeader>g
		nunmap <LocalLeader>p
		nunmap <LocalLeader>s
		nunmap <LocalLeader>a
		nunmap <LocalLeader>v
		map    <F3> <Plug>VimspectorToggleBreakpoint
		nmap   <F5> <Plug>VimspectorContinue
		nunmap <LocalLeader><F5>
		nunmap <Leader><F5>
		nunmap <F6>
		nmap   <F7> <Cmd>AsyncTask file-run<CR>
		nmap   <F8> <Cmd>AsyncTask file-build<CR>
	}

	# 在某些窗口中关闭 list 模式
	autocmd FileType GV,git setlocal nolist
augroup END
# }}}

# packs {{{
packadd! cfilter
packadd! comment
packadd! editexisting
packadd! editorconfig
packadd! helptoc
packadd! hlyank
packadd! matchit
packadd! nohlsearch

nmap <Leader>t <Cmd>HelpToc<CR>
tmap <C-t><C-t> <Cmd>HelpToc<CR>
g:popup_borderchars = ['─', '│', '─', '│', '╭', '╮', '╯', '╰']
g:popup_borderchars_t = ['─', '│', '─', '│', '├', '┤', '╯', '╰']
g:hlyank_duration = 200

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
autocmd user startified setlocal cursorline
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
g:startify_lists = [
	{ type: "sessions",  header: ["   Sessions"]  },
	{ type: "files",     header: ["   MRU"]       },
	{ type: "bookmarks", header: ["   Bookmarks"] },
	{ type: "commands",  header: ["   Commands"]  },
]
g:startify_session_dir = $MYVIMDIR .. "/sessions"
g:startify_skiplist = [ "runtime/doc/", "/plugged/.*/doc/", "/.git/" ]
g:startify_skiplist += [ "/Temp/", "fugitiveblame$" ]
g:startify_bookmarks = [ { "c": $MYVIMRC } ]
g:startify_bookmarks += [ { "b": "~/Documents/vault/projects/accounts/main.bean" } ]
g:startify_custom_footer = ["", "   Vim is charityware. Please read \":help uganda\".", ""]

Pack "Bakudankun/qline.vim"
Pack "vim-airline/vim-airline"
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
Pack "skywind3000/vim-terminal-help"
g:terminal_list = 0
if has("win32")
	g:terminal_shell = "nu"
endif

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
# ‘vim' 时无法运行路径中有空格的情况
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
nmap <LocalLeader>f <Cmd>Neoformat<CR>
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
endif
nmap <Leader>gg <Cmd>Git<CR>
nmap <Leader>gl <Cmd>GV<CR>
nmap <Leader>gcc <Cmd>Git commit -s -v<CR>
nmap <Leader>gca <Cmd>Git commit --amend -v<CR>
nmap <Leader>gce <Cmd>Git commit --amend --no-edit -v<CR>
nmap <Leader>gb <Cmd>Git branch<CR>
nmap <Leader>gs :Git switch<Space>
nmap <Leader>gS :Git stash<Space>
nmap <Leader>gco :Git checkout<Space>
nmap <Leader>gcp :Git cherry-pick<Space>
nmap <Leader>gM :Git merge<Space>
nmap <Leader>gcb <Cmd>Git branch<CR>
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
g:qf_mapping_ack_style = 1
Pack "mao-yining/vim-log-highlighting", { type: "opt" }
au! BufNewFile,BufRead *.log	setfiletype log
Pack "ubaldot/vim-conda-activate", { on: "CondaActivate" }
Pack "bfrg/vim-cmake-help", { for: "cmake" }
Pack "lervag/vimtex"
au FileType tex,latex,context setlocal keywordprg=:VimtexDocPackage*
g:vimtex_quickfix_autoclose_after_keystrokes = 2
g:vimtex_quickfix_open_on_warning = 0
g:vimtex_format_enabled = 1
g:vimtex_fold_enabled = 1
g:vimtex_fold_manual = 1
g:tex_comment_nospell = 1
g:matchup_override_vimtex = 1
g:vimtex_view_skim_reading_bar = 1
g:vimtex_complete_enabled = 1
g:vimtex_quickfix_mode = 0
g:vimtex_compiler_latexmk = {
	aux_dir: "",
	out_dir: "",
	callback: 1,
	continuous: 1,
	executable: "latexmk",
	hooks: [],
	options: [
		"-verbose",
		"-file-line-error",
		"-shell-escape",
		"-synctex=1",
		"-interaction=nonstopmode",
	],
}
Pack "junegunn/vim-easy-align", { on: "<Plug>(EasyAlign)" }
xmap <LocalLeader><Tab> <Plug>(EasyAlign)
nmap <LocalLeader><Tab> <Plug>(EasyAlign)
Pack "ferrine/md-img-paste.vim", { for: "markdown" }
Pack "nathangrigg/vim-beancount", { type: "opt" }
au FileType beancount ++once packadd vim-beancount | e
Pack "normen/vim-pio", { on: "PIO" }
Pack "tpope/vim-scriptease", { on: "PP" }
Pack "mhinz/vim-lookup", { for: "vim" }
Pack "chrisbra/csv.vim", { for: "csv" }
autocmd FileType vim nmap <buffer> <C-]>  <Cmd>call lookup#lookup()<CR>
autocmd FileType vim nmap <buffer> <C-t>  <Cmd>call lookup#pop()<CR>
g:filetype_md = "markdown"
g:pandoc#syntax#codeblocks#ignore = ["definition", "markdown", "md"]
g:pandoc#syntax#codeblocks#embeds#langs = [
	"bash=sh", "shell=sh", "sh",
	"asm", "c", "cpp",
	"rust", "go",
	"javascript",
	"yaml", "json", "jsonc", "toml",
	"python", "perl", "vim", "ruby", "lua",
	"tex", "tikz=tex", "typst",
	"git", "gitcommit", "gitrebase", "diff",
	"messages", "log",
	"mermaid",
]
Pack "tpope/vim-dadbod", { on: "DB" }
Pack "kristijanhusak/vim-dadbod-ui", { on: [ "DBUI", "DBUIToggle" ] }
# }}}

# vimspector {{{
Pack "puremourning/vimspector", { type: "opt" }
g:vimspector_install_gadgets = [ "debugpy", "vscode-cpptools", "CodeLLDB" ]
nmap <F5>          <Plug>VimspectorContinue
nmap <F3>          <Plug>VimspectorToggleBreakpoint
nmap <Leader><F3>  <Plug>VimspectorRunToCursor
nmap <F4>          <Plug>VimspectorAddFunctionBreakpoint
nmap <Leader><F4>  <Plug>VimspectorToggleConditionalBreakpoint
g:vimspector_enable_winbar = 0
autocmd User VimspectorDebugEnded {
	if exists("<Leader><F5>")|nunmap <Leader><F5>|endif
	if exists("<F6>")|nunmap <F6>|endif
	nmap <F7> <Cmd>AsyncTask file-run<CR>
	nmap <F8> <Cmd>AsyncTask file-build<CR>
	nmap <F9> <Cmd>AsyncTask project-run<CR>
	nmap <F10> <Cmd>AsyncTask project-build<CR>
	if exists("<Leader><F11>")|nunmap <Leader><F11>|endif
	if exists("<Leader><F12>")|nunmap <Leader><F12>|endif
	if exists("<Leader>B")|nunmap <Leader>B|endif
	if exists("<Leader>D")|nunmap <Leader>D|endif
}
autocmd User VimspectorUICreated {
	nmap <Leader><F5>  <Plug>VimspectorStop
	nmap <F6>          <Plug>VimspectorStepOver
	nmap <F7>          <Plug>VimspectorStepInto
	nmap <F8>          <Plug>VimspectorStepOut
	nmap <F9>          <Plug>VimspectorPause
	nmap <F10>         <Plug>VimspectorRestart
	nmap <Leader><F11> <Plug>VimspectorUpFrame
	nmap <Leader><F12> <Plug>VimspectorDownFrame
	nmap <Leader>B     <Plug>VimspectorBreakpoints
	nmap <Leader>D     <Plug>VimspectorDisassemble
}
# }}}

# ALE {{{
Pack "dense-analysis/ale", { type: "opt" }

g:ale_sign_column_always = true
g:ale_disable_lsp        = true
g:ale_echo_msg_format    = "[%linter%] %s [%severity%]"
g:ale_virtualtext_cursor = 0
g:ale_virtualtext_prefix = ""
g:ale_sign_error         = "E>"
g:ale_sign_warning       = "W>"
g:ale_sign_info          = "I>"
nmap <LocalLeader>d <Plug>(ale_detail)
nmap <silent> [d <Plug>(ale_previous)
nmap <silent> ]d <Plug>(ale_next)
g:ale_c_cppcheck_options = "--enable=style --check-level=exhaustive"
g:ale_cpp_cppcheck_options = "--enable=style --check-level=exhaustive"
g:ale_linters = {
	c: ["cc", "clangtidy", "cppcheck", "cpplint"],
	cpp: ["cc", "clangtidy", "cppcheck", "cpplint"],
	tex: ["chktex"],
}
# }}}

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

# # vim9lsp {{{
Pack 'yegappan/lsp', { type: "opt" }
Pack 'hrsh7th/vim-vsnip', { type: "opt" }
Pack 'hrsh7th/vim-vsnip-integ', { type: "opt" }
Pack 'rafamadriz/friendly-snippets', { type: "opt" }
packadd! lsp
packadd! vim-vsnip
packadd! vim-vsnip-integ
packadd! friendly-snippets
Pack 'girishji/scope.vim', { on: 'Scope', type: "opt" } # {{{
nmap <Leader>b <Cmd>Scope Buffer<CR>
nmap <Leader>; <Cmd>Scope commands<CR>
nmap <Leader><Space> <Cmd>Scope File<CR>
nmap <Leader>f <Cmd>Scope Grep<CR>
nmap <Leader>h <Cmd>Scope Help<CR>
nmap <Leader>r <Cmd>Scope MRU<CR>
nmap <Leader>s <Cmd>Scope LspDocumentSymbol<CR>

# }}}


var lspOpts = { # {{{
	aleSupport: false,
	autoComplete: false, # Use OmniComplete
	completionMatcher: 'case',
	diagVirtualTextAlign: 'after',
	ignoreMissingServer: false,
	popupBorder: true,
	semanticHighlight: true,
	showDiagWithVirtualText: false,
	useQuickfixForLocations: true, # For LspShowReferences
}
autocmd User LspSetup g:LspOptionsSet(lspOpts)
# }}}

var lspServers = [
	{ filetype: ["c", "cpp"], path: "clangd", args: ['--background-index', '--clang-tidy'] },
	{ filetype: "python", path: "pyright-langserver.cmd", args: ["--stdio"], workspaceConfig: { python: { pythonPath: "python" } } },
	{ filetype: "rust", path: "rust-analyzer" },
	{ filetype: ["tex", "bib"], path: "texlab"},
	{ filetype: "vim", path: "vim-language-server.cmd", args: ["--stdio"] },
	{ filetype: "rust", path: "rust-analyzer", syncInit: true },
	{ filetype: ["markdown", "pandoc"], path: "marksman", args: ["server"], syncInit: true },
	# { filetype: ['markdown', 'pandoc'], path: 'vscode-markdown-language-server.cmd', args: ['--stdio'] }
]
autocmd User LspSetup g:LspAddServer(lspServers)
nmap gD <Cmd>LspGotoDeclaration<CR>
nmap gd <Cmd>LspGotoDefinition<CR>
nmap gy <Cmd>LspGotoTypeDef<CR>
nmap gi <Cmd>LspGotoImpl<CR>
nmap gr <Cmd>LspPeekReferences<CR>
nmap gR <Cmd>LspShowReferences<CR>
nmap gs <Cmd>LspSubTypeHierarchy<CR>
nmap gS <Cmd>LspSuperTypeHierarchy<CR>
nmap yoI <Cmd>LspInlayHints toggle<CR>
nmap [oI <Cmd>LspInlayHints enable<CR>
nmap ]oI <Cmd>LspInlayHints disable<CR>
noremap <Leader>ca <Cmd>LspCodeAction<CR>
noremap <Leader>cl <Cmd>LspCodeLens<CR>
xnoremap <LocalLeader>e <Cmd>LspSelectionExpand<CR>
xnoremap <LocalLeader>s <Cmd>LspSelectionShrink<CR>
map <F2> <Cmd>LspRename<CR>
set keywordprg=:LspHover
au FileType vim,help,colortemplate setlocal keywordprg=:help

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
