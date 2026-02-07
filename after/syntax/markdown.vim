exe $'syn match mdTodoCheckbox /\%({&l:formatlistpat}\)\@<=\[ \]/ containedin=TOP'
exe $'syn match mdDoneCheckbox /\%({&l:formatlistpat}\)\@<=\[[xX]\]/ containedin=TOP'
exe $'syn match mdPendingCheckbox /\%({&l:formatlistpat}\)\@<=\[[-=]\]/ containedin=TOP'
exe $'syn match mdWrongCheckbox /\%({&l:formatlistpat}\)\@<=\[[?!]\]/ containedin=TOP'
hi! def link mdTodoCheckbox Todo
hi! def link mdDoneCheckbox Added
hi! def link mdPendingCheckbox Changed
hi! def link mdWrongCheckbox Error

syn match mdTodo /\<TODO\>/
syn match mdXXX /\<XXX\>/
syn match mdFixMe /\<FIXME\>/
syn match mdInProgress /\<\(CURRENT\|INPROGRESS\|STARTED\|WIP\)\>/
syn match mdDoneItem /^\(\s\+\).*\<DONE\>.*\(\n\1\s.*\)*/ contains=@mdInline
syn match mdDoneMarker /\<DONE\>/ containedin=mdDoneItem
hi! def link mdTodo WarningMsg
hi! def link mdXXX WarningMsg
hi! def link mdFixMe WarningMsg
hi! def link mdDoneItem Comment
hi! def link mdDoneMarker Question
hi! def link mdInProgress Directory

syn region mdWikilink matchgroup=mdWikilinkDelimiter start="\[\[" end="\]\]" contains=@markdownInline,markdownLineStart
hi! def link mdWikilinkDelimiter markdownLinkDelimiter
hi! def link mdWikilink markdownIdDeclaration
