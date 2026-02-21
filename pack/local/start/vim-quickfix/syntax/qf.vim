if exists("b:current_syntax")
  finish
endif
let b:current_syntax = "qf"

syn match	qfFileName	"^\f\+:\d*:\(\d\+:\)\?" nextgroup=qfText contains=qfLineNr
syn match	qfLineNr	":\d*:\(\d\+:\)\?"	contained contains=qfSeparator
syn match	qfSeparator	":"		contained
syn match	qfText		".*"		contained	contains=@qfType

syn match	qfError		"\<error\>"	contained
syn match	qfWarning	"\<warning\>"	contained
syn match	qfNote		"\<note\>"	contained
syn match	qfInfo		"\<info\>"	contained
syn match	qfTodo		"\<TODO: "	contained
syn cluster	qfType		contains=qfError,qfWarning,qfNote,qfInfo,qfTodo

hi def link	qfFileName	Directory
hi def link	qfLineNr	LineNr
hi def link	qfSeparator	Delimiter
hi def link	qfText		Normal
hi def link	qfError		Error
hi def link	qfWarning	WarningMsg
hi def link	qfInfo		String
hi def link	qfNote		Todo
hi def link	qfTodo		Todo

" vim: ts=8
