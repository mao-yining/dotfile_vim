vim9script

if executable('rg')
	set grepprg=rg\ -H\ --no-heading\ --vimgrep\ \"$*\"
	set grepformat=%f:%l:%c:%m
	command! -nargs=1 Rg :exe $'{<q-mods>} Term rg {<q-args>}'
elseif executable('ugrep')
	set grepprg=ugrep\ -RInk\ -j\ -u\ --tabs=1\ --ignore-files\ \"$*\"
	set grepformat=%f:%l:%c:%m,%f+%l+%c+%m,%-G%f\\\|%l\\\|%c\\\|%m
	command! -nargs=1 Ug :exe $'{<q-mods>} Term ug {<q-args>}'
endif

command -nargs=1 -bar Grep {
	const cmd = $"{&grepprg} {<q-args>}"
	cgetexpr system(cmd)
	setqflist([], 'a', {title: cmd})
}

command -nargs=1 -bar LGrep {
	const cmd = $"{&grepprg} {<q-args>}"
	lgetexpr system(cmd)
	setloclist(winnr(), [], 'a', {title: cmd})
}

command! Todo :Rg TODO:

augroup quickfix
	autocmd!
	autocmd QuickFixCmdPost cgetexpr belowright cwindow
	autocmd QuickFixCmdPost lgetexpr belowright lwindow
augroup END
