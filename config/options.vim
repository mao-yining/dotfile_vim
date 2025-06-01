vim9script

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
set listchars=tab:>\ ,trail:-,precedes:<,extends:>,nbsp:+
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
set complete-=i                 # disable scanning included files
set complete-=t                 # disable searching tags
set completeopt=menu,popup,preview
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

# vim:fdm=marker:fmr=[[[,]]]:ft=vim
