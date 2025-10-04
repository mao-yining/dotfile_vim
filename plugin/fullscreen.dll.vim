vim9script noclear
# File: fullscreen.dll.vim
# Author: mao-yining
# Description: a plugin for transparency and fullscreen of gvim.
# gvim_fullscreen.dll is needed
# Last Modified: 2025-10-03

if !has('gui_running') || (!has('win32') && !has('win64'))
	finish
endif

if &cp || (exists('g:loaded_fullscreen_dll') && g:loaded_fullscreen_dll)
	finish
endif

g:loaded_fullscreen_dll = 1

var dll = get(g:, 'fullscreen_dll_path', '')
if empty(dll)
	dll = get(split(globpath(&rtp, has('win64') ? 'gvim_fullscreen.dll' : '32.dll'), '\n'), 0, '')
	if empty(dll)
		finish
	endif
endif

def ToggleFullscreen()
	libcall(dll, 'ToggleFullscreen', 0)
enddef

def ToggleTransparency()
	libcall(dll, 'ToggleTransparency', "200,255")
enddef

command -nargs=0 ToggleFullscreen call <SID>ToggleFullscreen()
command -nargs=0 ToggleTransparency call <SID>ToggleTransparency()
