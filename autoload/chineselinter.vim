vim9script
# Name: autoload\chineselinter.vim
# Author: Mao-Yining <mao.yining@outlook.com>
# Desc: 中文文档语言规范检查工具
# Derive From: wsdjeg's chineselinter.nvim <https://github.com/wsdjeg/chineselinter.nvim>
# 参考指南：中文文案排版指北（简体中文版）<https://github.com/mzlogin/chinese-copywriting-guidelines>
# Usage:
#	import autoload 'chineselinter.vim'
#	command! -nargs=0 CheckChinese chineselinter.Check()

const ignored_errors = [ 'E018' ]

# Unicode 字符定义
const CHINESE_PUNCTUATION = '[\u2010-\u201f\u2026\uff01-\uff0f\uff1a-\uff1f\uff3b-\uff40\uff5b-\uff5e]'
const PUNCTUATION_EN = '[､,:;?!-]'
const PUNCTUATION_CN = '[、，：；。？！‘’“”（）《》『』＂＇／＜＞＝［］｛｝【】]'
const CHARS_CN = '[\u4e00-\u9fff]'
const NUMBERS = '\d'
const NUMBERS_CN = '[\uff10-\uff19]'
const CHARS_EN = '\a'
const SYMBOL = '[%‰‱\u3371-\u33df\u2100-\u2109]'
const BLANK = '\(\s\|[\u3000]\)'

# 检查规则
const RULES = {
	E001: [
		{ text: '中文字符后存在英文标点', pattern: CHARS_CN .. '[､,:;?!]' },
	],
	E002: [
		{ text: '中文与英文之间没有空格', pattern: CHARS_CN .. CHARS_EN },
		{ text: '英文与中文之间没有空格', pattern: CHARS_EN .. CHARS_CN },
	],
	E003: [
		{ text: '中文与数字之间没有空格', pattern: CHARS_CN .. NUMBERS },
		{ text: '数字与中文之间没有空格', pattern: NUMBERS .. CHARS_CN },
	],
	E004: [
		{ text: '中文标点前存在空格', pattern: BLANK .. '\+\ze' .. CHINESE_PUNCTUATION },
		{ text: '中文标点后存在空格', pattern: CHINESE_PUNCTUATION .. '\zs' .. BLANK .. '\+' },
	],
	E005: [
		{ text: '行尾有空格', pattern: BLANK .. '\+$' },
	],
	E006: [
		{ text: '数字和单位之间有空格', pattern: NUMBERS .. '\zs' .. BLANK .. '\+\ze' .. SYMBOL },
	],
	E007: [
		{ text: '数字使用了全角数字', pattern: NUMBERS_CN .. '\+' },
	],
	E008: [
		{ text: '汉字之间存在空格', pattern: CHARS_CN .. '\zs' .. BLANK .. '\+\ze' .. CHARS_CN },
	],
	E009: [
		{ text: '中文标点符号重复', pattern: '\(' .. PUNCTUATION_CN .. '\)\1\+' },
		{ text: '连续多个中文标点符号', pattern: '[、，：；。！？]\{2,}' },
	],
	E010: [
		{ text: '英文标点前侧存在空格', pattern: BLANK .. '\+\ze' .. '[､,:;?!]' },
		{ text: '英文标点符号后侧的空格数量多于 1 个', pattern: '[､,:;?!]' .. BLANK .. '\{2,}' },
		{ text: '英文标点与英文之间没有空格', pattern: '[､,:;?!]' .. CHARS_EN },
		{ text: '英文标点与中文之间没有空格', pattern: '[､,:;?!]' .. CHARS_CN },
		{ text: '英文标点与数字之间没有空格', pattern: '[､,;?!]' .. NUMBERS },
	],
	E011: [
		{ text: '中文与英文之间空格数量多于 1 个', pattern: '\%#=2' .. CHARS_CN .. '\zs' .. BLANK .. '\{2,}\ze' .. CHARS_EN },
		{ text: '英文与中文之间空格数量多于 1 个', pattern: '\%#=2' .. CHARS_EN .. '\zs' .. BLANK .. '\{2,}\ze' .. CHARS_CN },
	],
	E012: [
		{ text: '中文与数字之间空格数量多于 1 个', pattern: '\%#=2' .. CHARS_CN .. '\zs' .. BLANK .. '\{2,}\ze' .. NUMBERS },
		{ text: '数字与中文之间空格数量多于 1 个', pattern: '\%#=2' .. NUMBERS .. '\zs' .. BLANK .. '\{2,}\ze' .. CHARS_CN },
	],
	E013: [
		{ text: '英文与数字之间没有空格', pattern: CHARS_EN .. NUMBERS },
		{ text: '数字与英文之间没有空格', pattern: NUMBERS .. CHARS_EN },
	],
	E014: [
		{ text: '英文与数字之间空格数量多于 1 个', pattern: CHARS_EN .. '\zs' .. BLANK .. '\{2,}\ze' .. NUMBERS },
		{ text: '数字与英文之间空格数量多于 1 个', pattern: NUMBERS .. '\zs' .. BLANK .. '\{2,}\ze' .. CHARS_EN },
	],
	E015: [
		{ text: '英文标点符号重复', pattern: '\(' .. PUNCTUATION_EN .. BLANK .. '*\)\1\+' },
		{ text: '连续多个英文标点符号', pattern: '\(' .. '[,:;?!-]' .. BLANK .. '*\)\{2,}' },
	],
	E016: [
		{ text: '连续的空行数量大于 2 行', pattern: '^\(' .. BLANK .. '*\n\)\{3,}' },
	],
	E017: [
		{ text: '数字之间存在空格', pattern: NUMBERS .. '\zs' .. BLANK .. '\+\ze' .. NUMBERS },
	],
	E018: [
		{ text: '行首有空格', pattern: '^' .. BLANK .. '\+' },
	],
	E019: [
		{ text: '存在不应出现在行首的标点', pattern: '^' .. '[､,:;｡?!\/)]】}’”、，：；。？！／》』）］】｝ }' },
		{ text: '存在不应出现在行尾的标点', pattern: '[([【{‘“／《『（［【｛]' .. '$' },
	],
	E020: [
		{ text: '省略号"…"的数量只有 1 个', pattern: '\(^\|[^…]\)' .. '\zs' .. '…' .. '\ze' .. '\([^…]\|$\)' },
		{ text: '省略号"…"的数量大于 2 个', pattern: '…\{3,}' },
	],
	E021: [
		{ text: '破折号"—"的数量只有 1 个', pattern: '\(^\|[^—]\)' .. '\zs' .. '—' .. '\ze' .. '\([^—]\|$\)' },
		{ text: '破折号"—"的数量大于 2 个', pattern: '—\{3,}' },
	],
}

const CODE_BLOCK_FLAG = {
	markdown: {
		from: '^\(```\|---\)',
		to: '^\(```\|---\)',
	},
}

var code_block: dict<any>

def FindErrors(line: string, rule: list<dict<any>>): list<dict<any>>
	var errors: list<dict<any>> = []

	for rule_item in rule
		try
			var regex = match(line, rule_item.pattern)
			if regex != -1
				errors->add({
					col: regex,
					text: rule_item.text,
				})
			endif
		catch
			echohl ErrorMsg
			echom printf('%s regex is error', rule_item.text)
			echohl None
		endtry
	endfor

	return errors
enddef

export def Check()
	const bufnr = bufnr()
	const ft = &filetype
	var is_code_block = false

	if has_key(CODE_BLOCK_FLAG, ft)
		code_block = CODE_BLOCK_FLAG[ft]
	else
		code_block = {}
	endif

	var lines = getline(1, '$')
	var lint_results: list<dict<any>>
	var line_num = 1

	for line in lines
		if !empty(code_block)
			if !is_code_block && match(line, code_block.from) >= 0
				is_code_block = true
				line_num += 1
				continue
			elseif is_code_block && match(line, code_block.to) >= 0
				is_code_block = false
				line_num += 1
				continue
			elseif is_code_block
				line_num += 1
				continue
			endif
		endif

		for [err_code, rule] in items(RULES)
			if index(ignored_errors, err_code) == -1
				var errors = FindErrors(line, rule)
				if !empty(errors)
					for error in errors
						lint_results->add({
							bufnr: bufnr,
							lnum: line_num,
							col: error.col + 1,
							text: err_code .. ' ' .. error.text,
							type: 'E',
							nr: str2nr(err_code[1 :]),
						})
					endfor
				endif
			endif
		endfor

		line_num += 1
	endfor

	setqflist(lint_results)

	if !empty(lint_results)
		copen
	else
		cclose
	endif
enddef
