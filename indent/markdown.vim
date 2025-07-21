vim9script noclear
if exists('b:did_indent') | finish | endif
b:did_indent = 1

setlocal indentexpr=GetMarkdownIndent()
setlocal nolisp
setlocal autoindent

# Automatically continue blockquote on line break
setlocal formatoptions+=r
setlocal comments=b:>
if get(g:, 'vim_markdown_auto_insert_bullets', 1)
  # Do not automatically insert bullets when auto-wrapping with text-width
  setlocal formatoptions-=c
  # Accept various markers as bullets
  setlocal comments+=b:*,b:+,b:-
endif

# Only define the function once
if exists('*GetMarkdownIndent') | finish | endif

def IsMkdCode(lnum: number): bool
  var name = synIDattr(synID(lnum, 1, 0), 'name')
  return name =~# '^mkd\%(Code$\|Snippet\)' || name != '' && name !~? '^\%(mkd\|html\)'
enddef

def IsLiStart(line: string): bool
  return line !~# '^ *\([*-]\)\%( *\1\)\{2}\%( \|\1\)*$' &&
    line =~# '^\s*[*+-] \+'
enddef

def IsHeaderLine(line: string): bool
  return line =~# '^\s*#'
enddef

def IsBlankLine(line: string): bool
  return line =~# '^$'
enddef

def PrevNonBlank(lnum: number): number
  var i = lnum
  while i > 1 && IsBlankLine(getline(i))
    i -= 1
  endwhile
  return i
enddef

def GetMarkdownIndent(): number
  if v:lnum > 2 && IsBlankLine(getline(v:lnum - 1)) && IsBlankLine(getline(v:lnum - 2))
    return 0
  endif
  var list_ind = get(g:, 'vim_markdown_new_list_item_indent', 4)
  # Find a non-blank line above the current line.
  var lnum = PrevNonBlank(v:lnum - 1)
  # At the start of the file use zero indent.
  if lnum == 0 | return 0 | endif
  var ind = indent(lnum)
  var line = getline(lnum)    # Last line
  var cline = getline(v:lnum) # Current line
  if IsLiStart(cline)
    # Current line is the first line of a list item, do not change indent
    return indent(v:lnum)
  elseif IsHeaderLine(cline) && !IsMkdCode(v:lnum)
    # Current line is the header, do not indent
    return 0
  elseif IsLiStart(line)
    if IsMkdCode(lnum)
      return ind
    else
      # Last line is the first line of a list item, increase indent
      return ind + list_ind
    endif
  else
    return ind
  endif
enddef
