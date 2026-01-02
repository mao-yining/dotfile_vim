vim9script

augroup MyPython | au!
	autocmd BufWritePre <buffer> FixTrailingSpaces
augroup end

if executable('ruff')
    &l:formatprg = "ruff format --stdin-filename %"
elseif executable('black')
    &l:formatprg = "black -q - 2>/dev/null"
elseif executable('yapf')
    # pip install yapf
    &l:formatprg = "yapf"
endif
