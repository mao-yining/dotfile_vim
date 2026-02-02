if exists("b:current_syntax")
  finish
endif
let b:current_syntax = "qf"

syn match	qfFileName	"^[^|]*|"	   nextgroup=qfLineNr contains=qfSeparator1
syn match	qfSeparator1	"|"	 contained
syn match	qfLineNr	"[^|]*|" contained nextgroup=qfText contains=qfSeparator2
syn match	qfSeparator2	"|"	 contained
syn match	qfText		".*"	 contained contains=@qfType

syn match	qfError		"error"	  contained
syn match	qfWarning	"warning" contained
syn match	qfNote		"note"    contained
syn match	qfInfo		"info"    contained
syn cluster	qfType		contains=qfError,qfWarning,qfNote,qfInfo

hi def link qfFileName		Directory
hi def link qfLineNr		LineNr
hi def link qfSeparator1	Delimiter
hi def link qfSeparator2	Delimiter
hi def link qfText		Normal
hi def link qfError		Error

" vim: ts=8
