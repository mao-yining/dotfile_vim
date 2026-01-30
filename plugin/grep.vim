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

command! Todo silent grep TODO:
nnoremap <expr> g<Space> "<Cmd>silent call g:SetProjectRoot()<CR>:silent grep "
nnoremap <expr> g! "<Cmd>silent call g:SetProjectRoot()<CR>:silent grep! "
