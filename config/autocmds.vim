vim9script

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

# 设置 q 来退出无需编辑的窗口
autocmd FileType fugitive,qf map <buffer>q <Cmd>q<CR>

# 在 git commit 界面自动进入插入模式
autocmd FileType gitcommit :1 | startinsert

# vim:fdm=marker:fmr=[[[,]]]:ft=vim
