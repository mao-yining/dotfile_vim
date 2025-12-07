vim9script

augroup python | au!
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

set keywordprg=:LspHover

if exists("g:loaded_lsp")
	import autoload '../autoload/lsp.vim'
	augroup LspSetup
		au!
		au User LspAttached lsp.SetupMaps()
	augroup END
endif

