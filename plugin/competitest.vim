vim9script noclear
# Vim global plugin for competitive programing
# Last Change:	2025 Feb 10
# Maintainer:	毛同学 <stu_mao@outlook.com>
# License:	This file is placed in the public domain.

if exists("g:loaded_competitest")
  finish
endif
g:loaded_competitest = 1

def Add_testcase()
enddef

def Edit_testcase(case: number = -1)
enddef

def Delete_testcase(case: number = -1)
enddef

# Support many programing languages
# Handle compilation if needed
# Run multiple testcases at the same time
#   Run again processes
#   Kill processes
# Display results and execution data in a popup UI
# Display results and execution data in a split window UI
def Run()
  ShowUI()
  
enddef

def RunNoCompile()
enddef

def ShowUI()
enddef

# Integration with [competitive-companion](https://github.com/jmerle/competitive-companion)
#   Download testcases
#   Download problems
#   Download contests
#   Customizable folder structure for downloaded problems and contests
def Receive()
enddef

def SetupHighlightGroups()
  hi! CompetiTestDone cterm=none gui=none
  hi! CompetiTestCorrect ctermfg=green guifg=#00ff00
  hi! CompetiTestWarning ctermfg=yellow guifg=orange
  hi! CompetiTestWrong ctermfg=red guifg=#ff0000
  hi! CompetiTestRunning cterm=bold gui=bold
enddef
# def ResizeUI()
  # ResizeWigets()
  # # for
	# # vim.schedule(function()
	# # 	require("competitest.widgets").resize_widgets()
	# # 	for _, r in pairs(require("competitest.commands").runners) do
	# # 		r:resize_ui()
	# # 	end
	# # end)
# enddef

autocmd ColorScheme * SetupHighlightGroups()
# resize ui autocommand
# autocmd VimResized * ResizeUI()

command! -bang -nargs=? -range=-1 -complete=customlist,CommandCompletion CompetiTest exe fugitive#Command(<line1>, <count>, +"<range>", <bang>0, "<mods>", <q-args>)

command! -nargs=* -complete=custom,CommandCompletion CompetiTest 
