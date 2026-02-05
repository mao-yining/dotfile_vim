vim9script
exe $'syn match markdownTodoCheckbox /\%({&l:formatlistpat}\)\@<=\[ \]/ containedin=TOP'
exe $'syn match markdownDoneCheckbox /\%({&l:formatlistpat}\)\@<=\[[xX]\]/ containedin=TOP'
exe $'syn match markdownPendingCheckbox /\%({&l:formatlistpat}\)\@<=\[[-=]\]/ containedin=TOP'
exe $'syn match markdownWrongCheckbox /\%({&l:formatlistpat}\)\@<=\[[?!]\]/ containedin=TOP'
hi! def link markdownTodoCheckbox Todo
hi! def link markdownDoneCheckbox Added
hi! def link markdownPendingCheckbox Changed
hi! def link markdownWrongCheckbox Error
