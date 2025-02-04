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

# 斜杠

autocmd FileType tex,cpp,python,c,lua,json,vim setlocal shellslash

# 软换行

autocmd FileType tex,markdown,text set wrap

# vim:fdm=marker:fmr=[[[,]]]:ft=vim
