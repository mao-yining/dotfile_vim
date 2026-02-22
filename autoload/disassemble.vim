vim9script
# Name: autoload\disassemble.vim
# Author: Yegappan Lakshmanan (yegappan AT yahoo DOT com)
# Version: 2.1
# Convert To Vim9: Mao-Yining <mao.yining@outlook.com>
# Desc: Script to display the disassembled code using objdump. Assumes the
# objdump utility is present in $PATH
# Usage:
# import autoload "disassemble.vim"
# command! -nargs=* -complete=file ObjDump disassemble.Disassemble(<q-mods>, <q-args>)
#
# This plugin assumes that you have already compiled a source file into an
# object file or an executable. This plugin uses the objdump utility to
# disassemble the object file.
#
# To display the disassembled code of the current file, use the following
# command:
#
#	:Disassemble
#
# To display the disassembled code of any other file, supply the file name to
# the following command:
#
#	:Disassemble <filename>
#
# e.g.
#
#	:Disassemble myfile.c
#	:Disassemble myexecutable
#	:Disassemble comp.o

# Path to the objdump utility
const objdump = 'objdump'

def ErrorMsg(msg: string)
	echohl ErrorMsg
	echomsg '[markdown.vim]' msg
	echohl None
enddef

# Display the disassembled code for a specified file
export def Disassemble(cmdmods: string, arg: string)
	# Make sure objdump is present in the path
	if !executable(objdump)
		ErrorMsg($'{objdump} utility is not present')
		return
	endif

	var fname: string
	if arg != null_string
		# use the user supplied file name
		fname = arg
	else
		# default is to use the current file name
		fname = expand('%')
		if fname == null_string
			# No current file (empty buffer)
			return
		endif
	endif

	# Make sure the file is present
	var f = fname->findfile('**')
	if f == null_string || !filereadable(f)
		ErrorMsg($"File '{fname}' is not found")
		return
	endif
	fname = f

	# Find the object file for the specified file
	var objname = fname->fnamemodify(':r')
	# First recursively search for an executable with this name
	f = objname->findfile('**')
	if f == null_string
		# If not present, then recursively search for an object file by adding
		# an .o extension
		objname ..= '.o'
		f = objname->findfile('**')
		if f == null_string
			ErrorMsg($"File '{objname}' is not found")
			return
		endif
		objname = f
	endif

	const bname = $'\[Disassembly - {fname}\]'
	var winnr = bufwinnr(bname)
	if winnr != -1
		# Buffer is already present in a window. Use that window
		exe $':{winnr}wincmd w'
	else
		# Create a new window
		exe $'{cmdmods} new {bname}'
	endif
	setlocal modifiable
	system($'{objdump} -C -l -S --no-show-raw-insn -d {objname}')->split("\n")->setline(1)
	setlocal nomodified nomodifiable filetype=asm buftype=nofile bufhidden=wipe

	# create folds
	setlocal foldmethod=manual
	setlocal foldenable foldcolumn=1
	global/^\x\+ /:.+1,/^$/fold
	normal zR
	normal! gg
enddef
