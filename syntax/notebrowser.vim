if exists("b:current_syntax")
	finish
endif
let b:current_syntax = 'notebrowser'
syntax match ZettelKastenID '[0-9]\+-[0-9]\+-[0-9]\+-[0-9]\+-[0-9]\+-[0-9]\+\.md'
syntax match ZettelKastenDash '\s-\s'
syntax match ZettelKastenRefs '\[[0-9]\+ .*\]'
syntax match ZettelKastenTags '#\<\k\+\>'

highlight default link ZettelKastenID String
highlight default link ZettelKastenDash Comment
highlight default link ZettelKastenRefs Number
highlight default link ZettelKastenTags Tag
