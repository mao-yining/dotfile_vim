if exists('b:did_ftp')
  finish
endif
vim9script
import autoload "../autoload/notebook.vim"

setl cursorline
setl nomodifiable
setl nobuflisted
setl buftype=nofile
setl noswapfile
setl iskeyword+=:
setl iskeyword+=-
setl suffixesadd+=.md
setl errorformat=%f:%l:\ %m
setl keywordprg=:NoteHover\ -preview
setl tagfunc=notebook.TagFunc
command! -buffer -nargs=* -complete=custom,notebook.HoverComplete NoteHover
				\ notebook.InternalExecuteHoverCmd(<f-args>)

nnoremap <silent><nowait><buffer> [I <ScriptCmd>notebook.ShowBackReferences(expand("<cword>"))<CR>
nnoremap <silent><nowait><buffer> q <ScriptCmd>Bdelete<CR>
nnoremap <silent><nowait><buffer> <C-r> <Cmd>ZkBrowse<CR>
def OnLeftRelease()
	if synstack(line('.'), col('.'))->map('synIDattr(v:val, "name")')->index('ZettelKastenTags') != -1
		notebook.Browse({
			tags: ['#' .. expand('<cword>')]
		})
	endif
enddef
nnoremap <silent><nowait><buffer> <LeftRelease> <ScriptCmd>OnLeftRelease()<CR>
nnoremap <silent><nowait><buffer> <F2> <ScriptCmd>notebook.OpenTagTree()<CR>
nnoremap <silent><nowait><buffer> <Enter> 0<Cmd>e <cfile><CR>

nnoremap <silent><nowait><buffer> u <C-u>
nnoremap <silent><nowait><buffer> d <C-d>
nnoremap <silent><nowait><buffer> f <C-f>
nnoremap <silent><nowait><buffer> b <C-b>

exe 'lcd' g:notebook_config.notes_path
augroup zkbrowser_autocmds
	autocmd!
	autocmd BufEnter <buffer> setl nobuflisted
	autocmd BufEnter <buffer> silent exe 'lcd' g:notebook_config.notes_path
augroup END
b:did_ftp = true
