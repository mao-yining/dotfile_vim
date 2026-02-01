vim9script

if !empty($SUDO_USER) && $USER !=# $SUDO_USER
	setglobal viminfo=
	setglobal directory-=~/tmp
	setglobal backupdir-=~/tmp
elseif exists("+undodir") && !has("nvim-0.5")
	if !empty($XDG_DATA_HOME)
		$DATA_HOME = $XDG_DATA_HOME->substitute("/$", "", "") .. "/vim/"
	elseif has("win32")
		$DATA_HOME = expand("~/AppData/Local/vim/")
	else
		$DATA_HOME = expand("~/.local/share/vim/")
	endif
	&undodir   = $DATA_HOME .. "undo/"
	&directory = $DATA_HOME .. "swap/"
	&backupdir = $DATA_HOME .. "backup/"
	if !isdirectory(&undodir)   | &undodir->mkdir("p")   | endif
	if !isdirectory(&directory) | &directory->mkdir("p") | endif
	if !isdirectory(&backupdir) | &backupdir->mkdir("p") | endif
endif

set undofile backup
