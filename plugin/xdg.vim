vim9script
# only data directory
if !empty($SUDO_USER) && $USER !=# $SUDO_USER
	setglobal viminfo=
	setglobal directory-=~/tmp
	setglobal backupdir-=~/tmp
elseif exists("+undodir")
	def MkDir(dir: string): string
		if !isdirectory(dir)
			dir->mkdir('p', 0700)
		endif
		return dir
	enddef
	if !empty($XDG_DATA_HOME)
		$DATA_HOME = $XDG_DATA_HOME->trim("/", 2) .. "/vim/"
	elseif has("win32")
		$DATA_HOME = expand("~/AppData/Local/vim/")
	else
		$DATA_HOME = expand("~/.local/share/vim/")
	endif
	&undodir   = MkDir($DATA_HOME .. "undo/")
	&directory = MkDir($DATA_HOME .. "swap/")
	&backupdir = MkDir($DATA_HOME .. "backup/")
	set undofile
endif
set backup
