let g:mapleader = ' '
let g:maplocalleader = ';'
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
set ignorecase smartcase infercase
set completeopt=menuone,popup,fuzzy completepopup=border:off
set autocomplete complete=o,.^9,w^5,b^5,t^3,u^2
set complete+=Fcompletor#Path,Fcompletor#Abbrev^3,Fcompletor#Register^3
set mouse=a mousemodel=extend clipboard^=unnamed
set wildmode=noselect:lastused,full
set wildmenu wildoptions=pum,fuzzy wildcharm=<Tab> pumheight=12
set wildignore+=*.o,*.obj,*.bak,*.exe,*.swp,tags,*.cmx,*.cmi
set wildignore+=*~,*.py[co],__pycache__,pack
set wildignore+=*.obsidian,*.svg
