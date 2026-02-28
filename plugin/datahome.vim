vim9script
if !empty($XDG_DATA_HOME)
	$DATA_HOME = $XDG_DATA_HOME->trim("/", 2) .. "/vim/"
elseif has("win32")
	$DATA_HOME = expand("~/AppData/Local/vim/")
else
	$DATA_HOME = expand("~/.local/share/vim/")
endif
&undodir   = $DATA_HOME .. "undo/"
&directory = $DATA_HOME .. "swap/"
&backupdir = $DATA_HOME .. "backup/"
if !isdirectory(&undodir)   | &undodir->mkdir('p', 0700)   | endif
if !isdirectory(&directory) | &directory->mkdir('p', 0700) | endif
if !isdirectory(&backupdir) | &backupdir->mkdir('p', 0700) | endif
set backup undofile
