vim9script

if exists("g:loaded_lsp")
	import autoload '../autoload/lsp.vim'
	augroup LspSetup
		au!
		au User LspAttached {
			lsp.SetupMaps()
			setl keywordprg=:LspHover
		}
	augroup END
endif

