vim9script

if !has('gui_running')
	set termguicolors
endif

def Lsp()
	hi link lspDiagSignErrorText Removed
	hi link lspDiagVirtualTextError Removed
	hi link lspDiagSignWarningText Changed
	hi link lspDiagVirtualTextWarning Changed
	hi link lspSigActiveParameter PreProc
enddef # }}}

def NoBg()
	if has("gui_running") || &background == "light"
		return
	endif
	hi Normal guibg=NONE ctermbg=NONE
	hi StatusLine guibg=NONE ctermbg=NONE
	hi StatusLineNC guibg=NONE ctermbg=NONE
enddef

def Vsplit()
	hi VertSplit guibg=NONE ctermbg=NONE
enddef

augroup colors | au!
	au Colorscheme polukate,habamax,wildcharm,lunaperche Lsp()
	au Colorscheme polukate,habamax,wildcharm,lunaperche,catppuccin* NoBg()
	au Colorscheme habamax,xamabah,wildcharm,lunaperche,catppuccin* Vsplit()
	au Colorscheme * hi CursorLineNr guibg=NONE gui=bold cterm=bold
augroup END

colorscheme catppuccin

import autoload "../autoload/inline_colors.vim"
augroup InlineColors | au!
	au FileType colortemplate inline_colors.InlineColorsInit()
	au OptionSet background inline_colors.InlineColorsInWindows()
	au OptionSet termguicolors inline_colors.InlineColorsInWindows()
augroup END
