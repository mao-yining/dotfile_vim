vim9script

$v = $HOME .. (has('win32') ? '/vimfiles' : '/.vim')
$VIMRC = $v .. '/vimrc'

g:mapleader = ' '            # 定义<leader>键
g:maplocalleader = ';'       # 定义<loaclleader>键

# options {{{
set nocompatible                # 设置不兼容原始vi模式

set t_Co=256                    # 开启256色支持
set termguicolors               # 在终端上使用与 GUI 一致的颜色

set noerrorbells                # 关闭错误提示
set belloff=all
set vb t_vb=

set spelllang=en,cjk
set langmenu=zh_CN.UTF-8
set helplang=cn
set termencoding=utf-8
set encoding=utf-8

set display=lastline
set smoothscroll
set conceallevel=2

set formatoptions+=mM1          # 强制自动换行，应对中文无空格
set formatoptions+=j            # 按 J 时自动删除注释符号
set showcmd                     # select模式下显示选中的行数
set mouse=a
set ruler                       # 总是显示光标位置
set nowrap                      # 禁止折行
set laststatus=2                # 总是显示状态栏
set history=200                 # keep 200 lines of command line history
set timeoutlen=500              # 设置<ESC>键响应时间
set virtualedit=block
set noshowmode                  # 设置不打开底部insert
set switchbuf=useopen,usetab
set hidden                      # 设置允许在未保存切换buffer
set matchpairs+=<:>             # 设置%匹配<>

set smartindent                 # 智能的选择对其方式
set expandtab                   # 设置空格替换tab
set tabstop=4                   # 设置编辑时制表符占用空格数
set list
set listchars=tab:¦\ ,trail:-,precedes:<,extends:>,nbsp:+
set smarttab                    # 在行和段开始处使用制表符

set sidescroll=0                # 设置向右滑动距离
set sidescrolloff=0             # 设置右部距离
set scrolloff=5                 # 设置底部距离

set foldmethod=marker
set foldopen+=jump
set jumpoptions=stack

set cursorline                  # 高亮显示当前行
set number                      # 开启行号显示
set relativenumber              # 展示相对行号

set updatetime=300
set tabpagemax=50

set undodir=~/.cache/undofiles/ # 需是一个已经存在的文件夹
set undofile
set nobackup
set nowritebackup
set swapfile
set autowrite
set autoread                    # 设置自动保存

set hlsearch                    # 高亮显示搜索结果
set incsearch                   # 开启实时搜索功能
set ignorecase                  # 搜索时大小写不敏感
set smartcase                   # 搜索智能匹配大小写

set shortmess+=c                # 设置补全静默
set complete+=kspell            # 设置补全单词
set completeopt=fuzzy,menuone,popup
set wildmenu
set wildoptions=pum,fuzzy
set wildignore=*.o,*.obj,*.bak,*.exe,*.swp,tags,*.cmx,*.cmi
set wildignore+=*~,*.py[co],__pycache__
set completepopup=highlight:Pmenu,border:off

set diffopt=vertical,internal,filler,closeoff,indent-heuristic,hiddenoff,algorithm:patience
set diffopt+=inline:word        # word / char  patch 9.1.1243
set sessionoptions=buffers,curdir,folds,help,resize,tabpages,winsize,slash,terminal,unix
set viewoptions=cursor,folds,slash,unix
if has('win32')
  autocmd VimEnter * set shellslash
endif

set clipboard=unnamed

if has('sodium') && has("patch-9.0.1481")
  set cryptmethod=xchacha20v2
endif

# }}}

# keymaps {{{
noremap j gj
noremap k gk
inoremap <Up> <C-O>gk
inoremap <Down> <C-O>gj

# vim-buffer {{{
nnoremap <silent>H     <Cmd>call <sid>ChangeBuffer('p')<CR>
nnoremap <silent>L     <Cmd>call <sid>ChangeBuffer('n')<CR>
nnoremap <expr><CR> &bt == "" ? "<Cmd>w<CR>" : &bt == 'terminal' ? "i\<enter>" : getwininfo(win_getid())[0]["quickfix"] != 0 ? "\<CR>:cclose<CR>" : getwininfo(win_getid())[0]["loclist"] != 0 ? "\<CR>:lclose<CR>" : "\<CR>"

# buffer delete {{{
nnoremap <silent>=b <Cmd>enew<CR>
nnoremap <silent>\b <Cmd>call CloseBuf()<CR>
def ChangeBuffer(direct: string)
    if &bt != '' || &ft == 'netrw'|echoerr "buftype is " ..  &bt .. " cannot be change"|return|endif
    if direct == 'n'|bn
    else|bp|endif
    while &bt != ''
        if direct == 'n'|bn
        else|bp|endif
    endwhile
enddef
def g:CloseBuf()
    if &bt != '' || &ft == 'netrw'|bd|return|endif
    var buf_now = bufnr()
    var buf_jump_list = getjumplist()[0]
    var buf_jump_now = getjumplist()[1] - 1
    while buf_jump_now >= 0
        var last_nr = buf_jump_list[buf_jump_now]["bufnr"]
        var last_line = buf_jump_list[buf_jump_now]["lnum"]
        if buf_now != last_nr && bufloaded(last_nr) && getbufvar(last_nr, "&bt") == ''
            execute ":buffer " .. last_nr
            execute ":bd " .. buf_now
            return
        else
            buf_jump_now -= 1
        endif
    endwhile
    bp|while &bt != ''|bp|endwhile
    execute "bd " .. buf_now
enddef
# }}}
# }}}

# reload .vimrc
nnoremap <Leader>S <Cmd>set nossl<CR><Cmd>source $MYVIMRC<CR><Cmd>set ssl<CR>

# 插入移动
inoremap <C-e> <end>
inoremap <C-a> <C-o>^
inoremap <C-d> <del>
vnoremap <C-d> <del>
inoremap <C-f> <C-o>w
inoremap <C-v> <C-o>D

# vimdiff tool
cab <expr>Diff "Diff ".expand('%:p:h')."/"
command! -nargs=1 -bang -complete=file Diff exec ":vert diffsplit ".<q-args>
command! -nargs=0 Remote <Cmd>diffg RE
command! -nargs=0 Base   <Cmd>diffg BA
command! -nargs=0 Local  <Cmd>diffg LO

nnoremap <C-s> <Cmd>w<CR>

# change window width
nnoremap <C-up> <C-w>+
nnoremap <C-down> <C-w>-
nnoremap <C-left> <C-w><
nnoremap <C-right> <C-w>>

# change window in normal
nmap <Leader>w <C-w>
nnoremap <C-k> <C-w>k
nnoremap <C-j> <C-w>j
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l
nnoremap <M-k> <C-w>k
nnoremap <M-j> <C-w>j
nnoremap <M-h> <C-w>h
nnoremap <M-l> <C-w>l

nnoremap <silent><nowait>=q <Cmd>copen<CR>
nnoremap <silent><nowait>\q <Cmd>cclose<CR>
nnoremap <silent><nowait>=l <Cmd>lopen<CR>
nnoremap <silent><nowait>\l <Cmd>lclose<CR>
# show indent line
nnoremap <silent><nowait>=i <Cmd>set list lcs=tab:¦\<Space> <CR>
nnoremap <silent><nowait>\i <Cmd>set nolist<CR>

# set spell
nnoremap <silent><nowait>=s <Cmd>setlocal spell<CR>
nnoremap <silent><nowait>\s <Cmd>setlocal nospell<CR>

# set wrap
nnoremap <silent><nowait>=r <Cmd>setlocal wrap<CR><Cmd>noremap<buffer> j gj<CR><Cmd>noremap<buffer> k gk<CR>
nnoremap <silent><nowait>\r <Cmd>setlocal nowrap<CR><Cmd>unmap<buffer> j<CR><Cmd>unmap<buffer> k<CR>

# set line number
nnoremap <silent><nowait>=n <Cmd>setlocal norelativenumber<CR>
nnoremap <silent><nowait>\n <Cmd>setlocal relativenumber<Bar>setlocal number<CR>

# close/open number
nnoremap <silent><nowait>=N <Cmd>setlocal norelativenumber<CR><Cmd>setlocal nonumber<CR>
nnoremap <silent><nowait>\N <Cmd>setlocal relativenumber<CR><Cmd>setlocal number<CR>

# set fold auto,use zE unset all fold,zf create fold
nnoremap <silent><nowait>=z <Cmd>setlocal fdm=indent<CR><Cmd>setlocal fen<CR>
nnoremap <silent><nowait>\z <Cmd>setlocal fdm=manual<CR><Cmd>setlocal nofen<CR>
nnoremap <silent><nowait>=o zO
nnoremap <silent><nowait>\o zC
nnoremap <silent><nowait><expr><BS> foldlevel('.') > 0 ? "zc" : "\<BS>"

# " tab ctrl
nnoremap <silent><nowait>=<tab> <Cmd>tabnew<CR>
nnoremap <silent><nowait>\<tab> <Cmd>tabc<CR>
nnoremap <silent><nowait>[<tab> <Cmd>tabp<CR>
nnoremap <silent><nowait>]<tab> <Cmd>tabn<CR>

noremap <silent><M-1> <Cmd>tabn 1<CR>
noremap <silent><M-2> <Cmd>tabn 2<CR>
noremap <silent><M-3> <Cmd>tabn 3<CR>
noremap <silent><M-4> <Cmd>tabn 4<CR>
noremap <silent><M-5> <Cmd>tabn 5<CR>
noremap <silent><M-6> <Cmd>tabn 6<CR>
noremap <silent><M-7> <Cmd>tabn 7<CR>
noremap <silent><M-8> <Cmd>tabn 8<CR>
noremap <silent><M-9> <Cmd>tabn 9<CR>
noremap <silent><M-0> <Cmd>tabn 10<CR>
inoremap <silent><M-1> <ESC><Cmd>tabn 1<CR>
inoremap <silent><M-2> <ESC><Cmd>tabn 2<CR>
inoremap <silent><M-3> <ESC><Cmd>tabn 3<CR>
inoremap <silent><M-4> <ESC><Cmd>tabn 4<CR>
inoremap <silent><M-5> <ESC><Cmd>tabn 5<CR>
inoremap <silent><M-6> <ESC><Cmd>tabn 6<CR>
inoremap <silent><M-7> <ESC><Cmd>tabn 7<CR>
inoremap <silent><M-8> <ESC><Cmd>tabn 8<CR>
inoremap <silent><M-9> <ESC><Cmd>tabn 9<CR>
inoremap <silent><M-0> <ESC><Cmd>tabn 10<CR>

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
noremap <silent><M-left> <Cmd>call Tab_MoveLeft()<CR>
noremap <silent><M-right> <Cmd>call Tab_MoveRight()<CR>

# set search noh
nnoremap <silent><nowait>\h <Cmd>noh<CR>
nnoremap <silent><nowait>=h <Cmd>set hlsearch<CR>

# delete <Space> in end of line
nnoremap <silent><nowait>d<Space> <Cmd>%s/ *$//g<CR>:noh<CR><C-o>
nnoremap <nowait>g<Space> <Cmd>syntax match DiffDelete # *$"<CR>

# delete empty line
nnoremap <silent><nowait>dl <Cmd>g/^\s*$/d<CR>

# select search / substitute
xmap g/ "sy/<C-R>s
xmap gs "sy:%s/<C-R>s/

# run macro in visual model
xnoremap @ :normal @

# repeat for macro
nnoremap <silent><C-Q> @@

# indent buffer
onoremap <silent>A :<C-U>normal! ggVG<CR>
xnoremap <silent>A :<C-U>normal! ggVG<CR>

# object line
onoremap <silent>il :<C-U>normal! ^v$BE<CR>
xnoremap <silent>il :<C-U>normal! ^v$<CR><Left>
onoremap <silent>al :<C-U>normal! 0v$<CR>
xnoremap <silent>al :<C-U>normal! 0v$<CR>

# sudo to write file
cab w!! w !sudo tee % >/dev/null

# quick to change dir
cab cdn cd <C-R>=expand('%:p:h')<CR>
cab cdr cd <C-R>=FindRoot()<CR>
def g:FindRoot(): string
    var gitdir = finddir(".git", getcwd() .. ';')
    if !empty(gitdir)
        if gitdir == ".git"
            gitdir = getcwd()
        else
            gitdir = strpart(gitdir, 0, strridx(gitdir, "/"))
        endif
        return gitdir
    endif
    return ""
enddef

# enhance gf
nnoremap gf gF
vnoremap gf gF
# }}}

# autocmds {{{
# 回到上次编辑的位置
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

# vim -b : edit binary using xxd-format!
augroup Binary
  au!
  au BufReadPre  *.bin,*.exe let &bin=1
  au BufReadPost *.bin,*.exe if &bin | %!xxd
  au BufReadPost *.bin,*.exe set ft=xxd | endif
  au BufWritePre *.bin,*.exe if &bin | %!xxd -r
  au BufWritePre *.bin,*.exe endif
  au BufWritePost *.bin,*.exe if &bin | %!xxd
  au BufWritePost *.bin,*.exe set nomod | endif
augroup END

# 自动去除尾随空格
autocmd BufWritePre *.py :%s/[ \t\r]\+$//e

# 软换行
autocmd FileType tex,markdown,text set wrap

# 设置 q 来退出窗口
autocmd FileType fugitive,qf,help,gitcommit map <buffer>q <Cmd>q<CR>

# 在 gitcommit 中自动进入插入模式
autocmd FileType gitcommit :1 | startinsert

# 在某些窗口中关闭 list 模式
autocmd FileType GV setlocal nolist
# }}}

# plugs {{{
packadd! comment
packadd! editexisting
packadd! editorconfig
packadd! nohlsearch

call plug#begin()
Plug 'catppuccin/vim', { 'as': 'catppuccin' }
Plug 'stillwwater/wincap.vim'
Plug 'yianwillis/vimcdoc'

# coding {{{
Plug 'Eliot00/auto-pairs'         # vim9
Plug 'kshenoy/vim-signature'      # show marks
Plug 'wellle/targets.vim'
Plug 'andymass/vim-matchup'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-speeddating'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-characterize'     # 'ga' improve
Plug 'tpope/vim-surround'
Plug 'sheerun/vim-polyglot'
g:polyglot_disabled = ['sensible', 'markdown']
g:markdown_fenced_languages = [ 'c', 'cpp' ]
g:markdown_fenced_languages += [ 'bash', 'shell=sh', 'dosbatch' ]
g:markdown_fenced_languages += [ 'html', 'tex' ]
g:markdown_fenced_languages += [ 'vim', 'python' ]
g:markdown_minlines = 500
Plug 'tpope/vim-eunuch'
Plug 'girishji/vimbits'
Plug 'Andrewradev/switch.vim'
g:speeddating_no_mappings = 1
nnoremap <Plug>SpeedDatingFallbackUp <C-A>
nnoremap <Plug>SpeedDatingFallbackDown <C-X>
nnoremap <silent><C-A> <Cmd>if !switch#Switch() <Bar> call speeddating#increment(v:count1) <Bar> endif<CR>
nnoremap <silent><C-X> <Cmd>if !switch#Switch({'reverse': 1}) <Bar> call speeddating#increment(-v:count1) <Bar> endif<CR>
Plug 'itchyny/calendar.vim', { 'on': 'Calendar' }
Plug 'voldikss/vim-browser-search', { 'on': ['<Plug>SearchNormal', '<Plug>SearchVisual'] }
g:browser_search_default_engine = "bing"
nmap <silent> <LocalLeader>s <Plug>SearchNormal
vmap <silent> <LocalLeader>s <Plug>SearchVisual
# }}}

# ui {{{
Plug 'luochen1990/rainbow' # 彩虹括号
g:rainbow_conf = { guifgs: ['#da70d6', '#87cefa', ' #ffd700'] }
g:rainbow_active = 1

Plug 'mhinz/vim-startify'
autocmd user startified setlocal cursorline
g:startify_enable_special      = 0
g:startify_files_number        = 5
g:startify_relative_path       = 1
g:startify_change_to_dir       = 1
g:startify_update_oldfiles     = 1
g:startify_session_autoload    = 1
g:startify_session_persistence = 1
g:startify_session_dir = $v .. '/sessions'
g:startify_skiplist = [ "runtime/doc/", "/plugged/.*/doc/", "/.git/" ]
g:startify_skiplist += [ "/Temp/", "fugitiveblame$" ]
g:startify_bookmarks = [ { 'c': $vimrc } ]
g:startify_custom_footer = ["", "   Vim is charityware. Please read ':help uganda'.", ""]

Plug 'vim-airline/vim-airline'
# }}}

Plug 'skywind3000/vim-terminal-help'
g:terminal_list = 0
if has('win32')
    g:terminal_shell = 'nu'
endif
tnoremap <C-\> <C-\><C-N>
tnoremap <M-H> <C-_>h
tnoremap <M-L> <C-_>l
tnoremap <M-J> <C-_>j
tnoremap <M-K> <C-_>k

Plug 't9md/vim-choosewin', { 'on': '<Plug>(choosewin)' }
nmap <M-w> <Plug>(choosewin)
imap <M-w> <Esc><Plug>(choosewin)
tnoremap <M-w> <C-\><C-n><Plug>(choosewin)

Plug 'liuchengxu/vim-which-key', { 'on': ['WhichKey', 'WhichKey!'] }
nnoremap <silent><nowait> <Leader>      <Cmd>WhichKey '<Space>'<CR>
nnoremap <silent><nowait> <LocalLeader> <Cmd>WhichKey ';'<CR>
nnoremap <silent><nowait> = <Cmd>WhichKey '='<CR>
nnoremap <silent><nowait> \ <Cmd>WhichKey '\'<CR>

Plug 'vim-scripts/DrawIt', { 'on': 'DIstart' }
noremap =d <Cmd>DIstart<CR>
noremap \d <Cmd>DIstop<CR>

Plug 'habamax/vim-dir', { 'on': 'Dir' }
g:dir_show_hidden = false
nnoremap <silent>- <Cmd>Dir<CR>

Plug 'lilydjwg/colorizer', { 'on': 'ColorHighlight' }
noremap =c <Cmd>ColorHighlight<CR>
noremap \c <Cmd>ColorClear<CR>

Plug 'liuchengxu/vista.vim'
g:vista#renderer#enable_icon = false
nnoremap <silent><LocalLeader>v <Cmd>Vista!!<CR>

Plug 'dstein64/vim-startuptime', {'on': 'StartupTime'}

# gutentags 管理 tags 文件 {{{
Plug 'ludovicchabant/vim-gutentags', { 'on': 'GutentagsToggleEnabled' }
Plug 'skywind3000/gutentags_plus', { 'on': 'GscopeFind' }
# gutentags 搜索工程目录的标志当前文件路径向上递归直到碰到这些文件/目录名
g:gutentags_project_root = ['.root', '.svn', '.git', '.hg', '.project']
g:gutentags_ctags_tagfile = '.tags'   # 所生成的数据文件的名称
g:gutentags_modules = []              # 同时开启 ctags 和 gtags 支持
if executable('ctags')
    g:gutentags_modules += ['ctags']
endif
if executable('gtags-cscope') && executable('gtags')
    g:gutentags_modules += ['gtags_cscope']
endif
g:gutentags_cache_dir = expandcmd('~/.cache/tags')
g:gutentags_ctags_extra_args = [
    '--fields=+niazS',
    '--extra=+q',                     # ctags 的参数，Exuberant-ctags 不能有 --extra=+q
    '--c++-kinds=+px',
    '--c-kinds=+px',
    '--output-format=e-ctags'         # 若用 universal ctags 需加，Exuberant-ctags 不加
]
g:gutentags_auto_add_gtags_cscope = 0 # 禁用 gutentags 自动加载 gtags 数据库
g:gutentags_plus_switch = 1
# }}}

#  asynctasks {{{
Plug 'skywind3000/asyncrun.vim'
Plug 'skywind3000/asynctasks.vim'
g:asynctasks_term_pos = 'tab' # quickfix | vim | tab | bottom | external
# ‘vim' 时无法运行路径中有空格的情况
g:asyncrun_open = 6
g:asyncrun_save = 1
noremap <silent><f7> <Esc><Cmd>AsyncTask file-run<CR>
noremap <silent><f8> <Esc><Cmd>AsyncTask file-build<CR>
noremap <silent><f9> <Esc><Cmd>AsyncTask project-run<CR>
noremap <silent><f10> <Esc><Cmd>AsyncTask project-build<CR>
inoremap <silent><f7> <Esc><Cmd>AsyncTask file-run<CR>
inoremap <silent><f8> <Esc><Cmd>AsyncTask file-build<CR>
inoremap <silent><f9> <Esc><Cmd>AsyncTask project-run<CR>
inoremap <silent><f10> <Esc><Cmd>AsyncTask project-build<CR>
#  }}}

Plug 'sbdchd/neoformat', { 'on': 'Neoformat' }
noremap <LocalLeader>f <Cmd>Neoformat<CR>
g:neoformat_basic_format_align = 1 # Enable alignment
g:neoformat_basic_format_retab = 1 # Enable tab to spaces conversion
g:neoformat_basic_format_trim = 1  # Enable trimmming of trailing whitespace
g:neoformat_cpp_clangformat = { "exe": "clang-format", "args": [ expandcmd('-assume-filename="%"') ], "stdin": 1 }
g:neoformat_tex_texfmt = { "exe": "tex-fmt", "args": [ "--stdin" ], "stdin": 1 }
g:neoformat_enabled_tex = [ "texfmt" ]

Plug 'mbbill/undotree', { 'on': 'UndotreeToggle' } # 撤销树
noremap <Leader>u <Cmd>UndotreeToggle<CR>
g:undotree_SetFocusWhenToggle = true

Plug 'girishji/devdocs.vim'
nnoremap <Leader>D <Cmd>DevdocsFind<CR>

#  Git {{{
Plug 'tpope/vim-fugitive'
Plug 'junegunn/gv.vim', { 'on': ['GV', 'GV!'] }
nnoremap <Leader>gg <Cmd>Git<CR>
nnoremap <Leader>gl <Cmd>GV<CR>
nnoremap <Leader>gcc <Cmd>Git commit<CR>
nnoremap <Leader>gca <Cmd>Git commit --amend<CR>
nnoremap <Leader>gce <Cmd>Git commit --amend --no-edit<CR>
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
Plug 'airblade/vim-gitgutter'
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
Plug 'Eliot00/git-lens.vim'
Plug 'rhysd/conflict-marker.vim'
Plug 'mhinz/vim-signify', { 'on': 'SignifyEnable' }
g:signify_sign_add               = '+'
g:signify_sign_delete            = '_'
g:signify_sign_delete_first_line = '‾'
g:signify_sign_change            = '~'
g:signify_sign_changedelete      = g:signify_sign_change
#  }}}

Plug 'vim-utils/vim-man', { 'on': ['Man', 'Mangrep']}
Plug 'jamessan/vim-gnupg'
Plug 'vimwiki/vimwiki', { 'for': 'vimwiki' }
Plug 'romainl/vim-qf', { 'for': 'qf' }
Plug 'bfrg/vim-qf-preview', { 'for': 'qf' }
Plug 'ubaldot/vim-conda-activate', { 'on': 'CondaActivate' }
Plug 'bfrg/vim-cmake-help', { 'for': 'cmake' }
Plug 'lervag/vimtex', { 'for': 'tex', 'on': ['VimtexInverseSearch', 'VimtexDocPackage']}
Plug 'junegunn/vim-easy-align', { 'on': '<Plug>(EasyAlign)' }
xmap <LocalLeader>a <Plug>(EasyAlign)
nmap <LocalLeader>a <Plug>(EasyAlign)
Plug 'ferrine/md-img-paste.vim', { 'for': 'markdown' }
Plug 'nathangrigg/vim-beancount', { 'for': 'bean' }
Plug 'normen/vim-pio'

# vimspector {{{
Plug 'puremourning/vimspector'
g:vimspector_install_gadgets = [ 'debugpy', 'vscode-cpptools', 'CodeLLDB' ]
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
    if exists('<Leader><F5>')|nunmap <Leader><F5>|endif
    if exists('<F6>')|nunmap <F6>|endif
    nnoremap <silent><F7> <Esc><Cmd>AsyncTask file-run<CR>
    nnoremap <silent><F8> <Esc><Cmd>AsyncTask file-build<CR>
    nnoremap <silent><F9> <Esc><Cmd>AsyncTask project-run<CR>
    nnoremap <silent><F10> <Esc><Cmd>AsyncTask project-build<CR>
    if exists('<Leader><F11>')|nunmap <Leader><F11>|endif
    if exists('<Leader><F12>')|nunmap <Leader><F12>|endif
    if exists('<Leader>B')|nunmap <Leader>B|endif
    if exists('<Leader>D')|nunmap <Leader>D|endif
enddef
# }}}

# coc {{{
Plug 'tpope/vim-dadbod'
Plug 'kristijanhusak/vim-dadbod-ui' # Optional
Plug 'Shougo/neco-vim'
Plug 'neoclide/coc-neco'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'honza/vim-snippets'

if has('win32')
    set pythonthreedll=$HOME\AppData\Roaming\uv\python\cpython-3.13.3-windows-x86_64-none\python313.dll
    set pythonthreehome=$HOME\AppData\Roaming\uv\python\cpython-3.13.3-windows-x86_64-none\
endif
# Use tab for trigger completion with characters ahead and navigate
# NOTE: There's always complete item selected by default, you may want to enable
# no select by `"suggest.noselect": true` in your configuration file
# NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
# other plugin before putting this into your config
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

# Make <CR> to accept selected completion item or notify coc.nvim to format
# <C-g>u breaks current undo, please make your own choice
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \ : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

def CheckBackspace(): bool
    var col = col('.') - 1
    return !col || getline('.')[col - 1] =~# '\s'
enddef

# Use <C-l> for trigger snippet expand.
imap <C-l> <Plug>(coc-snippets-expand)

# Use <C-j> for select text for visual placeholder of snippet.
vmap <C-j> <Plug>(coc-snippets-select)

# Use <C-j> for jump to next placeholder, it's default of coc.nvim
g:coc_snippet_next = '<c-j>'

# Use <C-k> for jump to previous placeholder, it's default of coc.nvim
g:coc_snippet_prev = '<c-k>'

# Use <C-j> for both expand and jump (make expand higher priority.)
imap <C-j> <Plug>(coc-snippets-expand-jump)

# Use <leader>x for convert visual selected code to snippet
xmap <leader>x  <Plug>(coc-convert-snippet)

# Make <CR> to accept selected completion item or notify coc.nvim to format
# <C-g>u breaks current undo, please make your own choice
# inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
# \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

# Use <c-space> to trigger completion
if has('nvim')
    inoremap <silent><expr> <c-space> coc#refresh()
else
    inoremap <silent><expr> <c-@> coc#refresh()
endif

# GoTo code navigation
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

# Use K to show documentation in preview window
nnoremap <silent> K <cmd>call ShowDocumentation()<cr>
command! -nargs=0 Hover call CocAction('doHover')
def g:ShowDocumentation()
    if index(['vim', 'help'], &filetype) >= 0
        execute 'help ' .. expand('<cword>')
    elseif &filetype ==# 'tex'
        VimtexDocPackage
    else
        Hover
    endif
enddef

# Highlight the symbol and its references when holding the cursor
autocmd CursorHold * silent call CocActionAsync('highlight')

# Symbol renaming
nmap <f2> <Plug>(coc-rename)

augroup mygroup
    autocmd!
    # Setup formatexpr specified filetype(s)
    autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
    # Update signature help on jump placeholder
    autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

# Applying code actions to the selected code block
# Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

# Remap keys for applying code actions at the cursor position
nmap <leader>cc  <Plug>(coc-codeaction-cursor)
# Remap keys for apply code actions affect whole buffer
nmap <leader>cs  <Plug>(coc-codeaction-source)
# Apply the most preferred quickfix action to fix diagnostic on the current line
nmap <leader>.  <Plug>(coc-fix-current)
nmap <leader>ca  <Plug>(coc-fix-current)

# Remap keys for applying refactor code actions
xmap <silent> <localleader>r  <Plug>(coc-codeaction-refactor-selected)
nmap <silent> <localleader>r  <Plug>(coc-codeaction-refactor-selected)

# Run the Code Lens action on the current line
nmap <leader>cl  <Plug>(coc-codelens-action)

nmap [oI  <cmd>CocCommand document.enableInlayHint<cr>
nmap ]oI  <cmd>CocCommand document.disableInlayHint<cr>
nmap yoI  <cmd>CocCommand document.toggleInlayHint<cr>

# Map function and class text objects
# NOTE: Requires 'textDocument.documentSymbol' support from the language server
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

# Remap <C-f> and <C-b> to scroll float windows/popups
if has('nvim-0.4.0') || has('patch-8.2.0750')
    nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
    nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
    inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
    inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
    vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
    vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif

# Use CTRL-S for selections ranges
# Requires 'textDocument/selectionRange' support of language server
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

# Add `:Format` command to format current buffer
command! -nargs=0 Format call CocActionAsync('format')

# Add `:Fold` command to fold current buffer
command! -nargs=? Fold call CocAction('fold', <f-args>)

# Add `:OR` command for organize imports of the current buffer
command! -nargs=0 OR   call CocActionAsync('runCommand', 'editor.action.organizeImport')

# Mappings for CoCList
# Manage extensions
nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
# Find symbol of current document
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
# Search workspace symbols
nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
# Do default action for next item
nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
# Do default action for previous item
nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
# Resume latest coc list
nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>

nnoremap <silent><nowait> <leader>b <cmd>CocList buffers<CR>
nnoremap <silent><nowait> <leader>; <cmd>CocList commands<CR>
nnoremap <silent><nowait> <leader><space> <cmd>CocList files<CR>
nnoremap <silent><nowait> <leader>f <cmd>CocList grep<CR>
nnoremap <silent><nowait> <leader>h <cmd>CocList helptags<CR>
nnoremap <silent><nowait> <leader>r <cmd>CocList mru<CR>
nnoremap <silent><nowait> <leader>m <cmd>CocList marketplace<CR>
nnoremap <silent><nowait> <leader>t <cmd>CocList tasks<CR>
# }}}

# ALE {{{
Plug 'dense-analysis/ale'

g:ale_sign_column_always = true
g:airline#extensions#ale#enabled = 1
g:ale_disable_lsp = true
g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
g:ale_virtualtext_prefix = ""
g:ale_sign_error = '>>'
g:ale_sign_warning = '--'
nmap <localleader>d <Plug>(ale_detail)
nmap <silent> [d <Plug>(ale_previous)
nmap <silent> ]d <Plug>(ale_next)
g:ale_c_cppcheck_options = '--enable=style --check-level=exhaustive'
g:ale_cpp_cppcheck_options = '--enable=style --check-level=exhaustive'

# }}}

call plug#end()
# }}}

# colors{{{
silent! colorscheme catppuccin_mocha # 颜色主题
hi! clear SpellBad
hi! clear SpellCap
hi! clear SpellLocal
hi! clear SpellRare
hi! SpellBad gui=undercurl guisp=LightRed term=undercurl
hi! SpellCap gui=undercurl guisp=LightYellow term=undercurl
hi! SpellLocal gui=undercurl guisp=LightBlue term=undercurl
hi! SpellRare gui=undercurl guisp=LightGreen term=undercurl
hi! ALEVirtualTextError   ctermfg=12 ctermbg=16 guifg=#ff0000 guibg=#1E1E2E
hi! ALEVirtualTextWarning ctermfg=6  ctermbg=16 guifg=#ff922b guibg=#1E1E2E
hi! ALEVirtualTextInfo    ctermfg=14 ctermbg=16 guifg=#fab005 guibg=#1E1E2E
# }}}

# vim:fdm=marker:ft=vim
