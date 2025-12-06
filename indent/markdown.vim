vim9script
if exists("b:did_indent")
	finish
endif
b:did_indent = 1

import autoload "../autoload/mdindent.vim"

setlocal indentexpr=mdindent.GetPDMIndent(v:lnum)

setlocal nolisp			# lisp indent overrides, cancel it
setlocal nosmartindent	# not sure this is necessary
setlocal autoindent
