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

g:calendar_config = {
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
	highlights: {
		current: 'Visual',
		today: 'Todo',
		mark: 'Directory',
		adjacent: 'NonText',
	},
	borderchars: get(g:, "popup_borderchars", ['─', '│', '─', '│', '╭', '╮', '╯', '╰']),
	borderhighlight: get(g:, "popup_borderhighlight", ['VertSplit']),
	highlight: get(g:, "popup_highlight", 'Normal'),
	locale: v:lang,
	locales: {
		'en_US': {
			months: [
				'January', 'February', 'March', 'April', 'May', 'June',
				'July', 'August', 'September', 'October', 'November', 'December'
			],
			weekdays: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
			year_month: (year: number, month: number, months: list<string>): string =>
				printf('%s %d', months[month - 1], year),
		},

		'de_DE': {
			months: [
				'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni',
				'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember'
			],
			weekdays: ['So', 'Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa'],
			year_month: (year: number, month: number, months: list<string>): string =>
				printf('%s %d', months[month - 1], year),
		},

		'en_GB': {
			months: [
				'January', 'February', 'March', 'April', 'May', 'June',
				'July', 'August', 'September', 'October', 'November', 'December'
			],
			weekdays: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
			year_month: (year: number, month: number, months: list<string>): string =>
				printf('%s %d', months[month - 1], year),
		},

		'es_ES': {
			months: [
				'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
				'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
			],
			weekdays: ['dom', 'lun', 'mar', 'mié', 'jue', 'vie', 'sáb'],
			year_month: (year: number, month: number, months: list<string>): string =>
				printf('%s %d', months[month - 1], year),
		},

		'fr_FR': {
			months: [
				'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
				'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
			],
			weekdays: ['dim', 'lun', 'mar', 'mer', 'jeu', 'ven', 'sam'],
			year_month: (year: number, month: number, months: list<string>): string =>
				printf('%s %d', months[month - 1], year),
		},

		'it_IT': {
			months: [
				'gennaio', 'febbraio', 'marzo', 'aprile', 'maggio', 'giugno',
				'luglio', 'agosto', 'settembre', 'ottobre', 'novembre', 'dicembre'
			],
			weekdays: ['dom', 'lun', 'mar', 'mer', 'gio', 'ven', 'sab'],
			year_month: (year: number, month: number, months: list<string>): string =>
				printf('%s %d', months[month - 1], year),
		},

		'ja_JP': {
			months: null_list,
			weekdays: ['日', '月', '火', '水', '木', '金', '土'],
			year_month: (year: number, month: number, _: list<string>): string =>
				printf('%04d 年 %2d 月', year, month),
		},

		'ko_KR': {
			months: [
				'1월', '2월', '3월', '4월', '5월', '6월',
				'7월', '8월', '9월', '10월', '11월', '12월'
			],
			weekdays: ['일', '월', '화', '수', '목', '금', '토'],
			year_month: (year: number, month: number, _: list<string>): string =>
				printf('%04d년 %2d월', year, month),
		},

		'zh_CN': {
			months: null_list,
			weekdays: ['日', '一', '二', '三', '四', '五', '六'],
			year_month: (year: number, month: number, _: list<string>): string =>
				printf('%04d 年 %2d 月', year, month),
		},

		'zh_TW': {
			months: null_list,
			weekdays: ['日', '一', '二', '三', '四', '五', '六'],
			year_month: (year: number, month: number, _: list<string>): string =>
				printf('%04d 年 %2d 月', year, month),
		},

		'ru_RU': {
			months: [
				'январь', 'февраль', 'март', 'апрель', 'май', 'июнь',
				'июль', 'август', 'сентябрь', 'октябрь', 'ноябрь', 'декабрь'
			],
			weekdays: ['вс', 'пн', 'вт', 'ср', 'чт', 'пт', 'сб'],
			year_month: (year: number, month: number, months: list<string>): string =>
				printf('%s %d г.', months[month - 1], year),
		},
	}
}->extend(get(g:, 'calendar_config', {}))

var config = g:calendar_config
var buf: number
var win: number

type Grid = list<list<number>>
class Calendar
	var year  = str2nr(strftime("%Y"))
	var month = str2nr(strftime("%m"))
	var day   = str2nr(strftime("%d"))
	var days: number
	var grid: Grid
	var localtime = localtime()
	def Refresh()
		const month = this.month
		this.year  = str2nr(strftime("%Y", this.localtime))
		this.month = str2nr(strftime("%m", this.localtime))
		this.day   = str2nr(strftime("%d", this.localtime))
		if month != this.month
			this.GridUpdate()
			Open()
		endif
	enddef
	def DayPrev(n = 1)
		this.localtime -= 86400 * n
		this.Refresh()
	enddef
	def DayNext(n = 1)
		this.localtime += 86400 * n
		this.Refresh()
	enddef
	def MonthPrev()
		this.DayPrev(this.GetMonthDays(
			this.month == 1 ? this.year - 1 : this.year,
			this.month == 1 ? 12 : this.month - 1))
	enddef
	def MonthNext()
		this.DayNext(this.days)
	enddef
	def new()
		for i in range(6)
			this.grid[i] = [0]->repeat(7)
		endfor
		this.GridUpdate()
	enddef
	def Today()
		this.localtime = localtime()
		this.Refresh()
	enddef
	def GridUpdate()
		const start_col = this.GetFirstWeekday(this.year, this.month)
		this.days = this.GetMonthDays(this.year, this.month)

		var row = 0
		var col = start_col

		if start_col > 0
			var prev_month = this.month == 1 ? 12 : this.month - 1
			var prev_year = this.month == 1 ? this.year - 1 : this.year
			var prev_days = this.GetMonthDays(prev_year, prev_month)

			for i in range(start_col)
				this.grid[0][i] = prev_days - start_col + 1 + i
			endfor
		endif

		for i in range(1, this.days)
			this.grid[row][col] = i
			col += 1
			if col > 6
				col = 0
				row += 1
			endif
		endfor

		for i in range(1, 42 - start_col - this.days)
			this.grid[row][col] = i
			col += 1
			if col > 6
				col = 0
				row += 1
			endif
		endfor
	enddef
	def IsLeapYear(year: number): bool
		return (year % 100 != 0 && year % 4 == 0) || year % 400 == 0
	enddef

	def GetMonthDays(year: number, month: number): number
		const month_days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
		return month == 2 && this.IsLeapYear(year) ? 29 : month_days[month - 1]
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

		const h = (Q + ((13 * (m + 1)) / 5)->float2nr() + K
			+ (K / 4)->float2nr() + (J / 4)->float2nr() - 2 * J) % 7

		return (h + 6) % 7
	enddef
endclass
var calendar = Calendar.new()

def AlignStr(str: string, width: number, align = 'left', fillchar = ' '): string
	const str_width = str->strdisplaywidth()

	if str_width >= width
		return str
	endif

	const padding = width - str_width

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

def RenderLines(year: number, month: number, grid: Grid): list<string>
	const locale_data = config.locales[config.locale]
	const year_month = locale_data.year_month(year, month, locale_data.months)
	const weekdays = locale_data.weekdays

	var lines: list<string>
	lines->add(Center(year_month, 34))
	lines->add('')
	lines->add(Center(weekdays->mapnew((_, v) => Right(v, 3))->join(' '), 34))
	lines->add('')
	for week in grid
		lines->add($'   {week->mapnew((_, v) => v->printf('%3d'))->join(' ')}    ')
		lines->add(repeat("\t", 8))
	endfor

	return lines
enddef

def HighlightDay(day_num: number)
	prop_remove({type: 'current', bufnr: buf})
	var is_current_month = false
	for [row, week] in items(calendar.grid)
		for [col, val] in items(week)
			if is_current_month && val == 1
				is_current_month = false
			elseif !is_current_month && val == 1
				is_current_month = true
			endif
			if is_current_month && val == day_num
				prop_add(row * 2 + 5, col * 4 + 4, {
					length: 4,
					bufnr: buf,
					type: 'current',
				})
				return
			endif
		endfor
	endfor
enddef

def HighlightToday(year: number, month: number, grid: Grid)
	if "%Y"->strftime()->str2nr() != year || "%m"->strftime()->str2nr() != month
		return
	endif
	var is_current_month: bool
	for [row, week] in items(grid)
		for [col, val] in items(week)
			if is_current_month && val == 1
				is_current_month = false
			elseif !is_current_month && val == 1
				is_current_month = true
			endif
			if is_current_month && val == "%d"->strftime()->str2nr()
				prop_add(row * 2 + 5, col * 4 + 5, {
					length: 2,
					bufnr: buf,
					type: 'today',
				})
				return
			endif
		endfor
	endfor
enddef

def SetMark(year: number, month: number, grid: Grid)
	var is_current_month = false
	for [row, week] in items(grid)
		for [col, val] in items(week)
			if is_current_month && val == 1
				is_current_month = false
			elseif !is_current_month && val == 1
				is_current_month = true
			endif
			if is_current_month && HasMarks(year, month, val)
				prop_add(row * 2 + 6, col + 2, {
					bufnr: buf,
					text: config.mark_icon,
					type: 'mark',
				})
			endif
		endfor
	endfor
enddef

def HighlightAdjacentDays(grid: Grid)
	var is_current_month = false
	for [row, week] in items(grid)
		for [col, val] in items(week)
			if is_current_month && val == 1
				is_current_month = false
			elseif !is_current_month && val == 1
				is_current_month = true
			endif
			if !is_current_month
				prop_add(row * 2 + 5, col * 4 + 5, {
					length: 2,
					bufnr: buf,
					type: 'adjacent',
				})
			endif
		endfor
	endfor
enddef

export def Open()
	const popup_opts = {
		border: null_list,
		borderchars: config.borderchars,
		borderhighlight: config.borderhighlight,
		highlight: config.highlight,
		mapping: false,
		zindex: 49,
		filter: (_, key) => {
			if key == config.keymap.previous_month || key == "\<ScrollWheelUp>"
				calendar.MonthPrev()
			elseif key == config.keymap.next_month || key == "\<ScrollWheelDown>"
				calendar.MonthNext()
			elseif key == config.keymap.previous_day
				calendar.DayPrev()
				HighlightDay(calendar.day)
			elseif key == config.keymap.next_day
				calendar.DayNext()
				HighlightDay(calendar.day)
			elseif key == config.keymap.previous_week
				calendar.DayPrev(7)
				HighlightDay(calendar.day)
			elseif key == config.keymap.next_week
				calendar.DayNext(7)
				HighlightDay(calendar.day)
			elseif key == config.keymap.today
				calendar.Today()
			elseif key == config.keymap.close || key == "\<ESC>"
				Close()
			elseif key == "\<LeftMouse>"
				const pos = getmousepos()
				if pos.winid == win && pos.line > 3 && (pos.line - 3) % 2 == 0
					var new_day = calendar.grid->get((pos.line - 3) / 2 - 1)
						->get((pos.column - 4) / 4)
					if type(new_day) == v:t_string
						new_day = new_day->str2nr()
						OnAction(calendar.year, calendar.month, new_day)
					endif
				endif
			elseif key == "\<Enter>"
				OnAction(calendar.year, calendar.month, calendar.day)
			endif
			return true
		}
	}

	if popup_show(win) == -1 # Has Popup Show
		win = RenderLines(calendar.year, calendar.month, calendar.grid)
			->popup_create(popup_opts)
		buf = winbufnr(win)
		setbufvar(buf, '&tabstop', 4)
		if prop_type_list({bufnr: buf})->empty()
			config.highlights->foreach((name, highlight) => prop_type_add(name,
				{ bufnr: buf, highlight: highlight }))
		endif
	else
		RenderLines(calendar.year, calendar.month, calendar.grid)
			->setbufline(buf, 1)
	endif

	HighlightDay(calendar.day)
	HighlightAdjacentDays(calendar.grid)
	HighlightToday(calendar.year, calendar.month, calendar.grid)

	OnChange(calendar.year, calendar.month)
	SetMark(calendar.year, calendar.month, calendar.grid)
enddef

export def Close()
	popup_hide(win)
enddef

# Journal Extension {{{
import autoload "notebook.vim"
def Get(year: number, month: number): list<dict<number>>
	var marks: list<dict<number>>

	for file in notebook.GetJournals(year, month)
		const parts = file->fnamemodify(':r')->split('-')
		if len(parts) >= 3
			const note_year  = parts[0]->str2nr()
			const note_month = parts[1]->str2nr()
			const note_day   = parts[2]->str2nr()
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

def OpenDailyJournal(year: number, month: number, day: number)
	Close()
	notebook.Journal({year: year, month: month, day: day})
enddef

const journals = {
	get: Get,
	actions: {
		open_daily_note: OpenDailyJournal,
	}
} # }}}
# Actions {{{
var extensions: dict<any>
var marked_days: dict<bool>
def GetCalendarExts(): dict<dict<any>>
	return {journals: journals}
enddef

def HasMarks(year: number, month: number, day: number): bool
	return marked_days->has_key(printf('%4d%2d%2d', year, month, day))
enddef

def Mark(year: number, month: number, day: number)
	marked_days[printf('%4d%2d%2d', year, month, day)] = true
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

import autoload "popup.vim"
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
# }}}
# command! -nargs=0 Calendar Open()
# map <buffer><F5> <Cmd>so<CR><Cmd>Calendar<CR>
# vim:fdm=marker
