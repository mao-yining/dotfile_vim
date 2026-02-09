vim9script
# Name: autoload/recordkey.vim
# Author: Mao-Yining <mao.yining@outlook.com>
# Desc: A plugin that displays recent keystrokes in floating windows to help
# users track their typing. It shows the last few keys pressed and can group
# repeated keys with a counter.
# Derive From: wsdjeg's record-key.nvim <https://github.com/wsdjeg/record-key.nvim>
# Usage:
# import autoload "recordkey.vim"
# command! RecordKeyToggle recordkey.Toggle()

const default_config = {
	timeout: 2000,
	max_count: 5,
	borderchars: get(g:, "popup_borderchars", ['─', '│', '─', '│', '┌', '┐', '┘', '└']),
	highlight: get(g:, "popup_highlight", 'Normal'),
	borderhighlight: get(g:, "popup_borderhighlight", ['VertSplit']),
	while_list: [
			"<CR>",
			"<Tab>",
			"<Esc>",
		],
}
g:recordkey_config = get(g:, 'recordkey_config', {})->extend(default_config, 'keep')
var config = g:recordkey_config

var keys: list<string>
var win: number
var enabled: bool
var timer: number

def Start()
	if popup_show(win) == 0
		return
	endif
	var w = 8
	win = popup_create(keys, {
		title: " Recording Keys",
		minwidth: w,
		col: &columns,
		line:  &lines,
		zindex: 100,
		padding: [0, 1, 0, 1],
		border: [1, 1, 1, 1],
		tabpage: -1,
		mapping: false,
		borderchars: config.borderchars,
		borderhighlight: config.borderhighlight,
		highlight: config.highlight,
		filter: OnKey
	})
enddef

export def Stop()
	popup_hide(win)
	keys = null_list
enddef

def Display()
	win->popup_settext(keys)
enddef
def OnKey(_, key: string): bool
	var k = keytrans(key)
	if key !~ '\P' || key == "\<CursorHold>"
		return false
	endif
	if len(keys) > 0
		var last_key = keys[-1]
		if last_key =~ '×\d*$'
			var base_key = substitute(last_key, '×\d*$', '', 'g')
			if base_key == k
				timer_stop(timer)
				var count_str = matchstr(last_key, '\d*$')
				var count = str2nr(count_str) + 1
				keys[-1] = k .. '×' .. count
				Display()
				return false
			endif
		elseif last_key == k
			timer_stop(timer)
			keys[-1] = k .. '×2'
			Display()
			return false
		endif
	endif

	keys->add(k)

	timer = timer_start(config.timeout, (_) => {
		if len(keys) > 0
			keys->remove(0)
		endif
	})
	Display()
	return false
enddef

export def Toggle()
	if enabled
		Stop()
		enabled = false
	else
		Start()
		enabled = true
	endif
enddef
