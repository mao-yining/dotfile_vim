vim9script noclear

# TODO print messages when on visual mode. I only see VISUAL, not the messages.

# Function interface philosophy:
#
# - functions take arbitrary line numbers as parameters.
#    Current cursor line is only a suitable default parameter.
#
# - only functions that bind directly to user actions:
#
#    - print error messages.
#       All intermediate functions limit themselves return `0` to indicate an error.
#
#    - move the cursor. All other functions do not move the cursor.
#
# This is how you should view headers for the header mappings:
#
#   |BUFFER
#   |
#   |Outside any header
#   |
# a-+# a
#   |
#   |Inside a
#   |
# a-+
# b-+## b
#   |
#   |inside b
#   |
# b-+
# c-+### c
#   |
#   |Inside c
#   |
# c-+
# d-|# d
#   |
#   |Inside d
#   |
# d-+
# e-|e
#   |====
#   |
#   |Inside e
#   |
# e-+

# For each level, contains the regexp that matches at that level only.
#
var levelRegexpDict: dict<string> = {
  1: '\v^(#[^#]@=|.+\n\=+$)',
  2: '\v^(##[^#]@=|.+\n-+$)',
  3: '\v^###[^#]@=',
  4: '\v^####[^#]@=',
  5: '\v^#####[^#]@=',
  6: '\v^######[^#]@='
}

# Matches any header level of any type.
#
# This could be deduced from `levelRegexpDict`, but it is more
# efficient to have a single regexp for this.
#
var headersRegexp = '\v^(#|.+\n(\=+|-+)$)'

# Returns the line number of the first header before `line`, called the
# current header.
#
# If there is no current header, return `0`.
#
# @param a:1 The line to look the header of. Default value: `getpos('.')`.
#
def GetHeaderLineNum(...line: list<any>): number
  var l: number
  if line->len() == 0
    l = line('.')
  else
    l = line[0]
  endif
  while l > 0
    if join(getline(l, l + 1), "\n") =~ headersRegexp
      return l
    endif
    l -= 1
  endwhile
  return 0
enddef

# Move cursor to next header of any level.
#
# If there are no more headers, print a warning.
#
def MoveToNextHeader()
  if search(headersRegexp, 'W') == 0
    #normal! G
    echo 'no next header'
  endif
enddef

# Move cursor to previous header (before current) of any level.
#
# If it does not exist, print a warning.
#
def MoveToPreviousHeader()
  var curHeaderLineNumber = GetHeaderLineNum()
  var noPreviousHeader = false
  if curHeaderLineNumber <= 1
    noPreviousHeader = true
  else
    var previousHeaderLineNumber = GetHeaderLineNum(curHeaderLineNumber - 1)
    if previousHeaderLineNumber == 0
      noPreviousHeader = true
    else
      cursor(previousHeaderLineNumber, 1)
    endif
  endif
  if noPreviousHeader
    echo 'no previous header'
  endif
enddef

# - if line is inside a header, return the header level (h1 -> 1, h2 -> 2, etc.).
#
# - if line is at top level outside any headers, return `0`.
#
def GetHeaderLevel(...line: list<any>): number
  var l: number
  if line->len() == 0
    l = line('.')
  else
    l = line[0]
  endif
  var linenum = GetHeaderLineNum(l)
  if linenum != 0
    return GetLevelOfHeaderAtLine(linenum)
  else
    return 0
  endif
enddef

# Return list of headers and their levels.
#
def GetHeaderList(): list<dict<any>>
  var bufnr = bufnr('%')
  var fenced_block = false
  var front_matter = false
  var header_list: list<dict<any>> = []
  var markdown_yaml_head = get(g:, 'markdown_yaml_head', 0)
  var fence_str = ''
  for i in range(1, line('$'))
    var lineraw = getline(i)
    var l1 = getline(i + 1)
    var line = substitute(lineraw, '#', "\\\#", 'g')
    # exclude lines in fenced code blocks
    if line =~# '\v^[[:space:]>]*(`{3,}|\~{3,})\s*(\w+)?\s*$'
      if !fenced_block
        fenced_block = true
        fence_str = matchstr(line, '\v(`{3,}|\~{3,})')
      elseif fenced_block && matchstr(line, '\v(`{3,}|\~{3,})') ==# fence_str
        fenced_block = false
        fence_str = ''
      endif
    # exclude lines in frontmatters
    elseif markdown_yaml_head == 1
      if front_matter
        if line ==# '---'
          front_matter = false
        endif
      elseif i == 1
        if line ==# '---'
          front_matter = true
        endif
      endif
    endif
    # match line against header regex
    var is_header = join(getline(i, i + 1), "\n") =~# headersRegexp && line =~# '^\S'
    if is_header && !fenced_block && !front_matter
      # remove hashes from atx headers
      if match(line, '^#') > -1
        line = substitute(line, '\v^#*[ ]*', '', '')
        line = substitute(line, '\v[ ]*#*$', '', '')
      endif
      # append line to list
      var level = GetHeaderLevel(i)
      var item = {level: level, text: line, lnum: i, bufnr: bufnr}
      header_list = header_list + [item]
    endif
  endfor
  return header_list
enddef

# Returns the level of the header at the given line.
#
# If there is no header at the given line, returns `0`.
#
def GetLevelOfHeaderAtLine(linenum: number): number
  var lines = join(getline(linenum, linenum + 1), "\n")
  for key in levelRegexpDict->keys()->map((_, v) => str2nr(v))
    if lines =~ levelRegexpDict[key]
      return key
    endif
  endfor
  return 0
enddef

# Return the line number of the parent header of line `line`.
#
# If it has no parent, return `0`.
#
def GetParentHeaderLineNumber(...line: list<any>): number
  var l: number
  if line->len() == 0
    l = line('.')
  else
    l = line[0]
  endif
  var level = GetHeaderLevel(l)
  if level > 1
    var linenum = GetPreviousHeaderLineNumberAtLevel(level - 1, l)
    return linenum
  endif
  return 0
enddef

# Return the line number of the previous header of given level.
# in relation to line `a:1`. If not given, `a:1 = getline()`
#
# `a:1` line is included, and this may return the current header.
#
# If none return 0.
#
def GetNextHeaderLineNumberAtLevel(level: number, ...line: list<any>): number
  var l: number
  if line->len() < 1
    l = line('.')
  else
    l = line[0]
  endif
  while l <= line('$')
    if join(getline(l, l + 1), "\n") =~ levelRegexpDict[level]
      return l
    endif
    l += 1
  endwhile
  return 0
enddef

# Return the line number of the previous header of given level.
# in relation to line `a:1`. If not given, `a:1 = getline()`
#
# `a:1` line is included, and this may return the current header.
#
# If none return 0.
#
def GetPreviousHeaderLineNumberAtLevel(level: number, ...line: list<any>): number
  var l: number
  if line->len() == 0
    l = line('.')
  else
    l = line[0]
  endif
  while l > 0
    if join(getline(l, l + 1), "\n") =~ levelRegexpDict[level]
      return l
    endif
    l -= 1
  endwhile
  return 0
enddef

# Move cursor to next sibling header.
#
# If there is no next siblings, print a warning and don't move.
#
def MoveToNextSiblingHeader()
  var curHeaderLineNumber = GetHeaderLineNum()
  var curHeaderLevel = GetLevelOfHeaderAtLine(curHeaderLineNumber)
  var curHeaderParentLineNumber = GetParentHeaderLineNumber()
  var nextHeaderSameLevelLineNumber = GetNextHeaderLineNumberAtLevel(curHeaderLevel, curHeaderLineNumber + 1)
  var noNextSibling = false
  if nextHeaderSameLevelLineNumber == 0
    noNextSibling = true
  else
    var nextHeaderSameLevelParentLineNumber = GetParentHeaderLineNumber(nextHeaderSameLevelLineNumber)
    if curHeaderParentLineNumber == nextHeaderSameLevelParentLineNumber
      cursor(nextHeaderSameLevelLineNumber, 1)
    else
      noNextSibling = true
    endif
  endif
  if noNextSibling
    echo 'no next sibling header'
  endif
enddef

# Move cursor to previous sibling header.
#
# If there is no previous siblings, print a warning and do nothing.
#
def MoveToPreviousSiblingHeader()
  var curHeaderLineNumber = GetHeaderLineNum()
  var curHeaderLevel = GetLevelOfHeaderAtLine(curHeaderLineNumber)
  var curHeaderParentLineNumber = GetParentHeaderLineNumber()
  var previousHeaderSameLevelLineNumber = GetPreviousHeaderLineNumberAtLevel(curHeaderLevel, curHeaderLineNumber - 1)
  var noPreviousSibling = false
  if previousHeaderSameLevelLineNumber == 0
    noPreviousSibling = true
  else
    var previousHeaderSameLevelParentLineNumber = GetParentHeaderLineNumber(previousHeaderSameLevelLineNumber)
    if curHeaderParentLineNumber == previousHeaderSameLevelParentLineNumber
      cursor(previousHeaderSameLevelLineNumber, 1)
    else
      noPreviousSibling = true
    endif
  endif
  if noPreviousSibling
    echo 'no previous sibling header'
  endif
enddef

def Toc(...window_type: list<any>)
  var window_type_str: string
  if window_type->len() > 0
    window_type_str = window_type[0]
  else
    window_type_str = 'vertical'
  endif

  var cursor_line = line('.')
  var cursor_header = 0
  var header_list = GetHeaderList()
  var indented_header_list: list<dict<any>> = []
  if header_list->len() == 0
    echom 'Toc: No headers.'
    return
  endif
  var header_max_len = 0
  var vim_markdown_toc_autofit = get(g:, 'vim_markdown_toc_autofit', 0)
  for h in header_list
    # set header number of the cursor position
    if cursor_header == 0
      var header_line = h.lnum
      if header_line == cursor_line
        cursor_header = index(header_list, h) + 1
      elseif header_line > cursor_line
        cursor_header = index(header_list, h)
      endif
    endif
    # indent header based on level
    var text = repeat('  ', h.level - 1) .. h.text
    # keep track of the longest header size (heading level + title)
    var total_len = strdisplaywidth(text)
    if total_len > header_max_len
      header_max_len = total_len
    endif
    # append indented line to list
    var item = {lnum: h.lnum, text: text, valid: true, bufnr: h.bufnr, col: 1}
    indented_header_list = indented_header_list + [item]
  endfor
  setloclist(0, indented_header_list)

  if window_type_str ==# 'horizontal'
    lopen
  elseif window_type_str ==# 'vertical'
    vertical lopen
    # auto-fit toc window when possible to shrink it
    if (&columns / 2) > header_max_len && vim_markdown_toc_autofit == 1
      # header_max_len + 1 space for first header + 3 spaces for line numbers
      execute 'vertical resize ' .. (header_max_len + 1 + 3)
    else
      execute 'vertical resize ' .. (&columns / 2)
    endif
  elseif window_type_str ==# 'tab'
    tab lopen
  else
    lopen
  endif
  setlocal modifiable
  for i in range(1, line('$'))
    # this is the location-list data for the current item
    var d = getloclist(0)[i - 1]
    setline(i, d.text)
  endfor
  setlocal nomodified
  setlocal nomodifiable
  execute 'normal! ' .. cursor_header .. 'G'
enddef

def InsertToc(format: string, ...max_level: list<any>)
  var max_level_num: number
  if max_level->len() > 0
    if type(max_level[0]) != type(0)
      echohl WarningMsg
      echomsg '[vim-markdown] Invalid argument, must be an integer >= 2.'
      echohl None
      return
    endif
    max_level_num = max_level[0]
    if max_level_num < 2
      echohl WarningMsg
      echomsg '[vim-markdown] Maximum level cannot be smaller than 2.'
      echohl None
      return
    endif
  else
    max_level_num = 0
  endif

  var toc: list<string> = []
  var header_list = GetHeaderList()
  if header_list->len() == 0
    echom 'InsertToc: No headers.'
    return
  endif

  var max_h2_number_len: number
  if format ==# 'numbers'
    var h2_count = 0
    for header in header_list
      if header.level == 2
        h2_count += 1
      endif
    endfor
    max_h2_number_len = string(h2_count)->strlen()
  else
    max_h2_number_len = 0
  endif

  var h2_count = 0
  for header in header_list
    var indent: string
    var marker: string
    var level = header.level
    if level == 1
      # skip level-1 headers
      continue
    elseif max_level_num != 0 && level > max_level_num
      # skip unwanted levels
      continue
    elseif level == 2
      # list of level-2 headers can be bullets or numbers
      if format ==# 'bullets'
        indent = ''
        marker = '- '
      else
        h2_count += 1
        var number_len = string(h2_count)->strlen()
        indent = repeat(' ', max_h2_number_len - number_len)
        marker = h2_count .. '. '
      endif
    else
      indent = repeat(' ', max_h2_number_len + 2 * (level - 2))
      marker = '- '
    endif
    var text = '[' .. header.text .. ']'
    var link = '(#' .. tolower(header.text)->substitute('\v[ ]+', '-', 'g') .. ')'
    var line = indent .. marker .. text .. link
    toc = toc + [line]
  endfor

  append(line('.'), toc)
enddef

# Convert Setex headers in range `line1 .. line2` to Atx.
#
# Return the number of conversions.
#
def SetexToAtx(line1: number, line2: number): number
  var originalNumLines = line('$')
  execute 'silent! ' .. line1 .. ',' .. line2 .. 'substitute/\v(.*\S.*)\n\=+$/# \1/'

  var changed = originalNumLines - line('$')
  execute 'silent! ' .. line1 .. ',' .. (line2 - changed) .. 'substitute/\v(.*\S.*)\n-+$/## \1/'
  return originalNumLines - line('$')
enddef

# If `a:1` is 0, decrease the level of all headers in range `line1 .. line2`.
#
# Otherwise, increase the level. `a:1` defaults to `0`.
#
def HeaderDecrease(line1: number, line2: number, ...increase: list<any>)
  var incr: bool
  if increase->len() > 0
    incr = increase[0]
  else
    incr = false
  endif
  var forbiddenLevel: number
  var replaceLevels: list<number>
  var levelDelta: number
  if incr
    forbiddenLevel = 6
    replaceLevels = [5, 1]
    levelDelta = 1
  else
    forbiddenLevel = 1
    replaceLevels = [2, 6]
    levelDelta = -1
  endif
  for l in range(line1, line2)
    if join(getline(l, l + 1), "\n") =~ levelRegexpDict[forbiddenLevel]
      echomsg 'There is an h' .. forbiddenLevel .. ' at line ' .. l .. '. Aborting.'
      return
    endif
  endfor
  var numSubstitutions = SetexToAtx(line1, line2)
  var flags = (&gdefault ? '' : 'g')
  for level in range(replaceLevels[0], replaceLevels[1], -levelDelta)
    execute 'silent! ' .. line1 .. ',' .. (line2 - numSubstitutions) .. 'substitute/' .. levelRegexpDict[level] .. '/' .. repeat('#', level + levelDelta) .. '/' .. flags
  endfor
enddef

# Format table under cursor.
#
# Depends on Tabularize.
#
def TableFormat()
  var pos = getpos('.')

  if get(g:, 'vim_markdown_borderless_table', false)
    # add `|` to the beginning of the line if it isn't present
    normal! {
    search('|')
    execute 'silent .,''}s/\v^(\s{0,})\|?([^\|])/\1|\2/e'

    # add `|` to the end of the line if it isn't present
    normal! {
    search('|')
    execute 'silent .,''}s/\v([^\|])\|?(\s{0,})$/\1|\2/e'
  endif

  normal! {
  # Search instead of `normal! j` because of the table at beginning of file edge case.
  search('|')
  normal! j
  # Remove everything that is not a pipe, colon or hyphen next to a colon othewise
  # well formated tables would grow because of addition of 2 spaces on the separator
  # line by Tabularize /|.
  var flags = (&gdefault ? '' : 'g')
  execute 's/\(:\@<!-:\@!\|[^|:-]\)//e' .. flags
  execute 's/--/-/e' .. flags
  Tabularize /\(\\\)\@<!|
  # Move colons for alignment to left or right side of the cell.
  execute 's/:\( \+\)|/\1:|/e' .. flags
  execute 's/|\( \+\):/|:\1/e' .. flags
  execute 's/|:\?\zs[ -]\+\ze:\?|/\=repeat("-", len(submatch(0)))/' .. flags
  setpos('.', pos)
enddef

# Wrapper to do move commands in visual mode.
#
def VisMove(f: string)
  norm! gv
  execute 'call ' .. f .. '()'
enddef

# Map in both normal and visual modes.
#
def MapNormVis(rhs: string, lhs: string)
  execute 'nn <buffer><silent> ' .. rhs .. ' <ScriptCmd>' .. lhs .. '()<CR>'
  execute 'vn <buffer><silent> ' .. rhs .. ' <Esc><ScriptCmd>VisMove(''' .. lhs .. ''')<CR>'
enddef

# Parameters:
#
# - step +1 for right, -1 for left
#
# TODO: multiple lines.
#
def FindCornerOfSyntax(lnum: number, col: number, step: number): number
  var c = col
  var syn = synIDattr(synID(lnum, c, 1), 'name')
  while synIDattr(synID(lnum, c, 1), 'name') ==# syn
    c += step
  endwhile
  return c - step
enddef

# Return the next position of the given syntax name,
# inclusive on the given position.
#
# TODO: multiple lines
#
def FindNextSyntax(lnum: number, col: number, name: string): list<number>
  var c = col
  var step = 1
  while synIDattr(synID(lnum, c, 1), 'name') !=# name
    c += step
  endwhile
  return [lnum, c]
enddef

def FindCornersOfSyntax(lnum: number, col: number): list<number>
  return [FindLeftOfSyntax(lnum, col), FindRightOfSyntax(lnum, col)]
enddef

def FindRightOfSyntax(lnum: number, col: number): number
  return FindCornerOfSyntax(lnum, col, 1)
enddef

def FindLeftOfSyntax(lnum: number, col: number): number
  return FindCornerOfSyntax(lnum, col, -1)
enddef

# Returns:
#
# - a string with the the URL for the link under the cursor
# - an empty string if the cursor is not on a link
#
# TODO
#
# - multiline support
# - give an error if the separator does is not on a link
#
def Markdown_GetUrlForPosition(_lnum: number, _col: number): string
  var lnum = _lnum
  var col = _col
  var syn = synIDattr(synID(lnum, col, 1), 'name')

  if syn ==# 'mkdInlineURL' || syn ==# 'mkdURL' || syn ==# 'mkdLinkDefTarget'
  # Do nothing.
  elseif syn ==# 'mkdLink'
    [lnum, col] = FindNextSyntax(lnum, col, 'mkdURL')
    syn = 'mkdURL'
  elseif syn ==# 'mkdDelimiter'
    var line = getline(lnum)
    var char = line[col - 1]
    if char ==# '<'
      col += 1
    elseif char ==# '>' || char ==# ')'
      col -= 1
    elseif char ==# '[' || char ==# ']' || char ==# '('
      [lnum, col] = FindNextSyntax(lnum, col, 'mkdURL')
    else
      return ''
    endif
  else
    return ''
  endif

  var [left, right] = FindCornersOfSyntax(lnum, col)
  return getline(lnum)[left - 1 : right - 1]
enddef

# Front end for GetUrlForPosition.
#
def OpenUrlUnderCursor()
  var url = Markdown_GetUrlForPosition(line('.'), col('.'))
  if url !=# ''
    if url =~? 'http[s]\?:\/\/[[:alnum:]%\/_#.-]*'
    #Do nothing
    else
      url = expand(expand('%:h') .. '/' .. url)
    endif
    VersionAwareNetrwBrowseX(url)
  else
    echomsg 'The cursor is not on a link.'
  endif
enddef

# We need a definition guard because we invoke 'edit' which will reload this
# script while this function is running. We must not replace it.
if !exists('*EditUrlUnderCursor')
  def EditUrlUnderCursor()
    var editmethod = ''
    # determine how to open the linked file (split, tab, etc)
    if exists('g:vim_markdown_edit_url_in')
      if g:vim_markdown_edit_url_in ==# 'tab'
        editmethod = 'tabnew'
      elseif g:vim_markdown_edit_url_in ==# 'vsplit'
        editmethod = 'vsp'
      elseif g:vim_markdown_edit_url_in ==# 'hsplit'
        editmethod = 'sp'
      else
        editmethod = 'edit'
      endif
    else
      # default to current buffer
      editmethod = 'edit'
    endif
    var url = Markdown_GetUrlForPosition(line('.'), col('.'))
    if url !=# ''
      if get(g:, 'vim_markdown_autowrite', false)
        write
      endif
      var anchor = ''
      if get(g:, 'vim_markdown_follow_anchor', false)
        var parts = split(url, '#', true)
        if parts->len() == 2
          [url, anchor] = parts
          var anchorexpr = get(g:, 'vim_markdown_anchorexpr', '')
          if anchorexpr !=# ''
            anchor = eval(substitute(
                  \ anchorexpr, 'v:anchor',
                  \ escape('"' .. anchor .. '"', '"'), ''))
          endif
        endif
      endif
      if url !=# ''
        var ext = ''
        if get(g:, 'vim_markdown_no_extensions_in_markdown', false)
          # use another file extension if preferred
          if exists('g:vim_markdown_auto_extension_ext')
            ext = '.' .. g:vim_markdown_auto_extension_ext
          else
            ext = '.md'
          endif
        endif
        url = fnameescape(fnamemodify(expand('%:h') .. '/' .. url .. ext, ':.'))
        execute editmethod url
      endif
      if anchor !=# ''
        search(anchor, 's')
      endif
    else
      execute editmethod .. ' <cfile>'
    endif
  enddef
endif

def VersionAwareNetrwBrowseX(url: string)
  if has('patch-7.4.567')
    netrw#BrowseX(url, false)
  else
    netrw#NetrwBrowseX(url, false)
  endif
enddef

def MapNotHasmapto(lhs: string, rhs: string)
  if !hasmapto('<Plug>' .. rhs)
    execute 'nmap <buffer>' .. lhs .. ' <Plug>' .. rhs
    execute 'vmap <buffer>' .. lhs .. ' <Plug>' .. rhs
  endif
enddef

MapNormVis('<Plug>Markdown_MoveToNextHeader', 'MoveToNextHeader')
MapNormVis('<Plug>Markdown_MoveToPreviousHeader', 'MoveToPreviousHeader')
MapNormVis('<Plug>Markdown_MoveToNextSiblingHeader', 'MoveToNextSiblingHeader')
MapNormVis('<Plug>Markdown_MoveToPreviousSiblingHeader', 'MoveToPreviousSiblingHeader')
nnoremap <Plug>Markdown_OpenUrlUnderCursor <ScriptCmd>OpenUrlUnderCursor()<CR>
nnoremap <Plug>Markdown_EditUrlUnderCursor <ScriptCmd>EditUrlUnderCursor()<CR>

if !get(g:, 'vim_markdown_no_default_key_mappings', false)
  MapNotHasmapto(']]', 'Markdown_MoveToNextHeader')
  MapNotHasmapto('[[', 'Markdown_MoveToPreviousHeader')
  MapNotHasmapto('][', 'Markdown_MoveToNextSiblingHeader')
  MapNotHasmapto('[]', 'Markdown_MoveToPreviousSiblingHeader')
  MapNotHasmapto('gx', 'Markdown_OpenUrlUnderCursor')
  MapNotHasmapto('ge', 'Markdown_EditUrlUnderCursor')
endif

command! -buffer -range=% HeaderDecrease call HeaderDecrease(<line1>, <line2>)
command! -buffer -range=% HeaderIncrease call HeaderDecrease(<line1>, <line2>, true)
command! -buffer -range=% SetexToAtx call SetexToAtx(<line1>, <line2>)
command! -buffer -range TableFormat call TableFormat()
command! -buffer Title execute "normal! i# " .. expand('%:t:r') .. "\<Esc>"
command! -buffer Toc call Toc()
command! -buffer Toch call Toc('horizontal')
command! -buffer Tocv call Toc('vertical')
command! -buffer Toct call Toc('tab')
command! -buffer -nargs=? InsertToc call InsertToc('bullets', <args>)
command! -buffer -nargs=? InsertNToc call InsertToc('numbers', <args>)

# Heavily based on vim-notes - http://peterodding.com/code/vim/notes/
var filetype_dict: dict<string> = {}
if exists('g:vim_markdown_fenced_languages')
  for filetype in g:vim_markdown_fenced_languages
    var key = matchstr(filetype, '[^=]*')
    var val = matchstr(filetype, '[^=]*$')
    filetype_dict[key] = val
  endfor
else
  filetype_dict = {
    'c++': 'cpp',
    'viml': 'vim',
    'bash': 'sh',
    'shell': 'sh',
    'ini': 'dosini'
  }
endif

def MarkdownHighlightSources(force: bool)
  # Syntax highlight source code embedded in notes.
  # Look for code blocks in the current file
  var filetypes: dict<number> = {}
  for line in getline(1, '$')
    var ft = matchstr(line, '\(`\{3,}\|\~\{3,}\)\s*\zs[0-9A-Za-z_+-]*\ze.*')
    if !empty(ft) && ft !~# '^\d*$' | filetypes[ft] = 1 | endif
  endfor
  if !exists('b:mkd_known_filetypes')
    b:mkd_known_filetypes = {}
  endif
  if !exists('b:mkd_included_filetypes')
    # set syntax file name included
    b:mkd_included_filetypes = {}
  endif
  if !force && (b:mkd_known_filetypes == filetypes || filetypes->empty())
    return
  endif

  # Now we're ready to actually highlight the code blocks.
  var startgroup = 'mkdCodeStart'
  var endgroup = 'mkdCodeEnd'
  for ft in filetypes->keys()
    if force || !b:mkd_known_filetypes->has_key(ft)
      var filetype: string
      if filetype_dict->has_key(ft)
        filetype = filetype_dict[ft]
      else
        filetype = ft
      endif
      var group = 'mkdSnippet' .. toupper(substitute(filetype, '[+-]', '_', 'g'))
      var include: string
      if !b:mkd_included_filetypes->has_key(filetype)
        include = SyntaxInclude(filetype)
        b:mkd_included_filetypes[filetype] = 1
      else
        include = '@' .. toupper(filetype)
      endif
      var command_backtick = 'syntax region %s matchgroup=%s start="^\s*`\{3,}\s*%s.*$" matchgroup=%s end="\s*`\{3,}$" keepend contains=%s%s'
      var command_tilde    = 'syntax region %s matchgroup=%s start="^\s*\~\{3,}\s*%s.*$" matchgroup=%s end="\s*\~\{3,}$" keepend contains=%s%s'
      execute printf(command_backtick, group, startgroup, ft, endgroup, include, has('conceal') && get(g:, 'vim_markdown_conceal', true) && get(g:, 'vim_markdown_conceal_code_blocks', true) ? ' concealends' : '')
      execute printf(command_tilde,    group, startgroup, ft, endgroup, include, has('conceal') && get(g:, 'vim_markdown_conceal', true) && get(g:, 'vim_markdown_conceal_code_blocks', true) ? ' concealends' : '')
      execute printf('syntax cluster mkdNonListItem add=%s', group)

      b:mkd_known_filetypes[ft] = 1
    endif
  endfor
enddef

def SyntaxInclude(filetype: string): string
  # Include the syntax highlighting of another {filetype}.
  var grouplistname = '@' .. toupper(filetype)
  # Unset the name of the current syntax while including the other syntax
  # because some syntax scripts do nothing when "b:current_syntax" is set
  var syntax_save: string
  if exists('b:current_syntax')
    syntax_save = b:current_syntax
    unlet b:current_syntax
  endif
  try
    execute 'syntax include' grouplistname 'syntax/' .. filetype .. '.vim'
    execute 'syntax include' grouplistname 'after/syntax/' .. filetype .. '.vim'
  catch /E484/
    # Ignore missing scripts
  endtry
  # Restore the name of the current syntax
  if exists('syntax_save')
    b:current_syntax = syntax_save
  elseif exists('b:current_syntax')
    unlet b:current_syntax
  endif
  return grouplistname
enddef

def IsHighlightSourcesEnabledForBuffer(): bool
  # Enable for markdown buffers, and for liquid buffers with markdown format
  return &filetype =~# 'markdown' || get(b:, 'liquid_subtype', '') =~# 'markdown'
enddef

def MarkdownRefreshSyntax(force: bool)
  # Use != to compare &syntax's value to use the same logic run on
  # $VIMRUNTIME/syntax/synload.vim.
  #
  # vint: next-line -ProhibitEqualTildeOperator
  if IsHighlightSourcesEnabledForBuffer() && line('$') > 1 && &syntax != 'OFF'
    MarkdownHighlightSources(force)
  endif
enddef

def MarkdownClearSyntaxVariables()
  if IsHighlightSourcesEnabledForBuffer()
    unlet! b:mkd_included_filetypes
  endif
enddef

augroup Mkd
  # These autocmd calling MarkdownRefreshSyntax need to be kept in sync with
  # the autocmds calling MarkdownSetupFolding in after/ftplugin/markdown.vim.
  autocmd! * <buffer>
  autocmd BufWinEnter <buffer> call MarkdownRefreshSyntax(true)
  autocmd BufUnload <buffer> call MarkdownClearSyntaxVariables()
  autocmd BufWritePost <buffer> call MarkdownRefreshSyntax(false)
  autocmd InsertEnter,InsertLeave <buffer> call MarkdownRefreshSyntax(false)
  autocmd CursorHold,CursorHoldI <buffer> call MarkdownRefreshSyntax(false)
augroup END
