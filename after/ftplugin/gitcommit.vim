if exists('b:load_ftp')
	finish
endif
call bullet#SetLocalMappings()
map <buffer> q <Cmd>wincmd c<CR>
let b:load_ftp = 1
