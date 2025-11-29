vim9script

augroup general | au!

	autocmd BufReadPost * {
		if line("'\"") >= 1 && line("'\"") <= line("$") && &filetype !~# 'commit'
				&& index(['xxd', 'gitrebase', 'tutor'], &filetype) == -1
				&& !&diff
			execute "normal! g`\""
		endif
	}

	# create non-existent directory before buffer save
	au BufWritePre * {
		if &modifiable && !isdirectory(expand("%:p:h"))
			mkdir(expand("%:p:h"), "p")
		endif
	}

	# # save last session on exit if there is a buffer with name
	# au VimLeavePre * {
	# 	if reduce(getbufinfo({'buflisted': 1}), (a, v) => a || !empty(v.name), false)
	# 		:exe $'mksession! {$MYVIMDIR}sessions/default.vim'
	# 	endif
	# }

	autocmd TermResponse * {
		if v:termresponse == "\e[>0;136;0c"
			set bg=dark
		endif
	}

	# vim -b : 用 xxd-格式编辑二进制文件！
	autocmd BufReadPre  *.bin,*.exe,*.dll set binary
	autocmd BufReadPost *bin,*exe,*dll {
		if &binary
			silent :%!xxd -c 32
			set filetype=xxd
			redraw
		endif
	}
	autocmd BufWritePre *bin,*exe,*dll {
		if &binary
			b:view = winsaveview()
			silent :%!xxd -r -c 32
		endif
	}
	autocmd BufWritePost *bin,*exe,*dll {
		if &binary
			undojoin
			silent :%!xxd -c 32
			set nomodified
			winrestview(b:view)
			redraw
		endif
	}

	# 自动去除尾随空格
	autocmd BufWritePre *.py :%s/[ \t\r]\+$//e

	# 设置 q 来退出窗口
	autocmd FileType startuptime,fugitive,qf,help,git,fugitiveblame,gitcommit map <buffer>q <Cmd>q<CR>

	# 在 gitcommit 中自动进入插入模式
	# autocmd FileType gitcommit :1 | startinsert

	# QuickFixCmdPost
	autocmd QuickFixCmdPost * cwindow

	def QfMakeConv()
		var qflist = getqflist()
		for i in qflist
			i.text = iconv(i.text, "cp936", "utf-8")
		endfor
		setqflist(qflist)
	enddef

	autocmd QuickfixCmdPost make QfMakeConv()

	autocmd User TermdebugStartPost {
		nmap <nowait> <LocalLeader>g <Cmd>Gdb<CR>
		nmap <nowait> <LocalLeader>p <Cmd>Program<CR>
		nmap <nowait> <LocalLeader>s <Cmd>Source<CR>
		nmap <nowait> <LocalLeader>a <Cmd>Asm<CR>
		nmap <nowait> <LocalLeader>v <Cmd>Var<CR>
		nmap <nowait> <F3> <Cmd>ToggleBreak<CR>
		nmap <nowait> <F5> <Cmd>RunOrContinue<CR>
		nmap <nowait> <LocalLeader><F5> <Cmd>Stop<CR>
		nmap <nowait> <Leader><F5> <Cmd>Run<CR>
		nmap <nowait> <F6> <Cmd>Step<CR>
		nmap <nowait> <F7> <Cmd>Over<CR>
		nmap <nowait> <F8> <Cmd>Finish<CR>
		setlocal complete=
	}
	autocmd User TermdebugStopPost {
		nunmap <LocalLeader>g
		nunmap <LocalLeader>p
		nunmap <LocalLeader>s
		nunmap <LocalLeader>a
		nunmap <LocalLeader>v
		map    <F3> <Plug>VimspectorToggleBreakpoint
		nmap   <F5> <Plug>VimspectorContinue
		nunmap <LocalLeader><F5>
		nunmap <Leader><F5>
		nunmap <F6>
		nmap   <F7> <Cmd>AsyncTask file-run<CR>
		nmap   <F8> <Cmd>AsyncTask file-build<CR>
	}
augroup end

command! DiffOrig {
	vert new
	set bt=nofile
	r ++edit %%
	:0delete
	diffthis
	wincmd p
	diffthis
}

# Commands

# update packages
import autoload "pack.vim"
command! PackUpdate pack.Update()

# Wipe all hidden buffers
def WipeHiddenBuffers()
	var buffers = filter(getbufinfo(), (_, v) => empty(v.windows))
	if !empty(buffers)
		execute 'confirm bwipeout' join(mapnew(buffers, (_, v) => v.bufnr))
	endif
enddef
command! WipeHiddenBuffers WipeHiddenBuffers()

# literal search
command! -nargs=? Search {
	if !empty(<q-args>)
		@/ = $'\V{escape(<q-args>, '\')}'
		feedkeys("n")
	endif
}
command! -nargs=1 Occur exe $'lvim /\V{escape(<q-args>, '\')}/j %' | belowright lopen

# fix trailing spaces
command! FixTrailingSpaces {
	var v = winsaveview()
	keepj silent! :%s/\r\+$//g
	keepj silent! :%s/\v(\s+$)//g
	winrestview(v)
	echom 'Remove trailing spaces and ^Ms.'
}

import autoload "text.vim"
command! -range FixSpaces text.FixSpaces(<line1>, <line2>)

import autoload "share.vim"
command! -range=% -nargs=? -complete=custom,share.Complete Share share.Paste(<q-args>, <line1>, <line2>)

# syntax group names under cursor
command! Inspect :echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')

# write to a privileged file
if executable('sudo')
	command! W w !sudo tee "%" >/dev/null
endif

import autoload 'unicode.vim'
command! -nargs=1 -complete=custom,UnicodeComplete Unicode unicode.Copy(<f-args>)
def UnicodeComplete(_, _, _): string
	return unicode.Subset()
		->mapnew((_, v) => {
			return printf("%5S", printf("%04X", v.value))
				.. "  "
				.. printf("%3S", (nr2char(v.value, true) =~ '\p' ? nr2char(v.value, true) : " "))
				.. "    " .. v.name
		})->join("\n")
enddef

import autoload 'hlblink.vim'
command BlinkLine hlblink.Line()

const skip_lists = g:startify_skiplist
def RecentComplete(_, _, _): string
	return v:oldfiles->filter((_, val: string): bool => {
		for pattern in skip_lists
			if val =~# pattern
				return false
			endif
		endfor
		return true
	})->join("\n")
enddef
def Edit(fname: string, split: bool = false, mods: string = "")
	var guess_mods = ""
	if !empty(mods)
		guess_mods = mods
	elseif split && winwidth(winnr()) * 0.3 > winheight(winnr())
		guess_mods = "vert "
	endif
	exe $"{guess_mods} {split ? "split" : "edit"} {fname->fnamemodify(':p')}"
enddef
command! -nargs=1 -complete=custom,RecentComplete Recent Edit(<q-args>, false, <q-mods>)
command! -nargs=1 -complete=custom,RecentComplete SRecent Edit(<q-args>, true, <q-mods>)
