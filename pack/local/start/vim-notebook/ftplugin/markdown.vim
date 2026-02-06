vim9script
const re = '\d\d\d\d-\d\d-\d\d-\d\d-\d\d-\d\d\.md'
if !(bufname() =~# re)
  finish
endif
import autoload "../autoload/notebook.vim"

setl tagfunc=notebook.TagFunc
setl completefunc=notebook.CompleteFunc

setl iskeyword+=:
setl iskeyword+=-
setl suffixesadd+=.mdreturn
setl errorformat=%f:%l:\ %m
setl include=\[\[\\s\]\]
setl define=^#\ \\s*
setl keywordprg=:NoteHover
command! -buffer -nargs=* -complete=custom,notebook.HoverComplete NoteHover notebook.InternalExecuteHoverCmd(<f-args>)

if mapcheck('[I', 'n') == ''
  nnoremap <silent><nowait><buffer> [I <ScriptCmd>require("zettelkasten").show_back_references(expand("<cword>"))<CR>
endif
