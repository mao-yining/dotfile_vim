vim9script

# Name: autoload/text.vim
# Author: Maxim Kim <habamax@gmail.com>
# Maintainer: Mao-Yining <mao-yining@outlook.com>
# Desc: Text manipulation functions.

# Fix text:
# * replace non-breaking spaces with spaces
# * replace multiple spaces with a single space (preserving indent)
# * remove spaces between closed braces: ) ) -> ))
# * remove space before closed brace: word ) -> word)
# * remove space after opened brace: ( word -> (word
# * remove space at the end of line
# Usage:
# command! -range FixSpaces call text#fix_spaces(<line1>,<line2>)
export def FixSpaces(line1: number, line2: number)
	var view = winsaveview()
	defer winrestview(view)
	# replace non-breaking space to space first
	exe printf('silent :%d,%ds/\%%xA0/ /ge', line1, line2)
	# replace multiple spaces to a single space (preserving indent)
	exe printf('silent :%d,%ds/\S\+\zs\(\s\|\%%xa0\)\+/ /ge', line1, line2)
	# remove spaces between closed braces: ) ) -> ))
	exe printf('silent :%d,%ds/)\s\+)\@=/)/ge', line1, line2)
	# remove spaces between opened braces: ( ( -> ((
	exe printf('silent :%d,%ds/(\s\+(\@=/(/ge', line1, line2)
	# remove space before closed brace: word ) -> word)
	exe printf('silent :%d,%ds/\s)/)/ge', line1, line2)
	# remove space after opened brace: ( word -> (word
	exe printf('silent :%d,%ds/(\s/(/ge', line1, line2)
	# remove space at the end of line
	exe printf('silent :%d,%ds/\s*$//ge', line1, line2)
enddef

# Dates (text object and stuff)
var mons_en = ['Jan', 'Feb', 'Mar', 'Apr',
	'May', 'Jun', 'Jul', 'Aug',
	'Sep', 'Oct', 'Nov', 'Dec']
var months_en = ['January',   'February', 'March',    'April',
	'May',       'June',     'July',     'August',
	'September', 'October',  'November', 'December']
var months_cn = ['一月', '二月', '三月',   '四月',
	'五月', '六月', '七月',   '八月',
	'九月', '十月', '十一月', '十二月']

var months = extend(months_en, months_cn)
months = extend(months, mons_en)
g:months = copy(months)

# * ISO-8601 2020-03-21 -- 2020-06-30
# * RU 21 марта 2020
# * EN 10 December 2012
# * EN December 10, 2012
# * EN December 10 2012
# * EN 10 Dec 2012
# * EN Dec 10, 2012
# * EN Dec 10 2012
# Usage:
# xnoremap <silent> id :<C-u>call text#ObjDate(1)<CR>
# onoremap id :<C-u>normal vid<CR>
# xnoremap <silent> ad :<C-u>call text#ObjDate(0)<CR>
# onoremap ad :<C-u>normal vad<CR>
export def ObjDate(inner: bool)
	var view = winsaveview()
	var cword = expand("<cword>")
	if  cword =~ '\d\{4}'
		var rx = '\%(\D\d\{1,2}\s\+\%(' .. join(months, '\|') .. '\)\)'
		rx ..= '\|'
		rx ..= '\%(\s*\%(' .. join(months, '\|') .. '\)\s\+\d\{1,2},\?\)'
		if !search(rx, 'bcW', line('.'))
			search('\s*\D', 'bcW', line('.'))
		endif
	elseif cword =~ join(months, '\|')
		search('^\|\D\ze\d\{1,2}\s\+', 'bceW')
	elseif cword =~ '\d\{1,2}'
		if !search('\%(' .. join(months, '\|') .. '\)\s\+\d\{1,2}', 'bcW')
			search('^\|[^0-9\-]', 'becW')
		endif
	endif

	var rxdate = '\%(\d\{4}-\d\{2}-\d\{2}\)'
	rxdate ..= '\|'
	rxdate ..= '\%(\d\{1,2}\s\+\%(' .. join(months, '\|') .. '\)\s\+\d\{4}\)'
	rxdate ..= '\|'
	rxdate ..= '\%(\%(' .. join(months, '\|') .. '\)\s\+\d\{1,2},\?\s\+\d\{4}\)'
	if !inner
		rxdate = '\s*\%(' .. rxdate .. '\)\s*'
	endif

	if search(rxdate, 'cW') > 0
		normal v
		search(rxdate, 'ecW')
		return
	endif
	winrestview(view)
enddef

# number text object
export def ObjNumber()
	var rx_num = '\d\+\(\.\d\+\)*'
	if search(rx_num, 'ceW') > 0
		normal! v
		search(rx_num, 'bcW')
	endif
enddef

# Line text object
export def ObjLine(inner: bool)
	if inner
		normal! g_v^
	else
		normal! $v0
	endif
enddef

# Indent text object
# Usage:
# import autoload 'text.vim'
# onoremap <silent>ii <scriptcmd>text.ObjIndent(v:true)<CR>
# onoremap <silent>ai <scriptcmd>text.ObjIndent(v:false)<CR>
# xnoremap <silent>ii <esc><scriptcmd>text.ObjIndent(v:true)<CR>
# xnoremap <silent>ai <esc><scriptcmd>text.ObjIndent(v:false)<CR>
export def ObjIndent(inner: bool)
	var ln_start: number
	var ln_end: number
	if getline('.') =~ '^\s*$'
		ln_start = prevnonblank('.') ?? 1
	else
		ln_start = line('.')
	endif

	var indent = indent(ln_start)

	while indent == 0 && ln_start < line('$')
		ln_start = nextnonblank(ln_start + 1) ?? line('$')
		indent = indent(ln_start)
	endwhile

	if indent == 0
		return
	endif

	ln_end = ln_start

	while ln_start > 0 && indent(ln_start) >= indent
		ln_start = prevnonblank(ln_start - 1)
	endwhile

	while ln_end <= line('$') && indent(ln_end) >= indent
		ln_end = nextnonblank(ln_end + 1) ?? line('$') + 1
	endwhile

	if inner
		ln_start = nextnonblank(ln_start + 1) ?? line('$') + 1
		ln_end = prevnonblank(ln_end - 1)
	else
		ln_start += 1
		ln_end -= 1
	endif

	if ln_end < ln_start
		ln_end = ln_start
	endif

	exe ":" ln_end
	normal! V
	exe ":" ln_start
enddef

# 26 simple text objects
# ----------------------
# i_ i. i: i, i; i| i/ i\ i* i+ i- i# i<tab>
# a_ a. a: a, a; a| a/ a\ a* a+ a- a# a<tab>
# Usage:
# for char in [ '_', '.', ':', ',', ';', '<bar>', '/', '<bslash>', '*', '+', '-', '#', '<tab>' ]
#     execute $"xnoremap <silent> i{char} <esc><scriptcmd>text.Obj('{char}', 1)<CR>"
#     execute $"xnoremap <silent> a{char} <esc><scriptcmd>text.Obj('{char}', 0)<CR>"
#     execute $"onoremap <silent> i{char} :normal vi{char}<CR>"
#     execute $"onoremap <silent> a{char} :normal va{char}<CR>"
# endfor
export def Obj(char: string, inner: bool)
	var lnum = line('.')
	var echar = escape(char, '.*\')
	if (search('^\|' .. echar, 'cnbW', lnum) > 0 && search(echar, 'W', lnum) > 0)
			|| (search(echar, 'nbW', lnum) > 0 && search(echar .. '\|$', 'cW', lnum) > 0)
		if inner
			search('[^' .. escape(char, '\') .. ']', 'cbW', lnum)
		endif
		normal! v
		search('^\|' .. echar, 'bW', lnum)
		if inner
			search('[^' .. escape(char, '\') .. ']', 'cW', lnum)
		endif
		return
	endif
enddef

# Toggle current word
# nnoremap <silent> <BS> <cmd>call text#Toggle()<CR>
export def Toggle()
	const toggles = {
		true: 'false', false: 'true', True: 'False', False: 'True', TRUE: 'FALSE', FALSE: 'TRUE',
		yes: 'no', no: 'yes', Yes: 'No', No: 'Yes', YES: 'NO', NO: 'YES',
		on: 'off', off: 'on', On: 'Off', Off: 'On', ON: 'OFF', OFF: 'ON',
		open: 'close', close: 'open', Open: 'Close', Close: 'Open',
		dark: 'light', light: 'dark',
		width: 'height', height: 'width',
		first: 'last', last: 'first',
		top: 'right', right: 'bottom', bottom: 'left', left: 'center', center: 'top',
	}
	if toggles->has_key(expand("<cword>"))
		execute 'normal! "_ciw' .. toggles[expand("<cword>")]
	endif
enddef

# Encode/Decode
# Usage:
# nmap <expr> [y  text.TransformSetup('string_encode')
# xmap <expr> [y  text.TransformSetup('string_encode')
# nmap <expr> ]y  text.TransformSetup('string_decode')
# xmap <expr> ]y  text.TransformSetup('string_decode')
# nmap <expr> [yy text.TransformSetup('string_encode') .. '_'
# nmap <expr> ]yy text.TransformSetup('string_decode') .. '_'

# nmap <expr> [u  text.TransformSetup('url_encode')
# xmap <expr> [u  text.TransformSetup('url_encode')
# nmap <expr> ]u  text.TransformSetup('url_decode')
# xmap <expr> ]u  text.TransformSetup('url_decode')
# nmap <expr> [uu text.TransformSetup('url_encode') .. '_'
# nmap <expr> ]uu text.TransformSetup('url_decode') .. '_'

# nmap <expr> [x  text.TransformSetup('xml_encode')
# xmap <expr> [x  text.TransformSetup('xml_encode')
# nmap <expr> ]x  text.TransformSetup('xml_decode')
# xmap <expr> ]x  text.TransformSetup('xml_decode')
# nmap <expr> [xx text.TransformSetup('xml_encode') .. '_'
# nmap <expr> ]xx text.TransformSetup('xml_decode') .. '_'
export def TransformSetup(algorithm: string): string
	&opfunc = Transform->function([algorithm])
	return 'g@'
enddef

def Transform(algorithm: string, type: string)
	const sel_save = &selection
	const cb_save = &clipboard
	&selection = 'inclusive'
	&clipboard = &clipboard->substitute('unnamed\|unnamedplus', '', 'g')
	const reg_save = getreginfo('"')

	if type ==# 'line'
		silent exe "normal! '[V']y"
		@" = substitute(@", "\n$", '', '')
	elseif type ==# 'block'
		silent exe "normal! `[\<C-V>`]y"
	else
		silent exe "normal! `[v`]y"
	endif

	if algorithm ==# 'string_encode'
		@" = StringEncode(@")
	elseif algorithm ==# 'string_decode'
		@" = StringDecode(@")
	elseif algorithm ==# 'url_encode'
		@" = UrlEncode(@")
	elseif algorithm ==# 'url_decode'
		@" = UrlDecode(@")
	elseif algorithm ==# 'xml_encode'
		@" = XmlEncode(@")
	elseif algorithm ==# 'xml_decode'
		@" = XmlDecode(@")
	endif

	normal! gvp
	setreg('"', reg_save)
	&selection = sel_save
	&clipboard = cb_save
enddef

def StringEncode(str: string): string
	const map: dict<string> = {"\n": 'n', "\r": 'r', "\t": 't', "\b": 'b', "\f": '\f', '"': '"', '\': '\'}
	return str->substitute("[\001-\033\\\\\"]", '\="\\" .. get(map, submatch(0), printf("%03o", char2nr(submatch(0))))', 'g')
enddef

def StringDecode(str: string): string
	const map = {'n': "\n", 'r': "\r", 't': "\t", 'b': "\b", 'f': "\f", 'e': "\e", 'a': "\001", 'v': "\013", "\n": ''}
	var st = str
	if st =~# '^\s*".\{-\}\\\@<!\%(\\\\\)*"\s*\n\=$'
		st = st->trim()->trim('"')
	endif
	return st->substitute('\\\(\o\{1,3\}\|x\x\{1,2\}\|u\x\{1,4\}\|.\)', '\=map->get(submatch(1), submatch(1) =~? "^[0-9xu]" ? nr2char(submatch(1)->substitute("^[Uu]", "x", "")->str2nr(8)) : submatch(1))', 'g')
enddef

def UrlEncode(str: string): string
	return str->iconv('latin1', 'utf-8')->substitute('[^A-Za-z0-9_.~-]', '\="%" .. char2nr(submatch(0))->printf("%02X")', 'g')
enddef

def UrlDecode(str: string): string
	return str->substitute('%0[Aa]\n$', '%0A', '')
		->substitute('%0[Aa]', '\n', 'g')
		->substitute('+', ' ', 'g')
		->substitute('%\(\x\x\)', '\=nr2char(submatch(1)->str2nr(16))', 'g')
		->iconv('utf-8', 'latin1')
enddef

const html_entities = {
	nbsp: 160, iexcl: 161, cent: 162, pound: 163,
	curren: 164, yen: 165, brvbar: 166, sect: 167,
	uml: 168, copy: 169, ordf: 170, laquo: 171,
	not: 172, shy: 173, reg: 174, macr: 175,
	deg: 176, plusmn: 177, sup2: 178, sup3: 179,
	acute: 180, micro: 181, para: 182, middot: 183,
	cedil: 184, sup1: 185, ordm: 186, raquo: 187,
	frac14: 188, frac12: 189, frac34: 190, iquest: 191,
	Agrave: 192, Aacute: 193, Acirc: 194, Atilde: 195,
	Auml: 196, Aring: 197, AElig: 198, Ccedil: 199,
	Egrave: 200, Eacute: 201, Ecirc: 202, Euml: 203,
	Igrave: 204, Iacute: 205, Icirc: 206, Iuml: 207,
	ETH: 208, Ntilde: 209, Ograve: 210, Oacute: 211,
	Ocirc: 212, Otilde: 213, Ouml: 214, times: 215,
	Oslash: 216, Ugrave: 217, Uacute: 218, Ucirc: 219,
	Uuml: 220, Yacute: 221, THORN: 222, szlig: 223,
	agrave: 224, aacute: 225, acirc: 226, atilde: 227,
	auml: 228, aring: 229, aelig: 230, ccedil: 231,
	egrave: 232, eacute: 233, ecirc: 234, euml: 235,
	igrave: 236, iacute: 237, icirc: 238, iuml: 239,
	eth: 240, ntilde: 241, ograve: 242, oacute: 243,
	ocirc: 244, otilde: 245, ouml: 246, divide: 247,
	oslash: 248, ugrave: 249, uacute: 250, ucirc: 251,
	uuml: 252, yacute: 253, thorn: 254, yuml: 255,
	OElig: 338, oelig: 339, Scaron: 352, scaron: 353,
	Yuml: 376, circ: 710, tilde: 732, ensp: 8194,
	emsp: 8195, thinsp: 8201, zwnj: 8204, zwj: 8205,
	lrm: 8206, rlm: 8207, ndash: 8211, mdash: 8212,
	lsquo: 8216, rsquo: 8217, sbquo: 8218, ldquo: 8220,
	rdquo: 8221, bdquo: 8222, dagger: 8224, Dagger: 8225,
	permil: 8240, lsaquo: 8249, rsaquo: 8250, euro: 8364,
	fnof: 402, Alpha: 913, Beta: 914, Gamma: 915,
	Delta: 916, Epsilon: 917, Zeta: 918, Eta: 919,
	Theta: 920, Iota: 921, Kappa: 922, Lambda: 923,
	Mu: 924, Nu: 925, Xi: 926, Omicron: 927,
	Pi: 928, Rho: 929, Sigma: 931, Tau: 932,
	Upsilon: 933, Phi: 934, Chi: 935, Psi: 936,
	Omega: 937, alpha: 945, beta: 946, gamma: 947,
	delta: 948, epsilon: 949, zeta: 950, eta: 951,
	theta: 952, iota: 953, kappa: 954, lambda: 955,
	mu: 956, nu: 957, xi: 958, omicron: 959,
	pi: 960, rho: 961, sigmaf: 962, sigma: 963,
	tau: 964, upsilon: 965, phi: 966, chi: 967,
	psi: 968, omega: 969, thetasym: 977, upsih: 978,
	piv: 982, bull: 8226, hellip: 8230, prime: 8242,
	Prime: 8243, oline: 8254, frasl: 8260, weierp: 8472,
	image: 8465, real: 8476, trade: 8482, alefsym: 8501,
	larr: 8592, uarr: 8593, rarr: 8594, darr: 8595,
	harr: 8596, crarr: 8629, lArr: 8656, uArr: 8657,
	rArr: 8658, dArr: 8659, hArr: 8660, forall: 8704,
	part: 8706, exist: 8707, empty: 8709, nabla: 8711,
	isin: 8712, notin: 8713, ni: 8715, prod: 8719,
	sum: 8721, minus: 8722, lowast: 8727, radic: 8730,
	prop: 8733, infin: 8734, ang: 8736, and: 8743,
	or: 8744, cap: 8745, cup: 8746, int: 8747,
	there4: 8756, sim: 8764, cong: 8773, asymp: 8776,
	ne: 8800, equiv: 8801, le: 8804, ge: 8805,
	sub: 8834, sup: 8835, nsub: 8836, sube: 8838,
	supe: 8839, oplus: 8853, otimes: 8855, perp: 8869,
	sdot: 8901, lceil: 8968, rceil: 8969, lfloor: 8970,
	rfloor: 8971, lang: 9001, rang: 9002, loz: 9674,
	spades: 9824, clubs: 9827, hearts: 9829, diams: 9830,
	apos: 39
}

def XmlEncode(str: string): string
	return str->substitute('&', '\&amp;', 'g')
		->substitute('<', '\&lt;', 'g')
		->substitute('>', '\&gt;', 'g')
		->substitute('"', '\&quot;', 'g')
		->substitute("'", '\&apos;', 'g')
enddef

def XmlDecode(str: string): string
	return str->substitute('<\%([[:alnum:]-]\+=\%("[^"]*"\|''[^'']*''\)\|.\)\{-\}>', '', 'g')
		->substitute('\c&#\%(0*38\|x0*26\);', '&amp;', 'g')
		->substitute('\c&#\(\d\+\);', '\=nr2char(str2nr(submatch(1)))', 'g')
		->substitute('\c&#\(x\x\+\);', '\=nr2char(submatch(1)->str2nr(8))', 'g')
		->substitute('\c&apos;', "'", 'g')
		->substitute('\c&quot;', '"', 'g')
		->substitute('\c&gt;', '>', 'g')
		->substitute('\c&lt;', '<', 'g')
		->substitute('\C&\(\%(amp;\)\@!\w*\);', '\=nr2char(str2nr(html_entities->get(submatch(1), 63)))', 'g')
		->substitute('\c&amp;', '\&', 'g')
enddef

# paste mode
# Usage:
# nmap [p <ScriptCmd>text.PutLine('[p')<CR>
# nmap ]p <ScriptCmd>text.PutLine(']p')<CR>
# nmap [P <ScriptCmd>text.PutLine('[p')<CR>
# nmap ]P <ScriptCmd>text.PutLine(']p')<CR>
# nmap >P <ScriptCmd>text.PutLine(v:count1 .. '[p')<CR>>']
# nmap >p <ScriptCmd>text.PutLine(v:count1 .. ']p')<CR>>']
# nmap <P <ScriptCmd>text.PutLine(v:count1 .. '[p')<CR><']
# nmap <p <ScriptCmd>text.PutLine(v:count1 .. ']p')<CR><']
# nmap =P <ScriptCmd>text.PutLine(v:count1 .. '[p')<CR>=']
# nmap =p <ScriptCmd>text.PutLine(v:count1 .. ']p')<CR>=']
var paste: bool
var mouse: string

def RestorePaste()
	if paste
		&paste = paste
		&mouse = mouse
	endif
	autocmd! unimpaired_paste
enddef

def SetupPaste()
	paste = &paste
	mouse = &mouse
	&paste = true
	&mouse = ''
	augroup unimpaired_paste
		autocmd!
		autocmd InsertLeave * RestorePaste()
		autocmd ModeChanged *:n RestorePaste()
	augroup END
enddef

export def PutLine(how: string)
	var reg = v:register

	const body = getreg(reg)
	const type = getregtype(reg)
	if reg =~ '[:%.]'
		const body_save = getreg('"')
		const type_save = getregtype('"')
		reg = '"'
		setreg('"', body, type)
		if type ==# 'V'
			exe 'normal! "' .. reg .. how
		else
			setreg(reg, body, 'l')
			exe 'normal! "' .. reg .. how
			setreg(reg, body, type)
		endif
		setreg('"', body_save, type_save)
	else
		if type ==# 'V'
			exe 'normal! "' .. reg .. how
		else
			setreg(reg, body, 'l')
			exe 'normal! "' .. reg .. how
			setreg(reg, body, type)
		endif
	endif
enddef
