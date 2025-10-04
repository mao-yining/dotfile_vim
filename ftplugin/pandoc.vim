vim9script noclear

g:neoformat_enabled_pandoc = [ "prettier" ]

setlocal nolinebreak
setlocal textwidth=74

def AddFormat(mark: string): string
	return $"c{mark}\<C-R>\"{mark}\<Esc>"
enddef

# 创建视觉模式映射
xnoremap <expr> <LocalLeader>b AddFormat("**")
xnoremap <expr> <LocalLeader>i AddFormat("*")
xnoremap <expr> <LocalLeader>m AddFormat("$")
xnoremap <expr> <LocalLeader>s AddFormat("~~")
xnoremap <expr> <LocalLeader>c AddFormat("`")
xnoremap <expr> <LocalLeader>q AddFormat("`")

iab 》 >
iab 【 [
iab 】 ]
