vim9script

g:vim_man_cmd = get(g:, 'man_cmd', '/usr/bin/man')

import autoload '../autoload/man.vim'

command! -nargs=* -bar -complete=custom,man.Complete Man  man.GetPage('horizontal', <f-args>)
command! -nargs=* -bar -complete=custom,man.Complete Sman man.GetPage('horizontal', <f-args>)
command! -nargs=* -bar -complete=custom,man.Complete Vman man.GetPage('vertical',   <f-args>)
command! -nargs=* -bar -complete=custom,man.Complete Tman man.GetPage('tab',        <f-args>)
set keywordprg=:Man
command! -nargs=+ -bang Mangrep man.GrepRun(<bang>false, <f-args>)
