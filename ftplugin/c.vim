vim9script

if executable("clang-format")
	setl formatprg=clang-format\ -assume-filename=\"%\"
endif

if exists("g:loaded_lsp")
	import autoload '../autoload/lsp.vim'
	augroup LspSetup
		au!
		au User LspAttached {
			lsp.SetupMaps()
			setl keywordprg=:LspHover
			setl omnifunc=LspOmniFunc
		}
	augroup END
endif
