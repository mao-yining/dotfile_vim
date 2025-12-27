vim9script

def CmdReplace(cmd: string, ucmd: string): string
	return (getcmdtype() ==# ':' && getcmdline() ==# cmd) ? ucmd : cmd
enddef

cnoreabbrev <expr> git CmdReplace('git', 'Git')

# quick to change dir
cab cdn lcd <C-R>=expand('%:p:h')<CR>
cab cdr cd <C-R>=FindProjectRoot()<CR>

inorea myn Mao-Yining
inorea mynmail mao.yining@outlook.com
inorea latex LaTeX
inorea xetex XeTeX
inorea xelatex XeLaTeX
inorea luatex LuaTeX
inorea lualatex LuaLaTeX
inorea winodws windows
inorea flase false
inorea ture true
inorea adn and
inorea Adn And
inorea teh the
inorea Teh The
inorea tihs this
inorea Tihs This
inorea thsi this
inorea Thsi This
inorea taht that
inorea Taht That
inorea thta that
inorea Thta That
inorea htat that
inorea Htat That
inorea waht what
inorea Waht What
inorea whta what
inorea Whta What
inorea hwat what
inorea Hwat What
inorea wtih with
inorea Wtih With
inorea wthi with
inorea Wthi With
inorea wiht with
inorea Wiht With
inorea rigth right
inorea Rigth Right
inorea lenght length
inorea Lenght Length
inorea weigth weight
inorea Weigth Weight
inorea knwo know
inorea Knwo Know
inorea kwno know
inorea Kwno Know
inorea konw know
inorea Konw Know
inorea clena clean
inorea Clena Clean
inorea maek make
inorea Maek Make

inorea todo: TODO:
inorea fixme: FIXME:
inorea xxx: XXX:
inorea task: TASK:
inorea bug: BUG:
