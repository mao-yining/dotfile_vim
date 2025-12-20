filetype plugin indent on
syntax enable

set nocompatible
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
set number relativenumber cursorline cursorlineopt=both signcolumn=number
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
set complete+=Fcompletor#Path^10,Fcompletor#Abbrev^3,Fcompletor#Register^3
set mouse=a mousemodel=extend
set clipboard^=unnamed

let g:mapleader = " "
let g:maplocalleader = ";"

colorscheme catppuccin
