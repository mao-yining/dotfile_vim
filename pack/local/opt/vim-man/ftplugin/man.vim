if exists('b:did_ftplugin')
  finish
endif
vim9script
import autoload '../autoload/man.vim'
if exists('$MANPAGER')
  $MANPAGER = ''
endif
setlocal iskeyword+=.,-
setlocal nonumber
setlocal norelativenumber
setlocal foldcolumn=0
setlocal nofoldenable
setlocal nolist
setlocal tabstop=8
setlocal buftype=nofile
setlocal bufhidden=hide
setlocal nobuflisted
setlocal noswapfile
nnoremap <buffer><nowait> u <C-U>
nnoremap <buffer><nowait> d <C-D>
nnoremap <buffer><nowait> f <C-F>
nnoremap <buffer><nowait> b <C-B>
nnoremap <buffer> K <ScriptCmd>man.GetPageFromCword('horizontal')<CR>
nnoremap <buffer> <C-]> <ScriptCmd>man.GetPageFromCword('horizontal')<CR>
nnoremap <buffer> g<C-]> <ScriptCmd>man.GetPageFromCword('horizontal')<CR>
nnoremap <buffer> g] <ScriptCmd>man.GetPageFromCword('horizontal')<CR>
nnoremap <buffer> <C-W>] <ScriptCmd>man.GetPageFromCword('horizontal')<CR>
nnoremap <buffer> <C-W><C-]> <ScriptCmd>man.GetPageFromCword('horizontal')<CR>
nnoremap <buffer> <C-W>g<C-]> <ScriptCmd>man.GetPageFromCword('horizontal')<CR>
nnoremap <buffer> <C-W>g] <ScriptCmd>man.GetPageFromCword('horizontal')<CR>
nnoremap <buffer> <C-W>} <ScriptCmd>man.GetPageFromCword('horizontal')<CR>
nnoremap <buffer> <C-W>g} <ScriptCmd>man.GetPageFromCword('horizontal')<CR>
nnoremap <buffer> <C-T> <ScriptCmd>man.PopPage()<CR>
nnoremap <buffer> ]] <ScriptCmd>man.SectionMove(v:count1)<CR>
xnoremap <buffer> ]] <ScriptCmd>man.SectionMove(v:count1)<CR>
nnoremap <buffer> [[ <ScriptCmd>man.SectionMove(v:count1, 'b')<CR>
xnoremap <buffer> [[ <ScriptCmd>man.SectionMove(v:count1, 'b')<CR>
nnoremap <buffer> q <Cmd>q<CR>
nnoremap <buffer> g/ /^\s*\zs
b:undo_ftplugin = 'setlocal iskeyword<'
b:did_ftplugin = 1
