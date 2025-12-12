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
# }}}

# packs {{{
plugpac#Begin({
	progress_open: "tab",
	status_open: "vertical",
})

Pack "catppuccin/vim", { name: "catppuccin" }
Pack "k-takata/minpac", { type: "opt" }
Pack "yianwillis/vimcdoc", { type: "opt" }

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

Pack "lacygoill/vim9asm", { on: "Disassemble" } # vim9 asm plugin

Pack "vim-scripts/DrawIt", { on: "DIstart" }
nmap =d <Cmd>DIstart<CR>
nmap \d <Cmd>DIstop<CR>

Pack "habamax/vim-dir"

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
Pack "mbbill/undotree", { on: "UndotreeToggle" } # 撤销树
Pack "tpope/vim-fugitive", { type: "opt" }
Pack "tpope/vim-rhubarb", { type: "opt" }
Pack "junegunn/gv.vim", { type: "opt" }
Pack "airblade/vim-gitgutter", { type: "opt" }
Pack "rhysd/conflict-marker.vim", { type: "opt" }
Pack "vim-utils/vim-man", { on: ["Man", "Mangrep"]}
Pack "jamessan/vim-gnupg", { type: "opt" }
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
Pack "puremourning/vimspector", { type: "opt" }
Pack "vim-test/vim-test", { on: [ "TestNearest", "TestFile", "TestSuite" ] }
Pack "mao-yining/competitest.vim"
Pack "vim/colorschemes"
Pack 'yegappan/lsp', { type: "opt" }
Pack 'hrsh7th/vim-vsnip', { type: "opt" }
Pack 'hrsh7th/vim-vsnip-integ', { type: "opt" }
Pack 'rafamadriz/friendly-snippets', { type: "opt" }
Pack 'girishji/scope.vim', { on: 'Scope', type: "opt" }

plugpac#End() # }}}

colorscheme catppuccin
# vim:fdm=marker
