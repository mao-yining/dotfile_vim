if has("sodium") && has("patch-9.0.1481")
	set cryptmethod=xchacha20v2
else
	set cryptmethod=blowfish2
endif

if executable("gpg")
	packadd vim-gnupg
endif
