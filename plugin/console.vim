if has("gui_running")
	finish
endif

" Open modifyOtherKeys
let &t_TI = "\<Esc>[>4;2m"
let &t_TE = "\<Esc>[>4;m"

" cursor
let &t_EI = "\e[2 q"
let &t_SI = "\e[5 q"
let &t_SR = "\e[3 q"

set <M-H>=H
set <M-J>=J
set <M-K>=K
set <M-L>=L

for i in range(10)
	execute($"set <M-{i}>={i == 0 ? 10 : i}")
endfor
