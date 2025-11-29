vim9script

setl keywordprg=:LspHover

if exists("g:loaded_lsp")
	import autoload '../autoload/lsp.vim'
	augroup LspSetup
		au!
		au User LspAttached lsp.SetupMaps()
	augroup END
endif

