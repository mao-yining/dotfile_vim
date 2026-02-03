setl tw=80
if executable("indent") && &ft == 'c'
	let &l:formatprg = $'indent -kr'
elseif executable("clang-format")
	setl formatprg=clang-format\ -assume-filename=\"%\"
endif
