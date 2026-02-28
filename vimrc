vim9script
g:mapleader = ' '
g:maplocalleader = ';'
filetype plugin indent on
syntax on

set hidden confirm
set ttimeout ttimeoutlen=50
set belloff=all shortmess+=IcC
set autoindent smartindent smarttab
set nolangremap helplang=cn spelllang=en_gb,cjk
set history=10000 updatetime=400 tabpagemax=50 termwinscroll=40000
set display=lastline smoothscroll scrolloff=5 sidescroll=1 sidescrolloff=3
set colorcolumn=+1 conceallevel=2
set formatoptions+=mMjn
set splitbelow splitright
set foldopen+=jump,insert
set jumpoptions=stack
set autowrite autoread
set hlsearch incsearch ignorecase smartcase showmatch matchpairs+=<:>
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
set completeopt=menuone,popup,fuzzy completepopup=border:off
set previewpopup=border:round,borderhighlight:PmenuBorder
set autocomplete complete=o^9,.^9,w^5,b^5,t^3,u^2
set complete+=Fcompletor#Path^9,Fcompletor#Abbrev^3,Fcompletor#Register^3
set mouse=a mousemodel=extend clipboard^=unnamed
