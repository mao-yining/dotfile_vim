vim9script
g:mapleader = ' '
g:maplocalleader = ';'
filetype plugin indent on
syntax enable

set encoding=utf-8
set nocompatible
set hidden confirm
set belloff=all shortmess+=cC
set nolangremap
set helplang=cn spelllang=en_gb,cjk
set history=10000 updatetime=400 tabpagemax=50 termwinscroll=40000
set display=truncate smoothscroll scrolloff=5
set colorcolumn=+1 conceallevel=2
set formatoptions+=mMjn
set splitbelow splitright
set autoindent smartindent smarttab
set foldopen+=jump,insert
set jumpoptions=stack
set ttimeout ttimeoutlen=50
set autowrite autoread
set hlsearch incsearch ruler laststatus=2 showmatch matchpairs+=<:>
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
set ignorecase smartcase
set completeopt=menuone,popup,fuzzy completepopup=border:off
set autocomplete complete=o^9,.^9,w^5,b^5,t^3,u^2
set complete+=Fcompletor#Path^9,Fcompletor#Abbrev^3,Fcompletor#Register^3
set mouse=a mousemodel=extend clipboard^=unnamed
set wildmode=noselect:lastused,full
set wildmenu wildoptions=pum,fuzzy wildcharm=<Tab> pumheight=12
set wildignore+=*.o,*.obj,*.bak,*.exe,*.swp,tags,*.cmx,*.cmi
set wildignore+=*~,*.py[co],__pycache__,pack
set wildignore+=*.obsidian,*.svg
if has("sodium") && has("patch-9.0.1481")
	set cryptmethod=xchacha20v2
else
	set cryptmethod=blowfish2
endif
set backup
if !empty($SUDO_USER) && $USER !=# $SUDO_USER
	setglobal viminfo=
	setglobal directory-=~/tmp
	setglobal backupdir-=~/tmp
elseif exists("+undodir")
	if !empty($XDG_DATA_HOME)
		$DATA_HOME = $XDG_DATA_HOME->trim("/", 2) .. "/vim/"
	elseif has("win32")
		$DATA_HOME = expand("~/AppData/Local/vim/")
	else
		$DATA_HOME = expand("~/.local/share/vim/")
	endif
	&undodir   = $DATA_HOME .. "undo/"
	&directory = $DATA_HOME .. "swap/"
	&backupdir = $DATA_HOME .. "backup/"
	if !isdirectory(&undodir)   | &undodir->mkdir("p")   | endif
	if !isdirectory(&directory) | &directory->mkdir("p") | endif
	if !isdirectory(&backupdir) | &backupdir->mkdir("p") | endif
	set undofile
endif
if has('gui_running')
	finish
endif
&t_TI = "\<Esc>[>4;2m"
&t_TE = "\<Esc>[>4;m"
&t_EI = "\e[2 q"
&t_SI = "\e[5 q"
&t_SR = "\e[3 q"
set <M-H>=H
set <M-J>=J
set <M-K>=K
set <M-L>=L
for i in range(10)
	execute $"set <M-{i}>={(i == 0 ? 10 : i)}"
endfor
