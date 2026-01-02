vim9script

if executable("clang-format")
	setl formatprg=clang-format\ -assume-filename=\"%\"
endif

if exists("g:loaded_lsp")
	augroup CLspSetup | au!
		au User LspAttached setl keywordprg=:LspHover
	augroup END
endif
