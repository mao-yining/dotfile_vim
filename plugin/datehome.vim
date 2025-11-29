vim9script

if !empty($SUDO_USER) && $USER !=# $SUDO_USER
	setglobal viminfo=
	setglobal directory-=~/tmp
	setglobal backupdir-=~/tmp
elseif exists("+undodir") && !has("nvim-0.5")
	if !empty($XDG_DATA_HOME)
		$DATA_HOME = substitute($XDG_DATA_HOME, "/$", "", "") . "/vim/"
	elseif has("win32")
		$DATA_HOME = expand("~/AppData/Local/vim/")
	else
		$DATA_HOME = expand("~/.local/share/vim/")
	endif
	&undodir   = $DATA_HOME .. "undo/"
	&directory = $DATA_HOME .. "swap/"
	&backupdir = $DATA_HOME .. "backup/"
	if !isdirectory(&undodir)   | mkdir(&undodir, "p")   | endif
	if !isdirectory(&directory) | mkdir(&directory, "p") | endif
	if !isdirectory(&backupdir) | mkdir(&backupdir, "p") | endif
endif

set undofile backup
