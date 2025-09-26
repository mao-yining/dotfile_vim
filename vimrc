vim9script

$v = $HOME .. (has("win32") ? "/vimfiles" : "/.vim")
$VIMRC = $v .. "/vimrc"

g:mapleader = " "               # 定义<Leader>键
g:maplocalleader = ";"          # 定义<LocalLeader>键

# options {{{
filetype plugin indent on
syntax enable
set nocompatible
set t_Co=256                    # 开启256色支持
set termguicolors               # 在终端上使用与 GUI 一致的颜色

set noerrorbells                # 关闭错误提示
set nolangremap
set belloff=all
set novb t_vb=

set spelllang=en,cjk
set langmenu=zh_CN.UTF-8
set helplang=cn
set termencoding=utf-8
set encoding=utf-8

set smoothscroll
set breakindent
set colorcolumn=81
set conceallevel=2

set formatoptions+=mM           # 强制自动换行，应对中文无空格
set formatoptions+=j            # 按 J 时自动删除注释符号
set formatoptions+=n            # 识别编号的列表
set linebreak
set laststatus=2                # 总是显示状态栏
set virtualedit=block,onemore
set noshowmode                  # 设置不打开底部insert
set switchbuf=useopen,usetab
set hidden                      # 设置允许在未保存切换buffer
set nojoinspaces  # suppress inserting two spaces between sentences
set matchpairs+=<:>             # 设置%匹配<>
set showmatch

set autoindent smartindent      # 智能的选择对其方式
set shiftwidth=4
set list
set listchars=tab:>\ ,trail:~,precedes:<,extends:>,nbsp:␣
set fillchars+=eob:\            # 去掉buffer后的‘~’符号
set smarttab                    # 在行和段开始处使用制表符
set splitbelow
set splitright

set foldmethod=marker
set foldopen+=jump
set jumpoptions=stack

set grepprg=rg\ --vimgrep\ --smart-case\ \"$*\"
set grepformat=%f:%l:%c:%m
set cursorline                  # 高亮显示当前行
set number                      # 开启行号显示
set relativenumber              # 展示相对行号

set updatetime=300
set tabpagemax=50

set undofile nobackup nowritebackup
set autowrite autoread

set hlsearch                    # 高亮显示搜索结果
set ignorecase smartcase        # 搜索智能匹配大小写

set shortmess+=c                # 设置补全静默
set complete-=i
set completeopt=fuzzy,menuone,popup
set completepopup=highlight:Pmenu,border:off
set wildmenu wildoptions=pum wildcharm=<Tab>
set wildignore+=*.o,*.obj,*.bak,*.exe,*.swp,tags,*.cmx,*.cmi
set wildignore+=*~,*.py[co],__pycache__
set wildignore+=*.obsidian,*.svg
set wildignorecase
set diffopt+=vertical,indent-heuristic,hiddenoff,algorithm:patience
set diffopt+=inline:word        # word / char  patch 9.1.1243
set sessionoptions=buffers,curdir,folds,help,resize,tabpages,winsize,slash,terminal,unix
set viewoptions=cursor,folds,slash,unix

set clipboard=unnamed

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
	&undodir = $DATA_HOME .. "undo//"
	&directory = $DATA_HOME .. "swap//"
	&backupdir = $DATA_HOME .. "backup//"
	if !isdirectory(&undodir) | mkdir(&undodir, "p") | endif
	if !isdirectory(&directory) | mkdir(&directory, "p") | endif
	if !isdirectory(&backupdir) | mkdir(&backupdir, "p") | endif
endif

if !has("gui_running")
	source $VIMRUNTIME/menu.vim
endif

# }}}

# keymaps {{{
nnoremap <silent><expr> <CR> &buftype ==# "quickfix" ? "\r" : ":\025confirm " .. (&buftype !=# "terminal" ? (v:count ? "write" : "update") : &modified <Bar><Bar> exists("*jobwait") && jobwait([&channel], 0)[0] == -1 ? "normal! i" : "bdelete!") .. "\r"

# buffer delete {{{
nnoremap =b <Cmd>enew<CR>
nnoremap \b <ScriptCmd>CloseBuf()<CR>
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

# reload .vimrc
nnoremap <Leader>S <Cmd>set nossl<CR><Cmd>source $MYVIMRC<CR><Cmd>set ssl<CR>

# change window width
noremap <C-Up> <C-W>+
noremap <C-Down> <C-W>-
noremap <C-Left> <C-W><
noremap <C-Right> <C-W>>

# change window in normal
nmap <Leader>w <C-w>
noremap  <M-S-K> <C-w>k
noremap  <M-S-J> <C-w>j
noremap  <M-S-H> <C-w>h
noremap  <M-S-L> <C-w>l
tnoremap <M-S-H> <C-_>h
tnoremap <M-S-L> <C-_>l
tnoremap <M-S-J> <C-_>j
tnoremap <M-S-K> <C-_>k

tnoremap <C-\> <C-\><C-N>

noremap =q <Cmd>copen<CR>
noremap \q <Cmd>cclose<CR>
noremap =l <Cmd>lopen<CR>
noremap \l <Cmd>lclose<CR>

nnoremap L gt
nnoremap H gT
nnoremap =<Tab> <Cmd>tabnew<CR>

for i in range(10)
	execute($"noremap <M-{i}> <Cmd> tabn {i == 0 ? 10 : i}<CR>")
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
noremap <silent><M-Left> <ScriptCmd>Tab_MoveLeft()<CR>
noremap <silent><M-Right> <ScriptCmd>Tab_MoveRight()<CR>

# select search / substitute
xmap g/ "sy/<C-R>s
xmap gs "sy:%s/<C-R>s/

onoremap A <Cmd>normal! ggVG<CR>
xnoremap A <Cmd>normal! ggVG<CR>
# visual-block
autocmd ModeChanged *:[\x16] xunmap A
autocmd ModeChanged [\x16]:* xnoremap A :<C-U>normal! ggVG<CR>

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

noremap U <C-R>
noremap Y y$
map Q @@
noremap gf gF

cnoremap <C-A> <Home>
cnoremap <C-B> <Left>
cnoremap <C-D> <Del>
cnoremap <C-E> <End>
cnoremap <C-F> <Right>
cnoremap <C-N> <Down>
cnoremap <C-P> <Up>
cnoremap <C-S-B> <S-Left>
cnoremap <C-S-F> <S-Right>

nmap <C-N> <Cmd>cnext<CR>
nmap <C-P> <Cmd>cprev<CR>
# }}}

# autocmds {{{
augroup CustomAutocmds
	autocmd!
	# 回到上次编辑的位置
	au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

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
		ALEDisable
		nnoremap <nowait> <LocalLeader>g <Cmd>Gdb<CR>
		nnoremap <nowait> <LocalLeader>p <Cmd>Program<CR>
		nnoremap <nowait> <LocalLeader>s <Cmd>Source<CR>
		nnoremap <nowait> <LocalLeader>a <Cmd>Asm<CR>
		nnoremap <nowait> <LocalLeader>v <Cmd>Var<CR>
		nnoremap <nowait> <LocalLeader>r <Cmd>Run<CR>
		nnoremap <nowait> <F3> <Cmd>Break<CR>
		nnoremap <nowait> <LocalLeader><F3> <Cmd>TBreak<CR>
		nnoremap <nowait> <F4> <Cmd>Clear<CR>
		nnoremap <nowait> <F5> <Cmd>Continue<CR>
		nnoremap <nowait> <LocalLeader><F5> <Cmd>Stop<CR>
		nnoremap <nowait> <Leader><F5> <Cmd>Run<CR>
		nnoremap <nowait> <F6> <Cmd>Step<CR>
		nnoremap <nowait> <F7> <Cmd>Over<CR>
		nnoremap <nowait> <F8> <Cmd>Finish<CR>
	}
	autocmd User TermdebugStopPost {
		ALEEnable
		nunmap <LocalLeader>g
		nunmap <LocalLeader>p
		nunmap <LocalLeader>s
		nunmap <LocalLeader>a
		nunmap <LocalLeader>v
		nunmap <LocalLeader>r
		nunmap <F3>
		nunmap <LocalLeader><F3>
		nunmap <F4>
		nunmap <F5>
		nunmap <Leader><F5>
		nunmap <LocalLeader><F5>
		nunmap <F6>
		nunmap <F7>
		nunmap <F8>
	}

	# 在某些窗口中关闭 list 模式
	autocmd FileType GV,git setlocal nolist
augroup END
# }}}

# plugs {{{
packadd! comment
packadd! cfilter
packadd! editexisting
packadd! editorconfig
packadd! helptoc
packadd! hlyank
packadd! nohlsearch

plugpac#Begin({
	progress_open: "tab",
	status_open: "vertical",
})

Pack "catppuccin/vim", { name: "catppuccin" }
Pack "k-takata/minpac", { type: "opt" }
Pack "yianwillis/vimcdoc"

# if has("gui_running") && has("win32")
#		# Plug "stillwwater/wincap.vim" # 根据背景颜色修改标题栏
# endif

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
g:speeddating_no_mappings = 1
nnoremap <Plug>SpeedDatingFallbackUp <C-A>
nnoremap <Plug>SpeedDatingFallbackDown <C-X>
nnoremap <silent><C-A> <Cmd>if !switch#Switch() <Bar> call speeddating#increment(v:count1) <Bar> endif<CR>
nnoremap <silent><C-X> <Cmd>if !switch#Switch({"reverse": 1}) <Bar> call speeddating#increment(-v:count1) <Bar> endif<CR>
Pack "voldikss/vim-browser-search", { on: ["<Plug>SearchNormal", "<Plug>SearchVisual"] }
g:browser_search_default_engine = "bing"
nmap <silent> <LocalLeader>S <Plug>SearchNormal
vmap <silent> <LocalLeader>S <Plug>SearchVisual
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
g:startify_lists = [
	{ type: "sessions",  header: ["   Sessions"]  },
	{ type: "files",     header: ["   MRU"]       },
	{ type: "bookmarks", header: ["   Bookmarks"] },
	{ type: "commands",  header: ["   Commands"]  },
]
g:startify_session_sort = 1
g:startify_custom_header = "startify#pad(startify#fortune#boxed())"
g:startify_session_autoload    = 1
g:startify_session_persistence = 1
g:startify_change_to_vcs_root = 1
g:startify_session_dir = $v .. "/sessions"
g:startify_skiplist = [ "runtime/doc/", "/plugged/.*/doc/", "/.git/" ]
g:startify_skiplist += [ "/Temp/", "fugitiveblame$" ]
g:startify_bookmarks = [ { "c": $vimrc } ]
g:startify_bookmarks += [ { "b": "~/Documents/vault/projects/accounts/main.bean" } ]
g:startify_custom_footer = ["", "   Vim is charityware. Please read \":help uganda\".", ""]

Pack "Bakudankun/qline.vim"
Pack "vim-airline/vim-airline"
g:loaded_airline = 1
g:qline_config = {
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
		->substitute("^success$", "%#String#success%*", "")
		->substitute("^failure$", "%#Exception#failure%*", ""),
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
noremap =d <Cmd>DIstart<CR>
noremap \d <Cmd>DIstop<CR>

Pack "habamax/vim-dir", { on: "Dir" }
nnoremap - <Cmd>Dir<CR>

Pack "lilydjwg/colorizer", { on: "ColorHighlight" }
noremap =c <Cmd>ColorHighlight<CR>
noremap \c <Cmd>ColorClear<CR>

Pack "liuchengxu/vista.vim", { on: "Vista" }
g:vista#renderer#enable_icon = false
nnoremap <silent><LocalLeader>v <Cmd>Vista!!<CR>

Pack "dstein64/vim-startuptime", {on: "StartupTime"}

#  asynctasks {{{
Pack "skywind3000/asyncrun.vim"
Pack "skywind3000/asynctasks.vim"
g:asynctasks_term_pos = "external" # quickfix | vim | tab | bottom | external
# ‘vim' 时无法运行路径中有空格的情况
g:asyncrun_save = 1
if has("win32")
	g:asyncrun_encs = "cp936"
endif
noremap <silent><F7> <Esc><Cmd>AsyncTask file-run<CR>
noremap <silent><F8> <Esc><Cmd>AsyncTask file-build<CR>
noremap <silent><F9> <Esc><Cmd>AsyncTask project-run<CR>
noremap <silent><F10> <Esc><Cmd>AsyncTask project-build<CR>
inoremap <silent><F7> <Esc><Cmd>AsyncTask file-run<CR>
inoremap <silent><F8> <Esc><Cmd>AsyncTask file-build<CR>
inoremap <silent><F9> <Esc><Cmd>AsyncTask project-run<CR>
inoremap <silent><F10> <Esc><Cmd>AsyncTask project-build<CR>
#  }}}

Pack "sbdchd/neoformat", { on: "Neoformat"}
noremap <LocalLeader>f <Cmd>Neoformat<CR>
g:neoformat_basic_format_align = 1 # Enable alignment
g:neoformat_basic_format_retab = 1 # Enable tab to spaces conversion
g:neoformat_basic_format_trim = 1  # Enable trimmming of trailing whitespace
g:neoformat_cpp_clangformat = { exe: "clang-format", args: [ expandcmd('-assume-filename="%"') ], stdin: 1 }
g:neoformat_c_clangformat = { exe: "clang-format", args: [ expandcmd('-assume-filename="%"') ], stdin: 1 }
g:neoformat_tex_texfmt = { exe: "tex-fmt", args: [ "--stdin" ], stdin: 1 }
g:neoformat_enabled_tex = [ "texfmt" ]

Pack "mbbill/undotree", { on: "UndotreeToggle" } # 撤销树
nnoremap <Leader>u <Cmd>UndotreeToggle<CR>
g:undotree_SetFocusWhenToggle = true

Pack "girishji/devdocs.vim", { on: [ "DevdocsFind", "DevdocsInstall" ] }
nnoremap <Leader>D <Cmd>DevdocsFind<CR>

#  Git {{{
Pack "tpope/vim-fugitive"
Pack "junegunn/gv.vim", { on: "GV" }
nnoremap <Leader>gg <Cmd>Git<CR>
nnoremap <Leader>gl <Cmd>GV<CR>
nnoremap <Leader>gL <Cmd>GV!<CR>
nnoremap <Leader>gcc <Cmd>Git commit -s -v<CR>
nnoremap <Leader>gca <Cmd>Git commit --amend -v<CR>
nnoremap <Leader>gce <Cmd>Git commit --amend --no-edit -v<CR>
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
Pack "airblade/vim-gitgutter"
nnoremap <LocalLeader>hw <Plug>(GitGutterStageHunk)
nnoremap <LocalLeader>hr <Plug>(GitGutterUndoHunk)
nnoremap <LocalLeader>hp <Plug>(GitGutterPreviewHunk)
onoremap ih <Plug>(GitGutterTextObjectInnerPending)
onoremap ah <Plug>(GitGutterTextObjectOuterPending)
xnoremap ih <Plug>(GitGutterTextObjectInnerVisual)
xnoremap ah <Plug>(GitGutterTextObjectOuterVisual)
nnoremap ]h <Plug>(GitGutterNextHunk)
nnoremap [h <Plug>(GitGutterPrevHunk)
g:gitgutter_map_keys = 0
g:gitgutter_preview_win_floating = 1
Pack "rhysd/conflict-marker.vim"
#  }}}

# ftplugins {{{
Pack "vim-utils/vim-man", { on: ["Man", "Mangrep"]}
Pack "jamessan/vim-gnupg"
Pack "vimwiki/vimwiki", { for: "vimwiki" }
Pack "romainl/vim-qf", { for: "qf" }
Pack "mao-yining/vim-log-highlighting", { for: "log" }
Pack "bfrg/vim-qf-preview", { on: "<plug>(qf-preview-open)" }
autocmd FileType qf nmap <buffer>p <Plug>(qf-preview-open)
Pack "ubaldot/vim-conda-activate", { on: "CondaActivate" }
Pack "bfrg/vim-cmake-help", { for: "cmake" }
Pack "lervag/vimtex", { for: ["tex", "context"], on: "VimtexInverseSearch" }
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
g:tex_flavor = "latex"
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
Pack "nathangrigg/vim-beancount", { for: "beancount" }
Pack "normen/vim-pio"
Pack "tpope/vim-scriptease"
Pack "mhinz/vim-lookup", { for: "vim" }
Pack "chrisbra/csv.vim", { for: "csv" }
autocmd FileType vim nnoremap <buffer> <C-]>  <Cmd>call lookup#lookup()<CR>
autocmd FileType vim nnoremap <buffer> <C-t>  <Cmd>call lookup#pop()<CR>
# g:filetype_md = "pandoc"
g:pandoc#syntax#conceal#use = 1
g:pandoc#syntax#conceal#urls = 1
g:pandoc#syntax#codeblocks#ignore = ["definition", "markdown", "md"]
g:pandoc#syntax#codeblocks#embeds#langs = [
	"bash=sh",
	"shell=sh",
	"sh",
	"asm",
	"c",
	"cpp",
	"rust",
	"go",
	"javascript",
	"yaml",
	"json",
	"jsonc",
	"toml",
	"python",
	"perl",
	"vim",
	"ruby",
	"lua",
	"tex",
	"tikz=tex",
	"typst",
	"git",
	"gitcommit",
	"gitrebase",
	"messages",
	"mermaid",
]
g:markdown_minlines = 500
Pack "tpope/vim-dadbod", { on: "DB"}
Pack "kristijanhusak/vim-dadbod-ui" # Optional
# }}}

# vimspector {{{
Pack "puremourning/vimspector"
g:vimspector_install_gadgets = [ "debugpy", "vscode-cpptools", "CodeLLDB" ]
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
	if exists("<Leader><F5>")|nunmap <Leader><F5>|endif
	if exists("<F6>")|nunmap <F6>|endif
	nnoremap <silent><F7> <Esc><Cmd>AsyncTask file-run<CR>
	nnoremap <silent><F8> <Esc><Cmd>AsyncTask file-build<CR>
	nnoremap <silent><F9> <Esc><Cmd>AsyncTask project-run<CR>
	nnoremap <silent><F10> <Esc><Cmd>AsyncTask project-build<CR>
	if exists("<Leader><F11>")|nunmap <Leader><F11>|endif
	if exists("<Leader><F12>")|nunmap <Leader><F12>|endif
	if exists("<Leader>B")|nunmap <Leader>B|endif
	if exists("<Leader>D")|nunmap <Leader>D|endif
enddef
# }}}

# coc {{{
Pack "Shougo/neco-vim"
Pack "neoclide/coc-neco"
Pack "neoclide/coc.nvim", {"branch": "release"}
Pack "honza/vim-snippets"

# Use tab for trigger completion with characters ahead and navigate
# NOTE: There's always complete item selected by default, you may want to enable
# no select by `"suggest.noselect": true` in your configuration file
# NOTE: Use command ":verbose imap <Tab>" to make sure tab is not mapped by
# other plugin before putting this into your config
inoremap <silent><expr> <Tab>
			\ coc#pum#visible() ? coc#pum#next(1) :
			\ CheckBackspace() ? "\<Tab>" :
			\ coc#refresh()
inoremap <expr><S-Tab> coc#pum#visible() ? coc#pum#prev(1) : "\<C-H>"

# Make <CR> to accept selected completion item or notify coc.nvim to format
# <C-g>u breaks current undo, please make your own choice
# Remove "\<C-R>=coc#on_enter()" as it not used
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
			\ : "\<C-G>u\<CR>"

def CheckBackspace(): bool
	var col = col(".") - 1
	return !col || getline(".")[col - 1] =~# "\\s"
enddef

# Use <C-l> for trigger snippet expand.
imap <C-l> <Plug>(coc-snippets-expand)

# Use <C-j> for select text for visual placeholder of snippet.
vmap <C-j> <Plug>(coc-snippets-select)

# Use <C-j> for jump to next placeholder, it's default of coc.nvim
g:coc_snippet_next = "<C-j>"

# Use <C-k> for jump to previous placeholder, it's default of coc.nvim
g:coc_snippet_prev = "<C-k>"

# Use <Leader>x for convert visual selected code to snippet
xmap <Leader>x  <Plug>(coc-convert-snippet)

# Use <C-space> to trigger completion
if has("nvim")
	inoremap <silent><expr> <C-space> coc#refresh()
else
	inoremap <silent><expr> <C-@> coc#refresh()
endif

# GoTo code navigation
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

# Use K to show documentation in preview window
nnoremap <silent> K <ScriptCmd>ShowDocumentation()<CR>
command! -nargs=0 Hover call CocAction("doHover")
def ShowDocumentation()
	if index(["vim", "help"], &filetype) >= 0
		execute "help " .. expand("<cword>")
	elseif &filetype ==# "tex"
		execute "VimtexDocPackage"
	else
		execute "Hover"
	endif
enddef

# Highlight the symbol and its references when holding the cursor
autocmd CursorHold * silent call CocActionAsync("highlight")

# Symbol renaming
nmap <F2> <Plug>(coc-rename)

augroup mygroup
	autocmd!
	# Setup formatexpr specified filetype(s)
	autocmd FileType typescript,json setl formatexpr=CocAction("formatSelected")
	# Update signature help on jump placeholder
	autocmd User CocJumpPlaceholder call CocActionAsync("showSignatureHelp")
augroup end

# Applying code actions to the selected code block
# Example: `<Leader>aap` for current paragraph
xmap <Leader>a  <Plug>(coc-codeaction-selected)
nmap <Leader>a  <Plug>(coc-codeaction-selected)

# Remap keys for applying code actions at the cursor position
nmap <Leader>cc  <Plug>(coc-codeaction-cursor)
# Remap keys for apply code actions affect whole buffer
nmap <Leader>cs  <Plug>(coc-codeaction-source)
# Apply the most preferred quickfix action to fix diagnostic on the current line
nmap <Leader>.  <Plug>(coc-fix-current)
nmap <Leader>ca  <Plug>(coc-fix-current)

# Remap keys for applying refactor code actions
xmap <silent> <LocalLeader>r  <Plug>(coc-codeaction-refactor-selected)
nmap <silent> <LocalLeader>r  <Plug>(coc-codeaction-refactor-selected)

# Run the Code Lens action on the current line
nmap <Leader>cl  <Plug>(coc-codelens-action)

nmap [oI  <Cmd>CocCommand document.enableInlayHint<CR>
nmap ]oI  <Cmd>CocCommand document.disableInlayHint<CR>
nmap yoI  <Cmd>CocCommand document.toggleInlayHint<CR>

# Map function and class text objects
# NOTE: Requires "textDocument.documentSymbol" support from the language server
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

# Remap <C-f> and <C-b> to scroll float windows/popups
if has("nvim-0.4.0") || has("patch-8.2.0750")
	nnoremap <silent><nowait><expr> <C-F> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-F>"
	nnoremap <silent><nowait><expr> <C-B> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-B>"
	inoremap <silent><nowait><expr> <C-F> coc#float#has_scroll() ? "\<C-R>=coc#float#scroll(1)\<CR>" : "\<Right>"
	inoremap <silent><nowait><expr> <C-B> coc#float#has_scroll() ? "\<C-R>=coc#float#scroll(0)\<CR>" : "\<Left>"
	vnoremap <silent><nowait><expr> <C-F> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-F>"
	vnoremap <silent><nowait><expr> <C-B> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-B>"
endif

# Use CTRL-S for selections ranges
# Requires "textDocument/selectionRange" support of language server
nmap <silent> <C-S> <Plug>(coc-range-select)
xmap <silent> <C-S> <Plug>(coc-range-select)

# Add `:Format` command to format current buffer
command! -nargs=0 Format call CocActionAsync("format")

# Add `:Fold` command to fold current buffer
command! -nargs=? Fold call CocAction("fold", <f-args>)

# Add `:OR` command for organize imports of the current buffer
command! -nargs=0 OR   call CocActionAsync("runCommand", "editor.action.organizeImport")

nnoremap <Leader>e  <Cmd>CocCommand explorer<CR>

# Mappings for CoCList
nnoremap <Leader><Space> <Cmd>CocList files<CR>
nnoremap <Leader>o  <Cmd>CocList outline<CR>
nnoremap <Leader>s  <Cmd>CocList symbols<CR>
nnoremap <Leader>j  <Cmd>CocNext<CR>
nnoremap <Leader>k  <Cmd>CocPrev<CR>
nnoremap <Leader>p  <Cmd>CocListResume<CR>
nnoremap <Leader>b <Cmd>CocList buffers<CR>
nnoremap <Leader>; <Cmd>CocList commands<CR>
nnoremap <Leader>f <Cmd>CocList grep<CR>
nnoremap <Leader>h <Cmd>CocList helptags<CR>
nnoremap <Leader>r <Cmd>CocList mru<CR>
nnoremap <Leader>m <Cmd>CocList marketplace<CR>
nnoremap <Leader>t <Cmd>CocList tasks<CR>
# }}}

# ALE {{{
Pack "dense-analysis/ale"

g:ale_sign_column_always = true
g:ale_disable_lsp = true
g:ale_echo_msg_format = "[%linter%] %s [%severity%]"
g:ale_virtualtext_prefix = ""
g:ale_sign_error = ">>"
g:ale_sign_warning = "--"
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
autocmd VimEnter * hi clear SpellBad
autocmd VimEnter * hi clear SpellCap
autocmd VimEnter * hi clear SpellLocal
autocmd VimEnter * hi clear SpellRare
autocmd VimEnter * hi SpellBad gui=undercurl guisp=LightRed term=undercurl
autocmd VimEnter * hi SpellCap gui=undercurl guisp=LightYellow term=undercurl
autocmd VimEnter * hi SpellLocal gui=undercurl guisp=LightBlue term=undercurl
autocmd VimEnter * hi SpellRare gui=undercurl guisp=LightGreen term=undercurl
autocmd VimEnter,Colorscheme * hi ALEVirtualTextError   ctermfg=12 ctermbg=16 guifg=#ff0000 guibg=#1E1E2E
autocmd VimEnter,Colorscheme * hi ALEVirtualTextWarning ctermfg=6  ctermbg=16 guifg=#ff922b guibg=#1E1E2E
autocmd VimEnter,Colorscheme * hi ALEVirtualTextInfo    ctermfg=14 ctermbg=16 guifg=#fab005 guibg=#1E1E2E

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
autocmd FileType vader nnoremap <buffer><silent> K K
autocmd BufRead,BufNewFile *.vader setfiletype vader
# }}}

# competitest {{{
Pack "mao-yining/competitest.vim"
g:competitest_configs = {
	multiple_testing: 1,
	output_compare_method: (output: string, expout: string) => {
		def SquishString(str: string): string
			var res = str
			res = substitute(res, '\s*\n', '\n', 'g') # 去除行尾空格
			res = substitute(res, '^\s*', '', '')     # 删除开头的所有空白字符
			res = substitute(res, '\s*$', '', '')     # 删除结尾的所有空白字符
			return res
		enddef
		var _output = SquishString(output)
		var _expout = SquishString(expout)
		return _output == _expout
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

		var safe_contest = substitute(substitute(contest, '[<>:"/\\|?*]', '_', 'g'), '#', '', 'g')
		var safe_name = substitute(substitute(task.name, '[<>:"/\\|?*]', '_', 'g'), '#', '', 'g')

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

plugpac#End() # }}}

if &background == 'dark'
	silent! colorscheme catppuccin_mocha
	g:qline_config.colorscheme = 'airline:catppuccin_mocha'
else
	silent! colorscheme catppuccin_latte
	g:qline_config.colorscheme = 'airline:catppuccin_latte'
endif
