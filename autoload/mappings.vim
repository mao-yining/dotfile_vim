vim9script
import autoload "./popup.vim"
import autoload "./text.vim"
import autoload "./qc.vim"
import autoload "qf.vim"

def SourceVim(...args: list<any>): string
	if len(args) == 0
		&opfunc = matchstr(expand('<stack>'), '[^. ]*\ze[')
		return 'g@'
	endif
	if getline(nextnonblank(1) ?? 1) =~ '^\s*vim9script\s*$'
		vim9cmd :'[,']source
	else
		:'[,']source
	endif
	return ''
enddef

def Find(how = null_string, path = null_string)
	var mods: string
	if how == "s" && winwidth(winnr()) * 0.3 > winheight(winnr())
		mods = "vert "
	endif
	if empty(path)
		silent g:SetProjectRoot()
	else
		silent g:Lcd(path)
	endif
	feedkeys($":{mods}{how}find ", 'n')
enddef

export def LeaderNormal()
	g:undotree_SetFocusWhenToggle = true
	var find_commands = [
		{text: "Find in VIMRUNTIME", key: "r", close: true, cmd: (_) => Find("", $VIMRUNTIME)},
		{text: "Grep word under cursor", key: "w", close: true, cmd: "silent execute 'grep' expand('<cword>')"},
		{text: "Find in VIM config directory", key: "i", close: true, cmd: (_) => Find("", $MYVIMDIR)},
		{text: "Unicode search", key: "u", close: true, cmd: (_) => feedkeys(":Unicode ")},
		{text: "Change colorscheme", key: "c", close: true, cmd: (_) => feedkeys(":colorscheme ")},
		{text: "Load session", key: "s", close: true, cmd: (_) => feedkeys(":SLoad ")},
		{text: "Set filetype", key: "t", close: true, cmd: (_) => feedkeys(":set filetype=")},
		{text: "Set compiler", key: "m", close: true, cmd: (_) => feedkeys(":compiler ")},
	]
	var commands = [
		{text: "Toggle location list", key: "l", close: true, cmd: (_) => qf.ToggleLoc()},
		{text: "Toggle quickfix list", key: "q", close: true, cmd: (_) => qf.ToggleQF()},
		{text: "Toggle undotree", key: "u", close: true, cmd: "UndotreeToggle"},
		{text: "Window commands", key: "w", cmd: "<C-W>"},
		{text: "Source current vim file", key: "S", close: true, cmd: (_) => SourceVim()},
		{text: "Search in files", key: "/", close: true, cmd: 'exe $"Search {input("Search: ")}"'},
		{text: "Replace word under cursor", key: "%", close: true,
			cmd: (_) => feedkeys(":%s/\\<\<C-R>=expand(\"<cword>\")\<CR>\\>/\<C-R>=expand(\"<cword>\")\<CR>")},
		{text: "Navigate buffers", key: "n", close: true, cmd: (_) => qc.Nav()},
		{text: "Text transformations", key: "t", close: true, cmd: (_) => qc.TextTr()},
		{text: "Git commands", key: "g", close: true, cmd: (_) => qc.Git()},
		{text: "Occur search in buffer", key: "o", close: true, cmd: "execute 'Occur' expand('<cword>')"},
		{text: "Find in documents", key: "d", close: true, cmd: (_) => Find("", $DOCS ?? "~/docs")},
		{text: "Find files...", key: "f", close: true, cmd: (_) => {
			popup.Commands(find_commands)
		}},
		{text: "Recent files", key: "r", close: true, cmd: (_) => feedkeys(":Recent ")},
		{text: "Help topics", key: "h", close: true, cmd: (_) => feedkeys(":help ")},
		{text: "Switch buffers", key: "b", close: true, cmd: (_) => feedkeys(":buffer ")},
		{text: "Find in tabs", key: ";", close: true, cmd: (_) => Find("tab")},
		{text: "Find files (default)", key: " ", close: true, cmd: (_) => Find()},
		{text: "Toggle text wrap", key: "\<CR>", close: true, cmd: (_) => text.Toggle()},
	]
	popup.Commands(commands)
enddef

export def LeaderVisual()
	var commands = [
		{text: "Window commands", key: "w", cmd: "<C-W>"},
		{text: "Source current vim file", key: "S", close: true, cmd: (_) => SourceVim()},
		{text: "Text transformations", key: "t", close: true, cmd: (_) => qc.TextTr()},
		{text: "Git commands", key: "g", close: true, cmd: (_) => qc.Git()},
	]
	popup.Commands(commands)
enddef
