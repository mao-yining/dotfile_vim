vim9script

export def CmdReplace(cmd: string, ucmd: string): string
	return (getcmdtype() ==# ':' && getcmdline() ==# cmd) ? ucmd : cmd
enddef

export def Eatchar(pat: string): string
    var c = nr2char(getchar(0))
    return (c =~ pat) ? '' : c
enddef
