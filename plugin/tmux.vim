vim9script

# Add and uncomment following lines to your .tmux.conf:
# bind -n M-h if "[ $(tmux display -p '#{pane_current_command}') = vim ]" "send-keys M-h" "select-pane -L"
# bind -n M-j if "[ $(tmux display -p '#{pane_current_command}') = vim ]" "send-keys M-j" "select-pane -D"
# bind -n M-k if "[ $(tmux display -p '#{pane_current_command}') = vim ]" "send-keys M-k" "select-pane -U"
# bind -n M-l if "[ $(tmux display -p '#{pane_current_command}') = vim ]" "send-keys M-l" "select-pane -R"

if !has("gui_running")
	set <M-h>=h
	set <M-j>=j
	set <M-k>=k
	set <M-l>=l
endif

if empty($TMUX)
	noremap <M-h> <ScriptCmd>wincmd h<CR>
	noremap <M-j> <ScriptCmd>wincmd j<CR>
	noremap <M-k> <ScriptCmd>wincmd k<CR>
	noremap <M-l> <ScriptCmd>wincmd l<CR>
	inoremap <M-h> <Esc><ScriptCmd>wincmd h<CR>
	inoremap <M-j> <Esc><ScriptCmd>wincmd j<CR>
	inoremap <M-k> <Esc><ScriptCmd>wincmd k<CR>
	inoremap <M-l> <Esc><ScriptCmd>wincmd l<CR>
	tnoremap <M-h> <ScriptCmd>wincmd h<CR>
	tnoremap <M-j> <ScriptCmd>wincmd j<CR>
	tnoremap <M-k> <ScriptCmd>wincmd k<CR>
	tnoremap <M-l> <ScriptCmd>wincmd l<CR>
	finish
endif

var tmuxSocket = split($TMUX, ',')[0]

def TmuxCommand(cmd: string): string
	return trim(system($"tmux -S {tmuxSocket} {cmd}"))
enddef

def TmuxVimNavigate(direction: string)
	var winnr = winnr()
	exe "wincmd" direction
	if winnr == winnr() && TmuxCommand("display-message -p '#{window_zoomed_flag}'") != "1"
		TmuxCommand($'select-pane -{tr(direction, "hjkl", "LDUR")}')
	endif
enddef

noremap <M-h> <ScriptCmd>TmuxVimNavigate("h")<CR>
noremap <M-j> <ScriptCmd>TmuxVimNavigate("j")<CR>
noremap <M-k> <ScriptCmd>TmuxVimNavigate("k")<CR>
noremap <M-l> <ScriptCmd>TmuxVimNavigate("l")<CR>
inoremap <M-h> <Esc><ScriptCmd>TmuxVimNavigate("h")<CR>
inoremap <M-j> <Esc><ScriptCmd>TmuxVimNavigate("j")<CR>
inoremap <M-k> <Esc><ScriptCmd>TmuxVimNavigate("k")<CR>
inoremap <M-l> <Esc><ScriptCmd>TmuxVimNavigate("l")<CR>
tnoremap <M-h> <ScriptCmd>TmuxVimNavigate("h")<CR>
tnoremap <M-j> <ScriptCmd>TmuxVimNavigate("j")<CR>
tnoremap <M-k> <ScriptCmd>TmuxVimNavigate("k")<CR>
tnoremap <M-l> <ScriptCmd>TmuxVimNavigate("l")<CR>
