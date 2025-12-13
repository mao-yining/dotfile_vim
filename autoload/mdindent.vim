vim9script

const LISTINDENT = 4  # TODO: Consider implications of changing this.
const NOCHANGE = -1   # indentexpr value of -1 means no-op.
const list_item_head = '^\s*[*+-] \+'

def GetPDMIndent(lnum: number)
	# Find the nearest non-blank line before the current one.
	const plnum = prevnonblank(lnum)

	if plnum == 0 # This is the first non-empty line, do not indent.
		return 0
	endif

	if (lnum - plnum) > 1
		# Assume more than one blank line is a semantic break, leave
		# the indentation alone
		return NOCHANGE
	endif

	# If we got this far, we need to look a little closer
	const current_line = getline(lnum)
	const previous_nbline = getline(plnum)		# previous non-blank

	# Checking whether we are in a list
	if current_line =~# list_item_head
		# Do not change the indentation, assume it is as intended
		return NOCHANGE
	endif

	if previous_nbline =~# list_item_head
		# Indent according to constant value
		return LISTINDENT # TODO: nested lists?
	endif

	# Otherwise, leave indentation up to the user.
	return NOCHANGE
enddef
