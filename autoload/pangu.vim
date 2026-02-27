vim9script
# Name: autoload/pangu.vim
# Author: Mao-Yining <mao.yining@outlook.com>
# Desc: 中文文档语言规范检查工具
# 参考：中文文案排版指北（简体中文版）<https://github.com/mzlogin/chinese-copywriting-guidelines>
# Usage:
# import autoload 'pangu.vim'
# command -nargs=* -range Pangu <line1>,<line2> pangu.PanGuSpacingCore("RANGE", <line1>, <line2>)
# command -nargs=* PanguAll pangu.PanGuSpacingCore("ALL", 1, line("$"))
# command -nargs=0 PanguDisable let g:pangu_enabled = false
# command -nargs=0 PanguEnable let g:pangu_enabled = true

# 默认配置
g:pangu_enabled = get(g:, 'pangu_enabled', true)
g:pangu_rule_fullwidth_punctuation = get(g:, 'pangu_rule_fullwidth_punctuation', true)
g:pangu_rule_duplicate_punctuation = get(g:, 'pangu_rule_duplicate_punctuation', true)
g:pangu_rule_fullwidth_alphabet = get(g:, 'pangu_rule_fullwidth_alphabet', true)
g:pangu_rule_spacing = get(g:, 'pangu_rule_spacing', true)
g:pangu_rule_spacing_punctuation = get(g:, 'pangu_rule_spacing_punctuation', false)
g:pangu_rule_trailing_whitespace = get(g:, 'pangu_rule_trailing_whitespace', true)
g:pangu_rule_date = get(g:, 'pangu_rule_date', 2)
g:pangu_rule_remove_zero_width_whitespace = get(g:, 'pangu_rule_remove_zero_width_whitespace', true)

# g:pangu_punctuation_brackets = get(g:, 'pangu_punctuation_brackets', ["【", "】"])
g:pangu_punctuation_ellipsis = get(g:, 'pangu_punctuation_ellipsis', "······")

export def PanGuSpacingCore(mode: string, firstline: number, lastline: number)
	if search("PANGU_DISABLE", 'nw') > 0 || &filetype == "diff"
		return
	endif

	const savedpos = getpos("v")
	const save_regexpengine = &regexpengine
	&regexpengine = 2
	const save_gdefault = &gdefault
	setlocal nogdefault

	const lfirstline = mode == "ALL" ? 1 : firstline
	const llastline = mode == "ALL" ? line('$') : lastline

	# 汉字后的标点符号，转成全角符号。
	if g:pangu_rule_fullwidth_punctuation
		silent! exe $':{lfirstline},{llastline}s/\([\u4e00-\u9fa5\u3040-\u30FF]\)\.\($\|\s\+\)/\1。/g'
		silent! exe $':{lfirstline},{llastline}s/\([\u4e00-\u9fa5\u3040-\u30FF]\),\s*/\1，/g'
		silent! exe $':{lfirstline},{llastline}s/\([\u4e00-\u9fa5\u3040-\u30FF]\);\s*/\1；/g'
		silent! exe $':{lfirstline},{llastline}s/\([\u4e00-\u9fa5\u3040-\u30FF]\)!\s*/\1！/g'
		silent! exe $':{lfirstline},{llastline}s/\([\u4e00-\u9fa5\u3040-\u30FF]\):\s*/\1：/g'
		silent! exe $':{lfirstline},{llastline}s/\([\u4e00-\u9fa5\u3040-\u30FF]\)?\s*/\1？/g'
		silent! exe $':{lfirstline},{llastline}s/\([\u4e00-\u9fa5\u3040-\u30FF]\)\\\s*/\1、/g'

		silent! exe $':{lfirstline},{llastline}s/(\([\u4e00-\u9fa5\u3040-\u30FF][^()]*\|[^()]*[\u4e00-\u9fa5\u3040-\u30FF]\))/（\1）/g'
		silent! exe $':{lfirstline},{llastline}s/(\([\u4e00-\u9fa5\u3040-\u30FF]\)/（\1/g'
		silent! exe $':{lfirstline},{llastline}s/\([\u4e00-\u9fa5\u3040-\u30FF]\))/\1）/g'

	# 	const bracket_left = g:pangu_punctuation_brackets[0]
	# 	const bracket_right = g:pangu_punctuation_brackets[1]

	# 	silent! exe $':{lfirstline},{llastline}s/{bracket_left}/〘/g'
	# 	silent! exe $':{lfirstline},{llastline}s/{bracket_right}/〙/g'

	# 	silent! exe $':{lfirstline},{llastline}s/\[\([\u4e00-\u9fa5\u3040-\u30FF][^[\]]*\|[^[\]]*[\u4e00-\u9fa5\u3040-\u30FF]\)\]/{bracket_left}\1{bracket_right}/g'
	# 	silent! exe $':{lfirstline},{llastline}s/\[\([\u4e00-\u9fa5\u3040-\u30FF]\)/{bracket_left}\1/g'
	# 	silent! exe $':{lfirstline},{llastline}s/\([\u4e00-\u9fa5\u3040-\u30FF]\)\]/\1{bracket_right}/g'

	# 	silent! exe $':{lfirstline},{llastline}s/<\([\u4e00-\u9fa5\u3040-\u30FF][^<>]*\|[^<>]*[\u4e00-\u9fa5\u3040-\u30FF]\)>/《\1》/g'
	# 	silent! exe $':{lfirstline},{llastline}s/<\([\u4e00-\u9fa5\u3040-\u30FF]\)/《\1/g'
	# 	silent! exe $':{lfirstline},{llastline}s/\([\u4e00-\u9fa5\u3040-\u30FF]\)>/\1》/g'

	# 	silent! exe $':{lfirstline},{llastline}s/<《/《/g'
	# 	silent! exe $':{lfirstline},{llastline}s/》>/》/g'

	# 	silent! exe $':{lfirstline},{llastline}s/[{bracket_left}[]\([^{bracket_right}\]]\+\)[{bracket_right}\]]][{bracket_left}[]\([^{bracket_right}\]]\+\)[{bracket_right}\]]/[\1][\2]/g'
	# 	silent! exe $':{lfirstline},{llastline}s/[{bracket_left}[]\([^{bracket_right}\]]\+\)[{bracket_right}\]]][（(]\([^{bracket_right})]\+\)[）)]/[\1](\2)/g'

	# 	silent! exe $':{lfirstline},{llastline}s/\[[{bracket_left}[]\([^{bracket_right}\]]\+\)[{bracket_right}\]]\]/[[\1]]/g'
	# 	silent! exe $':{lfirstline},{llastline}s/[{bracket_left}[]\(https\?:\/\/\S\+\s\+[^{bracket_right}\]]\+\)[{bracket_right}\]]/[\1]/g'

	# 	silent! exe $':{lfirstline},{llastline}s/〘/{bracket_left}/g'
	# 	silent! exe $':{lfirstline},{llastline}s/〙/{bracket_right}/g'
	endif

	if g:pangu_rule_duplicate_punctuation
		silent! exe $':{lfirstline},{llastline}s/。\{{[3,]}}/{g:pangu_punctuation_ellipsis}/g'
		silent! exe $':{lfirstline},{llastline}s/\([！？]\)\1\{{3,}}/\1\1\1/g'
		silent! exe $':{lfirstline},{llastline}s/\([。，；：、“”【】〔〕『』〖〗〚〛《》]\)\1\{{1,}}/\1/g'
	endif

	if g:pangu_rule_fullwidth_alphabet
		silent! exe $':{lfirstline},{llastline}s/\([０-９Ａ-Ｚａ-ｚ＠]\)/\=nr2char(char2nr(submatch(0))-65248)/g'
	endif

	if g:pangu_rule_spacing
		silent! exe $':{lfirstline},{llastline}s/\([\u4e00-\u9fa5\u3040-\u30FF]\)\([a-zA-Z0-9]\)/\1 \2/g'
		silent! exe $':{lfirstline},{llastline}s/\([a-zA-Z0-9]\)\([\u4e00-\u9fa5\u3040-\u30FF]\)/\1 \2/g'
	endif

	if g:pangu_rule_spacing_punctuation
		silent! exe $':{lfirstline},{llastline}s/\([\u4e00-\u9fa5\u3040-\u30FF]\)\([@&=\[\$\%\^\-\+(\\]\)/\1 \2/g'
		silent! exe $':{lfirstline},{llastline}s/\([!&;=\]\,\.\:\?\$\%\^\-\+\)]\)\([\u4e00-\u9fa5\u3040-\u30FF]\)/\1 \2/g'
	endif

	if g:pangu_rule_date == 0
		silent! exe $':{lfirstline},{llastline}s/\s*\(\d\{{4,5}}\)\s*年\s*\(\d\{{1,2}}\)\s*月/\1年\2月/g'
		silent! exe $':{lfirstline},{llastline}s/\s*\(\d\{{1,2}}\)\s*月\s*\(\d\{{1,2}}\)\s*日/\1月\2日/g'
		silent! exe $':{lfirstline},{llastline}s/\s*\(\d\{{4,5}}\)\s*年\s*\(\d\{{1,2}}\)\s*月\s*\(\d\{{1,2}}\)\s*日/\1年\2月\3日/g'
		silent! exe $':{lfirstline},{llastline}s/\(\(\d\{{4,5}}年\)\?\d\{{1,2}}月\(\d\{{1,2}}日\)\?\)\s\+\([\u4e00-\u9fa5\u3040-\u30FF]\)/\1\4/g'
	elseif g:pangu_rule_date == 1
		silent! exe $':{lfirstline},{llastline}s/\(\d\{{4,5}}\)\s*年\s*\(\d\{{1,2}}\)\s*月/\1年\2月/g'
		silent! exe $':{lfirstline},{llastline}s/\(\d\{{1,2}}\)\s*月\s*\(\d\{{1,2}}\)\s\+日/\1月\2日/g'
		silent! exe $':{lfirstline},{llastline}s/\(\d\{{4,5}}\)\s*年\s*\(\d\{{1,2}}\)\s*月\s*\(\d\{{1,2}}\)\s\+日/\1年\2月\3日/g'
		silent! exe $':{lfirstline},{llastline}s/\(\(\d\{{4,5}}年\)\?\d\{{1,2}}月\(\d\{{1,2}}日\)\?\)\([\u4e00-\u9fa5\u3040-\u30FF]\)/\1 \4/g'
	endif

	if g:pangu_rule_trailing_whitespace
		silent! exe $':{lfirstline},{llastline}s/^ \[/[/'
		silent! exe $':{lfirstline},{llastline}s/\s\+$//'
	endif

	if g:pangu_rule_remove_zero_width_whitespace
		silent! exe $':{lfirstline},{llastline}s/[\u200c\u200b\u200d\u202c\u2060\u2061\u2062\u2063\u2064\ufeff]//g'
	endif

	&regexpengine = save_regexpengine
	if save_gdefault
		setlocal gdefault
	endif
	setpos(".", savedpos)
enddef
