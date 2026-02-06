vim9script
import autoload "../autoload/notebook.vim"
command! -nargs=0 NoteNew notebook.NewNote()
command! -nargs=? NoteBrowse notebook.Browse(<f-args>)
