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
set display=truncate smoothscroll scrolloff=5 sidescroll=1 sidescrolloff=3
set colorcolumn=+1 conceallevel=2
set formatoptions+=mMjn
set splitbelow splitright
set autoindent smartindent smarttab
set foldopen+=jump,insert
set jumpoptions=stack
set ttimeout ttimeoutlen=50
set autowrite autoread
set hlsearch incsearch laststatus=2 showmatch matchpairs+=<:>
set number relativenumber cursorline cursorlineopt=number signcolumn=number
set breakindent linebreak nojoinspaces
set list listchars=tab:›\ ,nbsp:␣,trail:·,extends:…,precedes:…
set fillchars=vert:│,fold:·,foldsep:│
set virtualedit=block,onemore nostartofline
set switchbuf=uselast
set nrformats=bin,hex,unsigned
set sessionoptions=buffers,options,curdir,help,tabpages,winsize,slash,terminal
set viewoptions=cursor,folds,curdir,slash
set diffopt+=algorithm:histogram,linematch:60
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
if has("sodium")
	set cryptmethod=xchacha20v2
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
set <M-t>=t
set <M-x>=x
for i in range(10)
	execute $"set <M-{i}>={(i == 0 ? 10 : i)}"
endfor
