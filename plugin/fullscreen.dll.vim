scriptencoding utf-8

if !has('gui_running') || (!has('win32') && !has('win64'))
  finish
endif

if &cp || (exists('g:loaded_fullscreen_dll') && g:loaded_fullscreen_dll)
  finish
endif

let g:loaded_fullscreen_dll = 1

let s:dll = get(g:, 'fullscreen_dll_path', '')
if empty(s:dll)
  let s:dll = get(split(globpath(&rtp, has('win64') ? 'gvim_fullscreen.dll' : '32.dll'), '\n'), 0, '')
  if empty(s:dll)
    finish
  endif
endif

function! s:ToggleFullscreen()
  call libcallnr(s:dll, 'ToggleFullscreen', 0)
endfunction

function! s:ToggleTransparency()
  call libcallnr(s:dll, 'ToggleTransparency', "200,255")
endfunction

command! -nargs=0 ToggleFullscreen call <SID>ToggleFullscreen()
command! -nargs=0 ToggleTransparency call <SID>ToggleTransparency()
