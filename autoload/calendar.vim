vim9script
# Name: vimfiles\autoload\calendar.vim
# Author: Mao-Yining <mao.yining@outlook.com>
# Desc: A lightweight and extensible pure-Lua monthly calendar plugin for Vim,
#	featuring Vim-style navigation, customizable day highlights and marks.
# Derive From: wsdjeg's calendar.nvim <https://github.com/wsdjeg/calendar.nvim>
# Usage:
#	import autoload "calendar.vim"
#	command! -nargs=0 Calendar calendar.Open()
# Features:
# - Monthly calendar view in Vim
# - Vim-style keyboard navigation
# - Today highlighting and custom day highlights
# - Marked days support
# - Configurable setup and keymaps

if !exists("*strftime")
	echow '[calendar.vim]: This plugins require "*strftime" funcion'
	finish
endif

var config = {
	keymap: {
		next_month: 'L',
		previous_month: 'H',
		next_day: 'l',
		previous_day: 'h',
		next_week: 'j',
		previous_week: 'k',
		today: 't',
		close: 'q',
	},
	mark_icon: ' •',
	show_adjacent_days: true,
	highlights: {
		current: 'Visual',
		today: 'Todo',
		mark: 'Directory',
		adjacent_days: 'NonText',
	},
	borderchars: get(g:, "popup_borderchars", ['─', '│', '─', '│', '╭', '╮', '╯', '╰']),
	borderhighlight: get(g:, "popup_borderhighlight", ['VertSplit']),
	highlight: get(g:, "popup_highlight", 'Normal'),
	locale: 'zh-CN',
	locales: {
		'en-US': {
			months: [
				'January', 'February', 'March', 'April', 'May', 'June',
				'July', 'August', 'September', 'October', 'November', 'December'
			],
			weekdays: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
			year_month: (year: number, month: number, months: list<string>): string =>
				printf('%s %d', months[month - 1], year),
		},

		'de-DE': {
			months: [
				'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni',
				'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember'
			],
			weekdays: ['So', 'Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa'],
			year_month: (year: number, month: number, months: list<string>): string =>
				printf('%s %d', months[month - 1], year),
		},

		'en-GB': {
			months: [
				'January', 'February', 'March', 'April', 'May', 'June',
				'July', 'August', 'September', 'October', 'November', 'December'
			],
			weekdays: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
			year_month: (year: number, month: number, months: list<string>): string =>
				printf('%s %d', months[month - 1], year),
		},

		'es-ES': {
			months: [
				'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
				'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
			],
			weekdays: ['dom', 'lun', 'mar', 'mié', 'jue', 'vie', 'sáb'],
			year_month: (year: number, month: number, months: list<string>): string =>
				printf('%s %d', months[month - 1], year),
		},

		'fr-FR': {
			months: [
				'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
				'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
			],
			weekdays: ['dim', 'lun', 'mar', 'mer', 'jeu', 'ven', 'sam'],
			year_month: (year: number, month: number, months: list<string>): string =>
				printf('%s %d', months[month - 1], year),
		},

		'it-IT': {
			months: [
				'gennaio', 'febbraio', 'marzo', 'aprile', 'maggio', 'giugno',
				'luglio', 'agosto', 'settembre', 'ottobre', 'novembre', 'dicembre'
			],
			weekdays: ['dom', 'lun', 'mar', 'mer', 'gio', 'ven', 'sab'],
			year_month: (year: number, month: number, months: list<string>): string =>
				printf('%s %d', months[month - 1], year),
		},

		'ja-JP': {
			months: null_list,
			weekdays: ['日', '月', '火', '水', '木', '金', '土'],
			year_month: (year: number, month: number, _: list<string>): string =>
				printf('%04d 年 %2d 月', year, month),
		},

		'ko-KR': {
			months: [
				'1월', '2월', '3월', '4월', '5월', '6월',
				'7월', '8월', '9월', '10월', '11월', '12월'
			],
			weekdays: ['일', '월', '화', '수', '목', '금', '토'],
			year_month: (year: number, month: number, _: list<string>): string =>
				printf('%04d년 %2d월', year, month),
		},

		'zh-CN': {
			months: null_list,
			weekdays: ['日', '一', '二', '三', '四', '五', '六'],
			year_month: (year: number, month: number, _: list<string>): string =>
				printf('%04d 年 %2d 月', year, month),
		},

		'zh-TW': {
			months: null_list,
			weekdays: ['日', '一', '二', '三', '四', '五', '六'],
			year_month: (year: number, month: number, _: list<string>): string =>
				printf('%04d 年 %2d 月', year, month),
		},

		'ru-RU': {
			months: [
				'январь', 'февраль', 'март', 'апрель', 'май', 'июнь',
				'июль', 'август', 'сентябрь', 'октябрь', 'ноябрь', 'декабрь'
			],
			weekdays: ['вс', 'пн', 'вт', 'ср', 'чт', 'пт', 'сб'],
			year_month: (year: number, month: number, months: list<string>): string =>
				printf('%s %d г.', months[month - 1], year),
		},
	}
}
g:calendar_config = config->extend(get(g:, 'calendar_config', {}))

var buf: number
var win: number
var calendar: dict<any>

def IsLeapYear(year: number): bool
	if year % 400 == 0
		return true
	elseif year % 100 == 0
		return false
	else
		return year % 4 == 0
	endif
enddef

def GetMonthDays(year: number, month: number): number
	const month_days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
	if month == 2 && IsLeapYear(year)
		return 29
	else
		return month_days[month - 1]
	endif
enddef

def GetFirstWeekday(year: number, month: number): number
	# Use Zeller's congruence
	# https://en.wikipedia.org/wiki/Zeller%27s_congruence
	var y = year
	var m = month
	if m < 3
		y -= 1
		m += 12
	endif

	const K = y % 100
	const J = y / 100
	const Q = 1

	var h = (Q + ((13 * (m + 1)) / 5)->float2nr() + K + (K / 4)->float2nr()
		+ (J / 4)->float2nr() - 2 * J) % 7

	return (h + 6) % 7
enddef

def BuildMonthGrid(year: number, month: number, show_adjacent_days: bool = true): dict<list<string>>
	var grid: dict<list<string>>
	for i in range(6)
		grid[i] = []
		for j in range(7)
			grid[i]->add('   ')
		endfor
	endfor

	const start_col = GetFirstWeekday(year, month)
	const days = GetMonthDays(year, month)

	var row = 0
	var col = start_col

	if show_adjacent_days && start_col > 0
		var prev_month = month == 1 ? 12 : month - 1
		var prev_year = month == 1 ? year - 1 : year
		var prev_days = GetMonthDays(prev_year, prev_month)

		for i in range(start_col)
			grid[0][i] = printf('%3d', prev_days - start_col + 1 + i)
		endfor
	endif

	for i in range(1, days)
		grid[row][col] = printf('%3d', i)
		col += 1
		if col > 6
			col = 0
			row += 1
		endif
	endfor

	if show_adjacent_days
		for i in range(1, 42 - start_col - days)
			grid[row][col] = printf('%3d', i)
			col += 1
			if col > 6
				col = 0
				row += 1
			endif
		endfor
	endif

	calendar.days = days
	return grid
enddef

def AlignStr(str: string, width: number, align = 'left', fillchar = ' '): string
	var str_width = str->strdisplaywidth()

	if str_width >= width
		return str
	endif

	var padding = width - str_width

	if align == 'left'
		return str .. fillchar->repeat(padding)
	elseif align == 'right'
		return fillchar->repeat(padding) .. str
	elseif align == 'center'
		var left_pad = padding / 2
		var right_pad = padding - left_pad
		return fillchar->repeat(left_pad) .. str .. fillchar->repeat(right_pad)
	endif

	return str
enddef

def Center(str: string, width: number): string
	return AlignStr(str, width, 'center')
enddef

def Right(str: string, width: number): string
	return AlignStr(str, width, 'right')
enddef

def HighlightToday(year: number, month: number, grid: dict<list<string>>)
	if "%Y"->strftime()->str2nr() != year || "%m"->strftime()->str2nr() != month
		return
	endif
	var is_current_month: bool
	for [row, week] in items(grid)
		for [col, v] in items(week)
			var val = v->str2nr()
			if is_current_month && val == 1
				is_current_month = false
			elseif !is_current_month && val == 1
				is_current_month = true
			endif
			if is_current_month && val == "%d"->strftime()->str2nr()
				prop_add(str2nr(row) * 2 + 5, col * 4 + 5, {
					length: 2,
					bufnr: buf,
					type: 'calendar_today',
				})
				break
			endif
		endfor
	endfor
enddef

def SetMark(year: number, month: number, grid: dict<list<string>>)
	prop_remove({type: 'calendar_mark', bufnr: buf, all: true})

	var is_current_month = false
	for [row, week] in items(grid)
		for [col, v] in items(week)
			var val = v->str2nr()
			if is_current_month && val == 1
				is_current_month = false
			elseif !is_current_month && val == 1
				is_current_month = true
			endif
			if is_current_month && HasMarks(year, month, val)
				prop_add(str2nr(row) * 2 + 6, col + 2, {
					bufnr: buf,
					text: config.mark_icon,
					type: 'calendar_mark',
				})
			endif
		endfor
	endfor
enddef

def HighlightAdjacentDays(grid: dict<list<string>>)
	prop_remove({type: 'calendar_adjacent', bufnr: buf, all: true})

	var is_current_month = false

	for [row, week] in items(grid)
		for [col, v] in items(week)
			var val = v->str2nr()
			if is_current_month && val == 1
				is_current_month = false
			elseif !is_current_month && val == 1
				is_current_month = true
			endif
			if !is_current_month
				prop_add(str2nr(row) * 2 + 5, col * 4 + 5, {
					length: 2,
					bufnr: buf,
					type: 'calendar_adjacent',
				})
			endif
		endfor
	endfor
enddef

def RenderLines(year: number, month: number, grid: dict<list<string>>): list<string>
	var locale_data = config.locales[config.locale]
	var lines: list<string>
	var CALENDAR_WIDTH = 34
	var WEEKDAY_WIDTH = 3

	var months = locale_data.months
	var year_month = locale_data.year_month(year, month, months)
	lines->add(Center(year_month, CALENDAR_WIDTH))
	lines->add('')

	var weekdays: list<string>
	for weekday in locale_data.weekdays
		weekdays->add(Right(weekday, WEEKDAY_WIDTH))
	endfor
	lines->add(Center(weekdays->join(' '), CALENDAR_WIDTH))
	lines->add('')

	for week in grid->values()
		lines->add('   ' .. (week->join(' ')) .. '    ')
		lines->add("\t\t\t\t\t\t\t\t")
	endfor

	return lines
enddef

export def Open(year = strftime("%Y")->str2nr(), month = strftime("%m")->str2nr(), day = strftime("%d")->str2nr())
	calendar.year = year
	calendar.month = month
	calendar.day = day
	calendar.grid = BuildMonthGrid(year, month)

	const lines = RenderLines(year, month, calendar.grid)

	if buf == 0 || !bufexists(buf)
		buf = bufadd('Calendar')
		setbufvar(buf, '&buftype', 'nofile')
		setbufvar(buf, '&bufhidden', 'hide')
		setbufvar(buf, '&swapfile', false)
		setbufvar(buf, '&tabstop', 4)
		if 'calendar_current'->prop_type_get({bufnr: buf})->empty()
			prop_type_add('calendar_today', {
				bufnr: buf, highlight: config.highlights.today })
			prop_type_add('calendar_mark', {
				bufnr: buf, highlight: config.highlights.mark })
			prop_type_add('calendar_adjacent', {
				bufnr: buf, highlight: config.highlights.adjacent_days })
			prop_type_add('calendar_current', {
				bufnr: buf, highlight: config.highlights.current, })
		endif
	endif

	# Set buffer content
	setbufvar(buf, '&modifiable', true)
	bufload(buf)
	setbufline(buf, 1, lines)
	setbufvar(buf, '&modifiable', false)

	if popup_show(win) == 0 # Has Popup Show
		HighlightToday(year, month, calendar.grid)
		HighlightDay(day)
		return
	endif

	win = buf->popup_create({
		border: null_list,
		borderchars: config.borderchars,
		borderhighlight: config.borderhighlight,
		highlight: config.highlight,
		mapping: false,
		zindex: 49,
		filter: (_, key) => {
			def PreviousMonth()
				const new_month = calendar.month == 1 ? 12 : calendar.month - 1
				const new_year = calendar.month == 1 ? calendar.year - 1 : calendar.year
				Open(new_year, new_month)
			enddef
			def NextMonth()
				const new_month = calendar.month == 12 ? 1 : calendar.month + 1
				const new_year = calendar.month == 12 ? calendar.year + 1 : calendar.year
				Open(new_year, new_month)
			enddef
			if key == config.keymap.previous_month
				PreviousMonth()
			elseif key == config.keymap.next_month
				NextMonth()
			elseif key == config.keymap.previous_day
				if calendar.day > 1
					calendar.day -= 1
					HighlightDay(calendar.day)
				else
					PreviousMonth()
					calendar.day = calendar.days
					HighlightDay(calendar.day)
				endif
			elseif key == config.keymap.next_day
				if calendar.day < calendar.days
					calendar.day += 1
				else
					NextMonth()
					calendar.day = 1
				endif
				HighlightDay(calendar.day)
			elseif key == config.keymap.previous_week
				if calendar.day <= 7
					const new_day = 7 - calendar.day
					PreviousMonth()
					calendar.day = calendar.days - new_day
				else
					calendar.day -= 7
				endif
				HighlightDay(calendar.day)
			elseif key == config.keymap.next_week
				if calendar.day + 7 > calendar.days
					var new_day = calendar.day + 7 - calendar.days
					NextMonth()
					calendar.day = new_day
				else
					calendar.day += 7
				endif
				HighlightDay(calendar.day)
			elseif key == config.keymap.today
				Open()
			elseif key == config.keymap.close
				Close()
			elseif key == "\<ESC>"
				Close()
			elseif key == "\<LeftMouse>"
				const pos = getmousepos()
				if pos.winid == win
					if pos.line > 3
						var new_day = calendar.grid->get((pos.line - 5) / 2)
							->get((pos.column - 4) / 4)
						if type(new_day) == v:t_string
							new_day = new_day->str2nr()
							if pos.line == 4 && new_day < 7
								PreviousMonth()
							elseif pos.line > 11 && new_day > 15
								NextMonth()
							endif
							calendar.day = new_day
							HighlightDay(new_day)
						endif
					endif
				else
					return false
				endif
			elseif key == "\<Enter>"
				OnAction(calendar.year, calendar.month, calendar.day)
			endif
			return true
		}
	})
	HighlightToday(year, month, calendar.grid)
	OnChange(year, month)
	HighlightDay(day)
enddef

export def Close()
	popup_close(win)
enddef

def HighlightDay(day_num: number)
	prop_remove({type: 'calendar_current', bufnr: buf, all: true})

	var is_current_month = false
	for [row, week] in items(calendar.grid)
		if !(type(week) == v:t_list)
			continue
		endif
		for [col, v] in items(week)
			var val = v->str2nr()
			if is_current_month && val == 1
				is_current_month = false
			elseif !is_current_month && val == 1
				is_current_month = true
			endif
			if is_current_month && val == day_num
				prop_add(str2nr(row) * 2 + 5, col * 4 + 4, {
					length: 4,
					bufnr: buf,
					type: 'calendar_current',
				})
			endif
		endfor
	endfor
	SetMark(calendar.year, calendar.month, calendar.grid)
	if config.show_adjacent_days
		HighlightAdjacentDays(calendar.grid)
	endif
enddef

var extensions = {}
var marked_days = {}
# Journal Ext{{{
import autoload "notebook.vim"
def Get(year: number, month: number): list<dict<any>>
	var notes = notebook.GetNotes()
	var marks: list<dict<any>> = []

	for note in notes
		var id_parts = split(note.id, '-')
		if len(id_parts) >= 3
			var note_year = id_parts[0]->str2nr()
			var note_month = id_parts[1]->str2nr()
			var note_day = id_parts[2]->str2nr()
			if note_year == year && note_month == month
				marks->add({
					year: note_year,
					month: note_month,
					day: note_day,
				})
			endif
		endif
	endfor
	return marks
enddef

def OpenDailyNote(year: number, month: number, day: number)
	Close()
	notebook.NewNote({date: {year: year, month: month, day: day}})
enddef

const journals = {
	get: Get,
	actions: {
		open_daily_note: OpenDailyNote,
	}
} # }}}

import autoload "popup.vim"
def GetCalendarExts(): dict<dict<any>>
	return {journals: journals}
enddef

def HasMarks(year: number, month: number, day: number): bool
	return marked_days->has_key(printf('%4d-%2d-%2d', year, month, day))
enddef

def Mark(year: number, month: number, day: number)
	marked_days[printf('%4d-%2d-%2d', year, month, day)] = true
enddef

export def Register(name: string, ext: dict<any>)
	extensions[name] = ext
enddef

def OnChange(year: number, month: number)
	extensions->extend(GetCalendarExts())
	for ext in extensions->values()
		for mark in ext.get(year, month)
			Mark(mark.year, mark.month, mark.day)
		endfor
	endfor
enddef

def OnAction(year: number, month: number, day: number)
	var actions: list<dict<any>>
	for [extension, ext] in items(extensions)
		for [action, callback] in items(ext.actions)
			actions->add({
				text: extension .. '/' .. action,
				callback: callback,
				date: { year: year, month: month, day: day },
			})
		endfor
	endfor
	if empty(actions)
		return
	endif
	if len(actions) == 1
		const res = actions[0]
		res.callback(res.date.year, res.date.month, res.date.day)
	elseif len(actions) < 5
		popup_menu(actions->mapnew((_, v) => v.text), {
			borderchars: config.borderchars,
			borderhighlight: config.borderhighlight,
			highlight: config.highlight,
			callback: (_, result) => {
				if result > 0
					const res = actions[result - 1]
					res.callback(res.date.year, res.date.month, res.date.day)
				endif
			}
		})
	else
		popup.Select("calendar actions", actions,
			(res, key) => {
				res.callback(res.date.year, res.date.month, res.date.day)
			})
	endif
enddef
command! -nargs=0 Calendar Open()
map <buffer><F5> <Cmd>so<CR><Cmd>Calendar<CR>
# vim:fdm=marker
