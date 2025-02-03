vim9script

setlocal keywordprg=:CMakeHelpPopup

# Open the online CMake documentation for current word in a browser
nmap <buffer> <leader>k <plug>(cmake-help-online)
