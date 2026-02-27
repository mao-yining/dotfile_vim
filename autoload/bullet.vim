vim9script
# Name: autoload\bullet.vim
# Author: Mao-Yining <mao.yining@outlook.com>
# Desc: Vim plugin for automated bulleted lists
# Usage:
# import autoload "bullet.vim"
#
# command! RecomputeCheckboxes  bullet.RecomputeCheckboxes()
# command! RenumberList         bullet.RenumberWholeList()
# command! BulletDemote         bullet.ChangeBulletLevel(-1, false)
# command! BulletPromote        bullet.ChangeBulletLevel(1, false)
# command! InsertNewBullet      bullet.InsertNewBullet()
# command! SelectBullet         bullet.SelectBulletItem(line('.'))
# command! SelectBulletText     bullet.SelectBulletText(line('.'))
# command! SelectCheckbox       bullet.SelectCheckbox(false)
# command! SelectCheckboxInside bullet.SelectCheckbox(true)
# command! ToggleCheckbox       bullet.ToggleCheckboxesNested(line("."))
#
# command! -range=% BulletDemoteVisual  bullet.ChangeBulletLevel(-1, true)
# command! -range=% BulletPromoteVisual bullet.ChangeBulletLevel(1,  true)
# command! -range=% RenumberSelection   bullet.RenumberSelection()
#
# In Ftplugin:
# import autoload "bullet.vim"
# bullet.SetLocalMappings()

if !exists('g:bullets_delete_last_bullet_if_empty')
	g:bullets_delete_last_bullet_if_empty = 1
endif

if !exists('g:bullets_line_spacing')
	g:bullets_line_spacing = 1
endif

if !exists('g:bullets_pad_right')
	g:bullets_pad_right = 1
endif

if !exists('g:bullets_max_alpha_characters')
	g:bullets_max_alpha_characters = 2
endif

if !exists('g:bullets_enable_roman_list')
	g:bullets_enable_roman_list = 1
endif

# calculate the decimal equivalent to the last alphabetical list item
var power = g:bullets_max_alpha_characters
var abc_max = -1
while power >= 0
	abc_max += pow(26.0, power * 1.0)->float2nr()
	power -= 1
endwhile

if !exists('g:bullets_list_item_styles')
	# A list of regex patterns that are recognized as bullet points for
	# bullet items.
	g:bullets_list_item_styles = ['-', '\*+', '\.+', '#\.', '\+', '\\item']
endif

if !exists('g:bullets_outline_levels')
	# Capitalization matters: all caps will make the symbol caps, lower = lower
	# Standard bullets should include the marker symbol after 'std'
	g:bullets_outline_levels = ['ROM', 'ABC', 'num', 'abc', 'rom', 'std-', 'std*', 'std+']
endif

if !exists('g:bullets_renumber_on_change')
	g:bullets_renumber_on_change = 1
endif

if !exists('g:bullets_nested_checkboxes')
	# Enable nested checkboxes that toggle parents and children when the current
	# checkbox status changes
	g:bullets_nested_checkboxes = 1
endif

if !exists('g:bullets_enable_wrapped_lines')
	g:bullets_enable_wrapped_lines = 1
endif

if !exists('g:bullets_checkbox_markers')
	# The ordered series of markers to use in checkboxes
	# If only two markers are listed, they represent 'off' and 'on'
	# When more than two markers are included, the (n) intermediate markers
	# represent partial completion where each marker is 1/n of the total number
	# of markers.
	# E.g. the default ' .oOX': ' ' = 0 < '.' <= 1/3 < 'o' < 2/3 < 'O' < 1 = X
	# This scheme is borrowed from https://github.com/vimwiki/vimwiki
	g:bullets_checkbox_markers = ' .oOX'

	# You can use fancy symbols like this:
	# g:bullets_checkbox_markers = '✗○◐●✓'

	# You can disable partial completion markers like this:
	# g:bullets_checkbox_markers = ' X'
endif

if !exists('g:bullets_checkbox_partials_toggle')
	# Should toggling on a partially completed checkbox set it to on (1), off
	# (0), or disable toggling partially completed checkboxes (-1)
	g:bullets_checkbox_partials_toggle = 1
endif

if !exists('g:bullets_auto_indent_after_colon')
	# Should a line ending in a colon result in the next line being indented (1)?
	g:bullets_auto_indent_after_colon = 1
endif
# --------------------------------------------------------

# Parse Bullet Type --------------------------------------

# A caching mechanism for bullet
# We add a crude 'reference count' for the cache so we can nest calls
var bullet_cache = null_dict
var bullet_cache_depth = 0

def EnableBulletCache()
	if bullet_cache_depth == 0
		bullet_cache = {}
	endif
	bullet_cache_depth += 1
enddef

def DisableBulletCache()
	if bullet_cache_depth == 1
		bullet_cache = null_dict
	endif

	if bullet_cache_depth > 0
		bullet_cache_depth -= 1
	endif
enddef

def ParseBullet(line_num: number, line_text: string): list<dict<any>>
	var kinds = ParseBulletText(line_text)

	for data in kinds
		data.starting_at_line_num = line_num
	endfor

	return kinds
enddef

def ParseBulletText(line_text: string): list<dict<any>>
	if bullet_cache != null
		const cached = bullet_cache->get(line_text, null)
		if cached != null
			# Return a copy so as not to break the reference
			return copy(cached)
		endif
	endif

	const bullet = MatchBulletListItem(line_text)
	# Must be a bullet to be a checkbox
	const check = !empty(bullet) ? MatchCheckboxBulletItem(line_text) : {}
	# Cannot be numeric if a bullet
	const num = empty(bullet) ? MatchNumericListItem(line_text) : {}
	# Cannot be alphabetic if numeric or a bullet
	const alpha = empty(bullet) && empty(num) ? MatchAlphabeticalListItem(line_text) : {}
	# Cannot be roman if numeric or a bullet
	const roman = empty(bullet) && empty(num) ? MatchRomanListItem(line_text) : {}

	final kinds = Filter([bullet, check, num, alpha, roman], '!empty(v:val)')

	if bullet_cache != null
		bullet_cache[line_text] = kinds
	endif

	return kinds
enddef

def MatchNumericListItem(input_text: string): dict<any>
	const num_bullet_regex = '\v^((\s*)(\d+)(\.|\))(\s+))(.*)'
	const matches = input_text->matchlist(num_bullet_regex)

	if empty(matches)
		return {}
	endif

	const bullet_length = strlen(matches[1])
	const leading_space = matches[2]
	const num = matches[3]
	const closure = matches[4]
	const trailing_space = matches[5]
	const text_after_bullet = matches[6]

	return {
		bullet_type:       'num',
		bullet_length:     bullet_length,
		leading_space:     leading_space,
		trailing_space:    trailing_space,
		bullet:            num,
		closure:           closure,
		text_after_bullet: text_after_bullet
	}
enddef

def MatchRomanListItem(input_text: string): dict<any>
	if g:bullets_enable_roman_list == 0
		return {}
	endif

	var rom_bullet_regex = join([
		'\v\C',
		'^(',
		'  (\s*)',
		'  (',
		'    M{0,4}%(CM|CD|D?C{0,3})%(XC|XL|L?X{0,3})%(IX|IV|V?I{0,3})',
		'    |',
		'    m{0,4}%(cm|cd|d?c{0,3})%(xc|xl|l?x{0,3})%(ix|iv|v?i{0,3})',
		'  )',
		'  (\.|\))',
		'  (\s+)',
		')',
		'(.*)'], '')
	var matches = input_text->matchlist(rom_bullet_regex)
	if empty(matches)
		return {}
	endif

	var bullet_length = strlen(matches[1])
	var leading_space = matches[2]
	var rom = matches[3]
	var closure = matches[4]
	var trailing_space = matches[5]
	var text_after_bullet = matches[6]

	return {
		bullet_type:       'rom',
		bullet_length:     bullet_length,
		leading_space:     leading_space,
		trailing_space:    trailing_space,
		bullet:            rom,
		closure:           closure,
		text_after_bullet: text_after_bullet
	}
enddef

def MatchAlphabeticalListItem(input_text: string): dict<any>
	if g:bullets_max_alpha_characters == 0
		return {}
	endif

	var max = string(g:bullets_max_alpha_characters)
	var abc_bullet_regex = join([
		'\v^((\s*)(\u{1,',
		max,
		'}|\l{1,',
		max,
		'})(\.|\))(\s+))(.*)'], '')

	var matches = input_text->matchlist(abc_bullet_regex)

	if empty(matches)
		return {}
	endif

	var bullet_length = strlen(matches[1])
	var leading_space = matches[2]
	var abc = matches[3]
	var closure = matches[4]
	var trailing_space = matches[5]
	var text_after_bullet = matches[6]

	return {
		bullet_type:       'abc',
		bullet_length:     bullet_length,
		leading_space:     leading_space,
		trailing_space:    trailing_space,
		bullet:            abc,
		closure:           closure,
		text_after_bullet: text_after_bullet
	}
enddef

def MatchCheckboxBulletItem(input_text: string): dict<any>
	# match any symbols listed in g:bullets_checkbox_markers as well as the
	# default ' ', 'x', and 'X'
	var checkbox_bullet_regex =
		'\v(^(\s*)([+-\*] \[(['
		.. g:bullets_checkbox_markers
		.. ' xX])?\])(:?)(\s+))(.*)'
	var matches = input_text->matchlist(checkbox_bullet_regex)

	if empty(matches)
		return {}
	endif

	var bullet_length = strlen(matches[1])
	var leading_space = matches[2]
	var bullet = matches[3]
	var checkbox_marker = matches[4]
	var trailing_char = matches[5]
	var trailing_space = matches[6]
	var text_after_bullet = matches[7]

	return {
		bullet_type:       'chk',
		bullet_length:     bullet_length,
		leading_space:     leading_space,
		bullet:            bullet,
		checkbox_marker:   checkbox_marker,
		closure:           trailing_char,
		trailing_space:    trailing_space,
		text_after_bullet: text_after_bullet
	}
enddef

def MatchBulletListItem(input_text: string): dict<any>
	var std_bullet_regex = '\v(^(\s*)('
		.. g:bullets_list_item_styles->join('|')
		.. ')(\s+))(.*)'
	var matches = input_text->matchlist(std_bullet_regex)

	if empty(matches)
		return {}
	endif

	var bullet_length = strlen(matches[1])
	var leading_space = matches[2]
	var bullet = matches[3]
	var trailing_space = matches[4]
	var text_after_bullet = matches[5]

	return {
		bullet_type:       'std',
		bullet_length:     bullet_length,
		leading_space:     leading_space,
		bullet:            bullet,
		closure:           '',
		trailing_space:    trailing_space,
		text_after_bullet: text_after_bullet
	}
enddef
# --------------------------------------------------------

# Selection management -----------------------------------

# These functions help us maintain the cursor or selection across operation
#
# When getting selection we record
# 1. The start and end line of the selection
# 2. Thd the offset of the start and end column the line end
#
# When setting the selection we set the start and end at the same _offset_
# From the new line start and end. As we manipulate line prefixes, the
# offset from the end represents the correct new cursor position
def GetSelection(is_visual: bool): dict<any>
	var sel: dict<any> = {}
	var mode = is_visual ? visualmode() : ''
	if mode ==# 'v' || mode ==# 'V' || mode ==# "\<C-v>"
		var [start_line, start_col] = getpos("'<")[1 : 2]
		sel.start_line = start_line
		sel.start_offset = strlen(getline(sel.start_line)) - start_col
		var [end_line, end_col] = getpos("'>")[1 : 2]
		sel.end_line = end_line
		sel.end_offset = strlen(getline(sel.end_line)) - end_col
		sel.visual_mode = mode
	else
		sel.start_line = line('.')
		sel.start_offset = strlen(getline(sel.start_line)) - col('.')
		sel.end_line = sel.start_line
		sel.end_offset = sel.start_offset
		sel.visual_mode = ''
	endif
	return sel
enddef

def SetSelection(sel: dict<any>)
	var start_col = strlen(getline(sel.start_line)) - sel.start_offset
	var end_col = strlen(getline(sel.end_line)) - sel.end_offset

	cursor(sel.start_line, start_col)
	if sel.start_line != sel.end_line || start_col != end_col
		cursor(sel.end_line, end_col)
	endif
enddef
# -------------------------------------------------------

# Resolve Bullet Type -----------------------------------
def ClosestBulletTypes(from_line_num: number, max_indent: number): list<dict<any>>
	var lnum = from_line_num
	var ltxt = getline(lnum)
	var curr_indent = indent(lnum)
	var bullet_kinds = ParseBullet(lnum, ltxt)

	if max_indent < 0
		# sanity check
		return []
	endif

	# Support for wrapped text bullets, even if the wrapped line is not indented
	# It considers a blank line as the end of a bullet
	# DEMO: https://raw.githubusercontent.com/dkarter/bullets.vim/master/img/wrapped-bullets.gif
	if g:bullets_enable_wrapped_lines
		while lnum > 1 && (curr_indent != 0 || bullet_kinds != [] || !(ltxt =~# '\v^(\s+$|$)'))
				&& (max_indent < curr_indent || bullet_kinds == [])
			if bullet_kinds != []
				lnum = lnum - g:bullets_line_spacing
			else
				lnum = lnum - 1
			endif
			ltxt = getline(lnum)
			bullet_kinds = ParseBullet(lnum, ltxt)
			curr_indent = indent(lnum)
		endwhile
	endif

	return bullet_kinds
enddef

def ResolveBulletType(bullet_types: list<dict<any>>): dict<any>
	if empty(bullet_types)
		return {}
	elseif len(bullet_types) == 2 && HasRomAndAbc(bullet_types)
		return ResolveRomOrAbc(bullet_types)
	elseif len(bullet_types) == 2 && HasChkAndStd(bullet_types)
		return ResolveChkOrStd(bullet_types)
	else
		return bullet_types[0]
	endif
enddef

def ContainsType(bullet_types: list<dict<any>>, type: string): bool
	return HasItem(bullet_types, (_, val) => val.bullet_type ==# type)
enddef

def FindByType(bullet_types: list<dict<any>>, type: string): dict<any>
	return Find(bullet_types, (_, val) => val.bullet_type ==# type)
enddef
# -------------------------------------------------------

# Roman Numeral vs Alphabetic Bullets -------------------
def ResolveRomOrAbc(bullet_types: list<dict<any>>): dict<any>
	var first_type = bullet_types[0]
	var prev_search_starting_line = first_type.starting_at_line_num - g:bullets_line_spacing
	var bullet_indent = indent(first_type.starting_at_line_num)
	var prev_bullet_types = ClosestBulletTypes(prev_search_starting_line, bullet_indent)

	while prev_bullet_types != [] && bullet_indent <= indent(prev_search_starting_line)
		prev_search_starting_line -= g:bullets_line_spacing
		prev_bullet_types = ClosestBulletTypes(prev_search_starting_line, bullet_indent)
	endwhile

	if len(prev_bullet_types) == 0 || bullet_indent > indent(prev_search_starting_line)
		# can't find previous bullet - so we probably have a rom i. bullet
		return FindByType(bullet_types, 'rom')

	elseif len(prev_bullet_types) == 1 && HasRomOrAbc(prev_bullet_types)
		# previous bullet is conclusive, use it's type to continue
		return FindByType(bullet_types, prev_bullet_types[0].bullet_type)

	elseif HasRomAndAbc(prev_bullet_types)
		# inconclusive - keep searching up recursively
		var prev_bullet = ResolveRomOrAbc(prev_bullet_types)
		return FindByType(bullet_types, prev_bullet.bullet_type)

	else
		# parent has unrelated bullet type, we'll go with rom
		return FindByType(bullet_types, 'rom')
	endif
enddef

def HasRomOrAbc(bullet_types: list<dict<any>>): bool
	var has_rom = ContainsType(bullet_types, 'rom')
	var has_abc = ContainsType(bullet_types, 'abc')
	return has_rom || has_abc
enddef

def HasRomAndAbc(bullet_types: list<dict<any>>): bool
	var has_rom = ContainsType(bullet_types, 'rom')
	var has_abc = ContainsType(bullet_types, 'abc')
	return has_rom && has_abc
enddef
# -------------------------------------------------------

# Checkbox vs Standard Bullets --------------------------
def ResolveChkOrStd(bullet_types: list<dict<any>>): dict<any>
	# if it matches both regular and checkbox it is most likely a checkbox
	return FindByType(bullet_types, 'chk')
enddef

def HasChkAndStd(bullet_types: list<dict<any>>): bool
	var has_chk = ContainsType(bullet_types, 'chk')
	var has_std = ContainsType(bullet_types, 'std')
	return has_chk && has_std
enddef
# -------------------------------------------------------

# Build Next Bullet -------------------------------------
def NextBulletStr(bullet: dict<any>): string
	var bullet_type = bullet->get('bullet_type')

	var next_bullet_marker: any
	if bullet_type ==# 'rom'
		next_bullet_marker = NextRomBullet(bullet)
	elseif bullet_type ==# 'abc'
		next_bullet_marker = NextAbcBullet(bullet)
	elseif bullet_type ==# 'num'
		next_bullet_marker = NextNumBullet(bullet)
	elseif bullet_type ==# 'chk'
		next_bullet_marker = NextChkBullet(bullet)
	else
		next_bullet_marker = bullet.bullet
	endif
	var closure = bullet->has_key('closure') ? bullet.closure : ''
	return bullet.leading_space .. next_bullet_marker .. closure .. ' '
enddef

def NextRomBullet(bullet: dict<any>): string
	var islower = bullet.bullet ==# tolower(bullet.bullet)
	return Arabic2Roman(Roman2Arabic(bullet.bullet) + 1, islower)
enddef

def NextAbcBullet(bullet: dict<any>): string
	var islower = bullet.bullet ==# tolower(bullet.bullet)
	return Dec2Abc(Abc2Dec(bullet.bullet) + 1, islower)
enddef

def NextNumBullet(bullet: dict<any>): number
	return str2nr(bullet.bullet) + 1
enddef

def NextChkBullet(bullet: dict<any>): string
	var checkbox_markers = split(g:bullets_checkbox_markers, '\zs')
	return bullet.bullet[0] .. ' [' .. checkbox_markers[0] .. ']'
enddef
# --------------------------------------------------------

# Generate bullets ---------------------------------------
export def InsertNewBullet(): string
	var curr_line_num = line('.')
	var next_line_num = curr_line_num + g:bullets_line_spacing
	var curr_indent = indent(curr_line_num)
	var closest_bullet_types = ClosestBulletTypes(curr_line_num, curr_indent)
	var bullet = ResolveBulletType(closest_bullet_types)
	# need to find which line starts the previous bullet started at and start
	# searching up from there
	var send_return = 1
	var normal_mode = mode() ==# 'n'
	var indent_next = LineEndsInColon(curr_line_num) && g:bullets_auto_indent_after_colon

	# check if current line is a bullet and we are at the end of the line (for
	# insert mode only)
	if bullet != {} && (normal_mode || IsAtEol())
		# was any text entered after the bullet?
		if bullet.text_after_bullet ==# ''
			# We don't want to create a new bullet if the previous one was not used,
			# instead we want to delete the empty bullet - like word processors do
			if g:bullets_delete_last_bullet_if_empty
				if g:bullets_delete_last_bullet_if_empty == 1
					setline(curr_line_num, '')
				elseif g:bullets_delete_last_bullet_if_empty == 2
					ChangeBulletLevel(1, false)
				endif
				send_return = 0
			endif
		elseif !(bullet.bullet_type ==# 'abc' && Abc2Dec(bullet.bullet) + 1 > abc_max)

			var next_bullet = NextBulletStr(bullet)
			var next_bullet_list: list<string>
			if bullet.bullet_type ==# 'chk'
				next_bullet_list = [next_bullet]
			else
				next_bullet_list = [PadToLength(next_bullet, bullet.bullet_length)]
			endif

			# prepend blank lines if desired
			if g:bullets_line_spacing > 1
				next_bullet_list += ['']->repeat(g:bullets_line_spacing - 1)
				reverse(next_bullet_list)
			endif

			# insert next bullet
			next_bullet_list->append(curr_line_num)

			# go to next line after the new bullet
			var col = strlen(getline(next_line_num)) + 1
			setpos('.', [0, next_line_num, col])

			# indent if previous line ended in a colon
			if indent_next
				# demote the new bullet
				ChangeLineBulletLevel(-1, next_line_num)
				# reset cursor position after indenting
				col = strlen(getline(next_line_num)) + 1
				setpos('.', [0, next_line_num, col])
			elseif g:bullets_renumber_on_change
				RenumberWholeList()
			endif

			send_return = 0
		endif
	endif

	if send_return || normal_mode
		# start a new line
		if normal_mode
			startinsert!
		endif

		var keys = send_return ? "\<CR>" : ''
		keys->feedkeys('n')
	endif

	# need to return a string since we are in insert mode calling with <C-R>=
	return ''
enddef

def IsAtEol(): bool
	return strlen(getline('.')) + 1 ==# col('.')
enddef


# Helper for Colon Indent
#   returns 1 if current line ends in a colon, else 0
def LineEndsInColon(lnum: number): bool
	var line = getline(lnum)
	if exists("*strcharlen") && exists("*strgetchar")
		var last_char_nr = line->strgetchar(strcharlen(line) - 1)
		return last_char_nr == 65306 || last_char_nr == 58
	else
		# Older versions of vim do not support strchar*
		return line[strlen(line) - 1 : ] ==# ':'
	endif
enddef
# --------------------------------------------------------

# Checkboxes ---------------------------------------------
def FindCheckboxPosition(lnum: number): number
	var line_text = getline(lnum)
	return line_text->matchend('\v\s*(\*|-|\+) \[')
enddef

export def SelectCheckbox(inner: bool)
	var lnum = line('.')
	var checkbox_col = FindCheckboxPosition(lnum)

	if checkbox_col
		setpos('.', [0, lnum, checkbox_col])

		# decide if we need to select the whole checkbox with brackets or just the
		# inside of it
		if inner
			normal! vi[
		else
			normal! va[
		endif
	endif
enddef

def ToggleCheckbox(lnum: number): number
	# Toggles the checkbox on line a:lnum.
	# Returns the resulting status: (1) checked, (0) unchecked, (-1) unchanged
	var indent = indent(lnum)
	var bullet = ResolveBulletType(ClosestBulletTypes(lnum, indent))
	var checkbox_content = bullet.checkbox_marker
	if empty(bullet) || !bullet->has_key('checkbox_marker')
		return -1
	endif

	var checkbox_markers = g:bullets_checkbox_markers->split('\zs')
	var partial_markers = checkbox_markers[1 : -2]->join('')
	var marker: string
	if g:bullets_checkbox_partials_toggle > 0
			&& checkbox_content =~# '\v[' .. partial_markers .. ']'
		# Partially complete
		marker = g:bullets_checkbox_partials_toggle ?
			checkbox_markers[-1] :
			checkbox_markers[0]
	elseif checkbox_content =~# '\v[ ' .. checkbox_markers[0] .. ']'
		marker = checkbox_markers[-1]
	elseif checkbox_content =~# '\v[xX' .. checkbox_markers[-1] .. ']'
		marker = checkbox_markers[0]
	else
		return -1
	endif

	SetCheckbox(lnum, marker)
	return marker ==? checkbox_markers[-1] ? 1 : 0
enddef

def SetCheckbox(lnum: number, marker: string)
	var initpos = getpos('.')
	var pos = FindCheckboxPosition(lnum)
	if pos >= 0
		ReplaceCharInLine(lnum, pos, marker)
		setpos('.', initpos)
	endif
enddef

export def ToggleCheckboxesNested(lnum: number)
	# toggle checkbox on the current line, as well as its parents and children
	const indent_val = indent(lnum)
	const bullet = ResolveBulletType(ClosestBulletTypes(lnum, indent_val))

	# Is this a checkbox? Do nothing if it's not, otherwise toggle the checkbox
	if empty(bullet) || bullet.bullet_type !=# 'chk'
		return
	endif

	var checked = ToggleCheckbox(lnum)

	# Toggle children and parents
	if g:bullets_nested_checkboxes
		var completion_marker = SiblingCheckboxStatus(lnum)
		SetParentCheckboxes(lnum, completion_marker)

		# Toggle children
		if checked >= 0
			SetChildCheckboxes(lnum, checked)
		endif
	endif
enddef

export def ToggleCheckboxesOp(...args: list<any>): string
	if len(args) == 0
		&opfunc = matchstr(expand('<stack>'), '[^. ]*\ze[')
		return 'g@'
	endif
	const sel_save = &selection
	const clipboard_save = &clipboard
	&selection = "inclusive"
	&clipboard = ""

	var save_cursor = getcurpos()
	try
		for lnum in range(line("']"), line("'["), -1)
			ToggleCheckboxesNested(lnum)
		endfor
	finally
		setpos('.', save_cursor)
	endtry

	&selection = sel_save
	&clipboard = clipboard_save
	return ""
enddef

def SetParentCheckboxes(lnum: number, marker: string)
	# set the parent checkbox of line a:lnum, as well as its parents, based on
	# the marker passed in a:marker
	if !g:bullets_nested_checkboxes
		return
	endif

	var parent = GetParent(lnum)
	if !empty(parent) && parent.bullet_type ==# 'chk'
		# Check for siblings' status
		var pnum = parent.starting_at_line_num
		SetCheckbox(pnum, marker)
		var completion_marker = SiblingCheckboxStatus(pnum)
		SetParentCheckboxes(pnum, completion_marker)
	endif
enddef

def SetChildCheckboxes(lnum: number, checked: number)
	# set the children checkboxes of line a:lnum based on the value of a:checked
	# 0: unchecked, 1: checked, other: do nothing
	if !g:bullets_nested_checkboxes || !(checked == 0 || checked == 1)
		return
	endif

	var children = GetChildrenLineNumbers(lnum)
	if !empty(children)
		var checkbox_markers = split(g:bullets_checkbox_markers, '\zs')
		for child in children
			var marker = checked ? checkbox_markers[-1] : checkbox_markers[0]
			SetCheckbox(child, marker)
			SetChildCheckboxes(child, checked)
		endfor
	endif
enddef

# Recompute partial checkboxes of a full checkbox tree given the root lnum
def RecomputeCheckboxTree(lnum: number)
	if !g:bullets_nested_checkboxes
		return
	endif

	var indent = indent(lnum)
	var bullet = ResolveBulletType(ClosestBulletTypes(lnum, indent))

	if bullet->get('bullet_type', '') !=# 'chk'
		return
	endif

	# recursively recompute checkbox tree for all children, then finally self

	var children = GetChildrenLineNumbers(lnum)
	for child_nr in children
		# nb: this skips 'grandchildren' checkboxes (i.e., children who aren't
		# checkboxes but have checkbox children themselves), but those grandkids
		# will be targeted by RecomputeCheckboxesInRange anyway
		RecomputeCheckboxTree(child_nr)
	endfor

	if empty(children)
		# if no children, preserve previous checked state
		# partially completed checkboxes become unchecked
		if empty(bullet) || !bullet->has_key('checkbox_marker')
			return
		endif

		var checkbox_markers = g:bullets_checkbox_markers->split('\zs')
		var partial_markers = checkbox_markers[1 : -2]->join('')

		if bullet.checkbox_marker =~# '\v[' .. partial_markers .. ']'
			SetCheckbox(lnum, checkbox_markers[0])
		endif
	else
		# if children exist, recompute this checkbox status
		var first_child = children[0]
		var completion_marker = SiblingCheckboxStatus(first_child)
		SetCheckbox(lnum, completion_marker)
	endif
enddef

def RecomputeCheckboxesInRange(start: number, end: number)
	if !g:bullets_nested_checkboxes
		return
	endif

	EnableBulletCache()
	for nr in start->range(end)
		# find all bullets who do not have a checkbox parent
		var parent = GetParent(nr)
		if !empty(parent) && parent.bullet_type ==# 'chk'
			continue
		endif

		RecomputeCheckboxTree(nr)
	endfor
	DisableBulletCache()
enddef

# Recomputes checkboxes for the whole list containing the cursor.
export def RecomputeCheckboxes()
	if !g:bullets_nested_checkboxes
		return
	endif

	EnableBulletCache()
	var first_line = FirstBulletLine(line('.'))
	var last_line = LastBulletLine(line('.'))
	if first_line > 0 && last_line > 0
		RecomputeCheckboxesInRange(first_line, last_line)
	endif
	DisableBulletCache()
enddef

# Checkboxes ---------------------------------------------

# Roman numerals -----------------------------------------

# Roman numeral functions lifted from tpope's speeddating.vim
# where they are in turn based on similar functions from VisIncr.vim

var a2r = [
	[1000, 'm'], [900, 'cm'], [500, 'd'], [400, 'cd'],
	[100, 'c'], [90, 'xc'], [50, 'l'], [40, 'xl'],
	[10,  'x'], [9, 'ix'], [5, 'v'], [4, 'iv'],
	[1, 'i']
]

def Roman2Arabic(roman: string): number
	var rom = tolower(roman)
	var sign = 1
	var arabic = 0
	while rom !=# ''
		if rom =~# '^[-n]'
			sign = -sign
		endif
		for [numbers, letters] in a2r
			if rom =~# '^' .. letters
				arabic += sign * numbers
				rom = rom->strpart(strlen(letters) - 1)
				break
			endif
		endfor
		rom = rom->strpart(1)
	endwhile
	return arabic
enddef

def Arabic2Roman(arabic: number, islower: bool): string
	var arab: number
	var roman: string
	if arabic <= 0
		arab = -arabic
		roman = 'n'
	else
		arab = arabic
		roman = ''
	endif
	for [numbers, letters] in a2r
		roman ..= letters->repeat(arab / numbers)
		arab = arab % numbers
	endfor
	return islower ? tolower(roman) : toupper(roman)
enddef
# Roman numerals -----------------------------------------

# Alphabetic ordinals ------------------------------------

# Alphabetic ordinal functions
# Treat alphabetic ordinals as base-26 numbers to make things easy
def Abc2Dec(abc: string): number
	var abc_lower = tolower(abc)
	var dec = char2nr(abc_lower[0]) - char2nr('a') + 1
	if len(abc_lower) == 1
		return dec
	else
		return float2nr(26->pow(len(abc_lower) - 1)) * dec + Abc2Dec(abc_lower[1 : ])
	endif
enddef

def Dec2Abc(dec: number, islower: bool): string
	var a = islower ? 'a' : 'A'
	var rem = (dec - 1) % 26
	var abc = nr2char(rem + char2nr(a))
	if dec <= 26
		return abc
	else
		return Dec2Abc((dec - 1) / 26, islower) .. abc
	endif
enddef
# Alphabetic ordinals ------------------------------------

# Renumbering --------------------------------------------
export def RenumberSelection()
	var sel = GetSelection(true)
	RenumberLines(sel.start_line, sel.end_line)
	SetSelection(sel)
enddef

def RenumberLines(start: number, end: number)
	EnableBulletCache()
	var prev_indent = -1
	var levels: dict<any> = {} # stores all the info about the current outline/list

	for nr in start->range(end)
		var indent = indent(nr)
		var bullet = ResolveBulletType(ClosestBulletTypes(nr, indent))
		var curr_level = GetLevel(bullet)
		if curr_level > 1
			# then it's an AsciiDoc list and shouldn't be renumbered
			break
		endif

		if !empty(bullet) && bullet.starting_at_line_num == nr
			# skip wrapped lines and lines that aren't bullets
			if (indent > prev_indent || !levels->has_key(indent))
					&& bullet.bullet_type !=# 'chk' && bullet.bullet_type !=# 'std'
				if !levels->has_key(indent)
					levels[indent] = {index: 1}
				endif

				# use the first bullet at this level to define the bullet type for
				# subsequent bullets at the same level. Needed to normalize bullet
				# types when there are multiple types of bullets at the same level.
				levels[indent].islower = bullet.bullet ==# tolower(bullet.bullet)
				levels[indent].type = bullet.bullet_type
				levels[indent].bullet = bullet.bullet # for standard bullets
				levels[indent].closure = bullet.closure # normalize closures
				levels[indent].trailing_space = bullet.trailing_space
			else
				if bullet.bullet_type !=# 'chk' && bullet.bullet_type !=# 'std'
					levels[indent].index += 1
				endif

				if indent < prev_indent
					# Reset the numbering on all all child items. Needed to avoid continuing
					# the numbering from earlier portions of the list with the same bullet
					# type in some edge cases.
					for key in keys(levels)
						if key->str2nr() > indent
							levels->remove(key)
						endif
					endfor
				endif
			endif

			prev_indent = indent

			if bullet.bullet_type !=# 'chk' && bullet.bullet_type !=# 'std'
				var bullet_num: any
				if levels[indent].type ==? 'rom'
					bullet_num = Arabic2Roman(levels[indent].index, levels[indent].islower)
				elseif levels[indent].type ==? 'abc'
					bullet_num = Dec2Abc(levels[indent].index, levels[indent].islower)
				elseif levels[indent].type ==# 'num'
					bullet_num = levels[indent].index
				endif

				var new_bullet =
					bullet_num
					.. levels[indent].closure
					.. levels[indent].trailing_space
				if levels[indent].index > 1
					new_bullet = PadToLength(new_bullet, levels[indent].pad_len)
				endif
				levels[indent].pad_len = len(new_bullet)
				var renumbered_line = bullet.leading_space
					.. new_bullet
					.. bullet.text_after_bullet
				renumbered_line->setline(nr)
			elseif bullet.bullet_type ==# 'chk'
				# Reset the checkbox marker if it already exists, or blank otherwise
				var marker = bullet->has_key('checkbox_marker') ?
					bullet.checkbox_marker : ' '
				SetCheckbox(nr, marker)
			endif
		endif
	endfor
	DisableBulletCache()
enddef

# Renumbers the whole list containing the cursor.
export def RenumberWholeList()
	EnableBulletCache()
	var first_line = FirstBulletLine(line('.'))
	var last_line = LastBulletLine(line('.'))
	if first_line > 0 && last_line > 0
		RenumberLines(first_line, last_line)
	endif
	DisableBulletCache()
enddef

# -------------------------------------------------------

# Changing outline level --------------------------------
def ChangeLineBulletLevel(direction: number, lnum: number)
	var curr_line = ParseBullet(lnum, getline(lnum))

	if direction == 1
		if curr_line != [] && indent(lnum) == 0
			# Promoting a bullet at the highest level will delete the bullet
			curr_line[-1].text_after_bullet->setline(lnum)
			return
		else
			execute $':{lnum}normal! <<'
		endif
	else
		execute $':{lnum}normal! >>'
	endif

	if curr_line == []
		# If the current line is not a bullet then don't do anything else.
		return
	endif

	var curr_indent = indent(lnum)
	var curr_bullet = ResolveBulletType(ClosestBulletTypes(lnum, curr_indent))

	var curr_line_num = curr_bullet.starting_at_line_num
	var closest_bullet = ResolveBulletType(ClosestBulletTypes(curr_line_num - g:bullets_line_spacing, curr_indent))

	if closest_bullet == {}
		# If there is no parent/sibling bullet then this bullet shouldn't change.
		return
	endif

	var islower = closest_bullet.bullet ==# tolower(closest_bullet.bullet)
	var closest_indent = indent(closest_bullet.starting_at_line_num)

	var closest_type = islower ? closest_bullet.bullet_type :
		toupper(closest_bullet.bullet_type)
	if closest_bullet.bullet_type ==# 'std'
		# Append the bullet marker to the type, e.g., 'std*'

		closest_type = closest_type .. closest_bullet.bullet
	endif

	var closest_index = g:bullets_outline_levels->index(closest_type)
	if closest_index == -1
		# We are in a list using markers that aren't specified in
		# g:bullets_outline_levels so we shouldn't try to change the current
		# bullet.
		return
	endif
	var next_bullet_str: string
	if (curr_indent == closest_indent)
		# The closest bullet is a sibling so the current bullet should
		# increment to the next bullet marker.

		var next_bullet = NextBulletStr(closest_bullet)
		next_bullet_str = PadToLength(next_bullet, closest_bullet.bullet_length)
			.. curr_bullet.text_after_bullet

	elseif closest_index + 1 >= len(g:bullets_outline_levels)
			&& curr_indent > closest_indent
		# The closest bullet is a parent and its type is the last one defined in
		# g:bullets_outline_levels so keep the existing bullet.
		# TODO: Might make an option for whether the bullet should stay or be
		# deleted when demoting past the end of the defined bullet types.
		return
	elseif closest_index + 1 < len(g:bullets_outline_levels) || curr_indent < closest_indent
		# The current bullet is a child of the closest bullet so figure out
		# what bullet type it should have and set its marker to the first
		# character of that type.

		var next_type = g:bullets_outline_levels[closest_index + 1]
		var next_islower = next_type ==# tolower(next_type)
		var trailing_space = ' '
		curr_bullet.closure = closest_bullet.closure

		# set the bullet marker to the first character of the new type
		var next_num: any
		if next_type ==? 'rom'
			next_num = Arabic2Roman(1, next_islower)
		elseif next_type ==? 'abc'
			next_num = Dec2Abc(1, next_islower)
		elseif next_type ==# 'num'
			next_num = '1'
		else
			# standard bullet; the last character of next_type contains the bullet
			# symbol to use
			next_num = next_type->strpart(len(next_type) - 1)
			curr_bullet.closure = ''
		endif

		next_bullet_str =
			curr_bullet.leading_space
			.. next_num
			.. curr_bullet.closure
			.. trailing_space
			.. curr_bullet.text_after_bullet

	else
		# We're outside of the defined outline levels
		next_bullet_str =
			curr_bullet.leading_space
			.. curr_bullet.text_after_bullet
	endif

	# Apply the new bullet
	next_bullet_str->setline(lnum)
enddef

export def ChangeBulletLevel(direction: number, is_visual: bool)
	# Changes the bullet level for each of the selected lines
	var sel = GetSelection(is_visual)
	for lnum in sel.start_line->range(sel.end_line)
		ChangeLineBulletLevel(direction, lnum)
	endfor

	if g:bullets_renumber_on_change
		RenumberWholeList()
	endif
	SetSelection(sel)
enddef

# -------------------------------------------------------

# Keyboard mappings -------------------------------------

export def SetLocalMappings()
	# Automatic bullets
	inoremap <silent> <buffer> <CR> <C-]><C-R>=bullet#InsertNewBullet()<CR>
	nnoremap <silent> <buffer> o <ScriptCmd>InsertNewBullet()<CR>

	# Renumber bullet list
	nnoremap <silent> <buffer> gN <ScriptCmd>RenumberWholeList()<CR>
	xnoremap <silent> <buffer> gN <ScriptCmd>RenumberSelection()<CR>

	# Toggle checkbox
	nnoremap <expr><buffer> <M-x> ToggleCheckboxesOp() .. '_'
	xnoremap <expr><buffer> <M-x> ToggleCheckboxesOp()

	# Recompute checkbox list
	nnoremap <silent> <buffer> <M-r> <Cmd>RecomputeCheckboxes<CR>

	# Promote and Demote outline level
	inoremap <silent> <buffer> <C-t> <ScriptCmd>ChangeBulletLevel(-1, false)<CR>
	inoremap <silent> <buffer> <C-d> <Cmd>ChangeBulletLevel(1, false)<CR>
	nnoremap <silent> <buffer> >> <ScriptCmd>ChangeBulletLevel(-1, false)<CR>
	nnoremap <silent> <buffer> << <ScriptCmd>ChangeBulletLevel(1, false)<CR>
	xnoremap <silent> <buffer> > :BulletDemoteVisual<CR>
	xnoremap <silent> <buffer> < :BulletPromoteVisual<CR>
enddef

# -------------------------------------------------------

# Helpers -----------------------------------------------
def PadToLength(str: string, len: number): string
	if g:bullets_pad_right == 0 | return str | endif
	var length = len - strlen(str)
	var ret = str
	if (length <= 0) | return str | endif
	while length > 0
		ret ..= ' '
		length -= 1
	endwhile
	return ret
enddef

def Filter(list: any, fn: string): any
	return deepcopy(list)->filter(fn)
enddef

def Find(list: any, Fn: func(any, any): bool): any
	for item in list
		if Fn(0, item)
			return deepcopy(item)
		endif
	endfor

	return 0
enddef

def HasItem(list: any, Fn: func(any, any): bool): bool
	return !empty(Find(list, Fn))
enddef

def GetLevel(bullet: dict<any>): number
	if bullet == {} || bullet.bullet_type !=# 'std'
		return 0
	else
		return len(bullet.bullet)
	endif
enddef

def FirstBulletLine(lnum: number, min_indent = 0): number
	# returns the line number of the first bullet in the list containing the
	# given line number, up to the first blank line
	# returns -1 if lnum is not in a list
	# Optional argument: only consider bullets at or above this indentation
	var line_num = lnum
	var first_line = -1
	var curr_indent = indent(line_num)
	var bullet_kinds = ClosestBulletTypes(line_num, curr_indent)
	var blank_lines = 0
	var list_start = 0

	if min_indent < 0
		# sanity check
		return -1
	endif

	while line_num >= 1 && !list_start && curr_indent >= min_indent
		if bullet_kinds != []
			first_line = line_num
			blank_lines = 0
		else
			blank_lines += 1
			list_start = blank_lines >= g:bullets_line_spacing ? 1 : 0
		endif
		curr_indent = indent(line_num)
		bullet_kinds = ClosestBulletTypes(line_num, curr_indent)
		line_num -= 1
	endwhile
	return first_line
enddef

def LastBulletLine(lnum: number, min_indent = 0): number
	# returns the line number of the last bullet in the list containing the
	# given line number, down to the end of the list
	# returns -1 if lnum is not in a list
	# Optional argument: only consider bullets at or above this indentation
	var line_num = lnum
	var buf_end = line('$')
	var last_line = -1
	var curr_indent = indent(line_num)
	var bullet_kinds = ClosestBulletTypes(line_num, curr_indent)
	var blank_lines = 0
	var list_end = 0

	if min_indent < 0
		# sanity check
		return -1
	endif

	while line_num <= buf_end && !list_end && curr_indent >= min_indent
		if bullet_kinds != []
			last_line = line_num
			blank_lines = 0
		else
			blank_lines += 1
			list_end = blank_lines >= g:bullets_line_spacing ? 1 : 0
		endif
		line_num += 1
		if line_num <= buf_end
			curr_indent = indent(line_num)
			bullet_kinds = ClosestBulletTypes(line_num, curr_indent)
		endif
	endwhile
	return last_line
enddef

def GetParent(lnum: number): dict<any>
	# returns the parent bullet of the given line number, lnum, with indentation
	# at or below the given indent.
	# if there is no parent, returns an empty dictionary
	var indent = indent(lnum)
	if indent < 0
		return {}
	endif
	var parent = ResolveBulletType(ClosestBulletTypes(lnum, indent - 1))
	return parent
enddef

def GetSiblingLineNumbers(lnum: number): list<number>
	# returns a list with line numbers of the sibling bullets with the same
	# indentation as a:indent, starting from the given line number, a:lnum
	const indent = indent(lnum)
	const first_sibling = FirstBulletLine(lnum, indent)
	const last_sibling = LastBulletLine(lnum, indent)

	var siblings: list<number>
	for num in range(first_sibling, last_sibling)
		if indent(num) == indent
			const bullet = ParseBullet(num, getline(num))
			if !empty(bullet)
				siblings->add(num)
			endif
		endif
	endfor
	return siblings
enddef

def GetChildrenLineNumbers(lnum: number): list<number>
	# returns a list with line numbers of the immediate children bullets with
	# indentation greater than line a:lnum
	const buf_end = line('$')

	# sanity check
	if lnum < 1 || lnum >= buf_end
		return []
	endif

	# find the first child (if any) so we can figure out the indentation for the
	# rest of the children
	var line_num = lnum + 1
	var indent_val = indent(lnum)
	var curr_indent = indent(line_num)
	var bullet_kinds = ClosestBulletTypes(line_num, curr_indent)
	var child_lnum = 0
	var blank_lines = 0

	while line_num <= buf_end && child_lnum == 0
		if bullet_kinds != [] && curr_indent > indent_val
			child_lnum = line_num
		else
			blank_lines += 1
			child_lnum = blank_lines >= g:bullets_line_spacing ? -1 : 0
		endif
		line_num += 1
		if line_num <= buf_end
			curr_indent = indent(line_num)
			bullet_kinds = ClosestBulletTypes(line_num, curr_indent)
		endif
	endwhile

	if child_lnum > 0
		return GetSiblingLineNumbers(child_lnum)
	else
		return []
	endif
enddef

def SiblingCheckboxStatus(lnum: number): string
	# Returns the marker corresponding to the proportion of siblings that are
	# completed.
	const siblings = GetSiblingLineNumbers(lnum)
	var checked = 0
	const checkbox_markers = g:bullets_checkbox_markers->split('\zs')
	for num in siblings
		const indent = indent(num)
		const bullet = ResolveBulletType(ClosestBulletTypes(num, indent))
		if !empty(bullet) && bullet->has_key('checkbox_marker')
			const checkbox_content = bullet.checkbox_marker

			if checkbox_content =~# '\v[xX' .. checkbox_markers[-1] .. ']'
				# Checked
				checked += 1
			endif
		endif
	endfor
	const quot = (len(checkbox_markers) - 1.0) * checked / len(siblings)
	const mark = float2nr(quot) == 0 && quot != 0.0 ? 1 : float2nr(quot)
	return checkbox_markers[mark]
enddef

def ReplaceCharInLine(lnum: number, chari: number, item: string)
	const curline = getline(lnum)
	const before = curline->strcharpart(0, chari)
	const after = curline->strcharpart(chari + 1)
	setline(lnum, before .. item .. after)
enddef

export def SelectBulletText(lnum: number)
	const curr_line = ParseBullet(lnum, getline(lnum))
	if curr_line != []
		const startpos = curr_line[0].bullet_length + 1
		setpos('.', [0, lnum, startpos])
		normal! v
		setpos('.', [0, lnum, len(getline(lnum))])
	endif
enddef

export def SelectBulletItem(lnum: number)
	const curr_line = ParseBullet(lnum, getline(lnum))
	if curr_line != []
		const startpos = len(curr_line[0].leading_space) + 1
		setpos('.', [0, lnum, startpos])
		normal! v
		setpos('.', [0, lnum, len(getline(lnum))])
	endif
enddef
