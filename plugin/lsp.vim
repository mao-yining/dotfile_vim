if "lsp"->getcompletion("packadd")->empty()|finish|endif
vim9script
var lspServers: list<dict<any>>

if executable("clangd")
	lspServers->extend([{
		name: "clangd",
		filetype: ["c", "cpp"],
		path: "clangd",
		args: ["--background-index", "--clang-tidy"],
	}])
endif

if executable("pyright-langserver")
	lspServers->extend([{
		path: "pyright-langserver",
		filetype: ["python"],
		args: ["--stdio"],
		workspaceConfig: { python: { pythonPath: "python" } }
	}])
endif

if executable("texlab")
	lspServers->extend([{
		path: "texlab",
		filetype: ["tex", "bib"]
	}])
endif

if executable("rust-analyzer")
	lspServers->extend([{
		path: "rust-analyzer",
		filetype: ["rust"],
		syncInit: true
	}])
endif

# if executable("marksman")
# 	lspServers->extend([{
# 		path: "marksman",
# 		filetype: ["markdown", "pandoc"],
# 		args: ["server"],
# 		syncInit: true
# 	}])
# endif

if lspServers->empty()
	finish
endif

packadd lsp
g:LspAddServer(lspServers)
g:LspOptionsSet({
	autoComplete: false, # Use OmniComplete
	autoPopulateDiags: true,
	completionMatcher: "fuzzy",
	diagVirtualTextAlign: "after",
	filterCompletionDuplicates: true,
	ignoreMissingServer: false,
	semanticHighlight: true,
	semanticHighlightDelay: 350,
	showDiagWithVirtualText: true,
	useQuickfixForLocations: true, # For LspShowReferences
	usePopupInCodeAction: true,
})
import autoload 'lsp.vim'
augroup LspSetup
	au!
	au User LspAttached lsp.SetupMaps()
augroup END
