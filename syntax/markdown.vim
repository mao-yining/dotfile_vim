exe $'syn match markdownCheckbox /\%({&l:formatlistpat}\)\@<=\[[xX ]\]/ containedin=TOP'

hi! def link markdownCheckbox MarkdownListMarker
