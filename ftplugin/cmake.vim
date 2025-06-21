vim9script

import autoload 'cmakehelp.vim'

setlocal ballooneval
setlocal balloonevalterm
setlocal balloonexpr=cmakehelp.Balloonexpr()

nmap <buffer> K <plug>(cmake-help-popup)
