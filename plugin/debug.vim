vim9script

def SetTermdebugMappings()
	nmap <nowait> <LocalLeader>g <Cmd>Gdb<CR>
	nmap <nowait> <LocalLeader>p <Cmd>Program<CR>
	nmap <nowait> <LocalLeader>s <Cmd>Source<CR>
	nmap <nowait> <LocalLeader>a <Cmd>Asm<CR>
	nmap <nowait> <LocalLeader>v <Cmd>Var<CR>
	nmap <nowait> <F3> <Cmd>ToggleBreak<CR>
	nmap <nowait> <F5> <Cmd>RunOrContinue<CR>
	nmap <nowait> <LocalLeader><F5> <Cmd>Stop<CR>
	nmap <nowait> <Leader><F5> <Cmd>Run<CR>
	nmap <nowait> <F6> <Cmd>Step<CR>
	nmap <nowait> <F7> <Cmd>Over<CR>
	nmap <nowait> <F8> <Cmd>Finish<CR>
	setlocal complete=
enddef

def ResetTermdebugMappings()
	nunmap <LocalLeader>g
	nunmap <LocalLeader>p
	nunmap <LocalLeader>s
	nunmap <LocalLeader>a
	nunmap <LocalLeader>v
	map    <F3> <Plug>VimspectorToggleBreakpoint
	nmap   <F5> <Plug>VimspectorContinue
	nunmap <LocalLeader><F5>
	nunmap <Leader><F5>
	nunmap <F6>
	nmap   <F7> <Cmd>AsyncTask file-run<CR>
	nmap   <F8> <Cmd>AsyncTask file-build<CR>
enddef

if has('python3') && !"vimspector"->getcompletion("packadd")->empty()
	packadd vimspector
	g:vimspector_install_gadgets = [ "debugpy", "vscode-cpptools", "CodeLLDB" ]
	nmap <F5>          <Plug>VimspectorContinue
	nmap <F3>          <Plug>VimspectorToggleBreakpoint
	nmap <Leader><F3>  <Plug>VimspectorRunToCursor
	nmap <F4>          <Plug>VimspectorAddFunctionBreakpoint
	nmap <Leader><F4>  <Plug>VimspectorToggleConditionalBreakpoint
	g:vimspector_enable_winbar = 0
	def SetVimspectorMappings()
		if exists("<Leader><F5>")|nunmap <Leader><F5>|endif
		if exists("<F6>")|nunmap <F6>|endif
		nmap <F7> <Cmd>AsyncTask file-run<CR>
		nmap <F8> <Cmd>AsyncTask file-build<CR>
		nmap <F9> <Cmd>AsyncTask project-run<CR>
		nmap <F10> <Cmd>AsyncTask project-build<CR>
		if exists("<Leader><F11>")|nunmap <Leader><F11>|endif
		if exists("<Leader><F12>")|nunmap <Leader><F12>|endif
		if exists("<Leader>B")|nunmap <Leader>B|endif
		if exists("<Leader>D")|nunmap <Leader>D|endif
	enddef
	def ResetVimspectorMappings()
		nmap <Leader><F5>  <Plug>VimspectorStop
		nmap <F6>          <Plug>VimspectorStepOver
		nmap <F7>          <Plug>VimspectorStepInto
		nmap <F8>          <Plug>VimspectorStepOut
		nmap <F9>          <Plug>VimspectorPause
		nmap <F10>         <Plug>VimspectorRestart
		nmap <Leader><F11> <Plug>VimspectorUpFrame
		nmap <Leader><F12> <Plug>VimspectorDownFrame
		nmap <Leader>B     <Plug>VimspectorBreakpoints
		nmap <Leader>D     <Plug>VimspectorDisassemble
	enddef
	ResetVimspectorMappings()
endif

augroup debug | au!
	autocmd User TermdebugStartPost SetTermdebugMappings()
	autocmd User TermdebugStopPost ResetTermdebugMappings()

	autocmd User VimspectorDebugEnded SetVimspectorMappings()
	autocmd User VimspectorUICreated ResetVimspectorMappings()
augroup end
