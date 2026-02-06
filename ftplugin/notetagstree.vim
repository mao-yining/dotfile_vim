if exists('b:did_ftp')
  finish
endif
vim9script
import autoload "../autoload/notebook.vim"

setlocal cursorline
setlocal nomodifiable
setlocal nobuflisted
setlocal nonumber
setlocal iskeyword+=-
setlocal norelativenumber
setlocal bufhidden=wipe
setlocal syntax=zktagstree
setlocal buftype=nofile
setlocal noswapfile
setlocal winfixwidth

nnoremap <silent><nowait><buffer> q <Cmd>close<CR>
nnoremap <silent><nowait><buffer> <F2> <Cmd>close<CR>

def OnEnter()
  const bufnr = bufnr('zk://browser')
  if bufload(bufnr)
      const content = notebook.GetNoteBrowserContent({tags: [trim(getline('.'))]})
      setbufvar(bufnr, '&modifiable', 1)
      deletebufline(bufnr, 1, '$')
      setbufline(bufnr, 1, content)
      setbufvar(bufnr, '&modifiable', 0)
  endif
enddef

nnoremap <silent><nowait><buffer> <Enter> <ScriptCmd>OnEnter()<CR>

def OnLeftRelease()
  if util.syntax_at() == 'zktagstreeOrg'
      sidebar.toggle_folded_key()
  else
    const bufnr = bufnr('zk://browser')
    if bufloaded(bufnr)
        const content = notbook.GetNoteBrowserContent({ tags:[trim(getline('.'))]})
        setbufvar(bufnr, '&modifiable', 1)
        deletebufline(bufnr, 1, '$')
        setbufline(bufnr, 1, content)
        setbufvar(bufnr, '&modifiable', 0)
    endif
  endif
enddef
nnoremap <silent><nowait><buffer> <LeftRelease> <ScriptCmd>OnLeftRelease()<CR>
b:did_ftp = true
