vim9script

augroup General | au!

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

	autocmd TermResponse * {
		if v:termresponse == "\e[>0;136;0c"
			set bg=dark
		endif
	}

	# vim -b : 用 xxd-格式编辑二进制文件！
	autocmd BufReadPre  *.bin,*.exe,*.dll set binary
	autocmd BufReadPost *.bin,*.exe,*.dll {
		if &binary
			silent :%!xxd -c 32
			set filetype=xxd
			redraw
		endif
	}
	autocmd BufWritePre *.bin,*.exe,*.dll {
		if &binary
			b:view = winsaveview()
			silent :%!xxd -r -c 32
		endif
	}
	autocmd BufWritePost *.bin,*.exe,*.dll {
		if &binary
			undojoin
			silent :%!xxd -c 32
			set nomodified
			winrestview(b:view)
			redraw
		endif
	}

	autocmd BufWritePost $MYVIMDIR/plugin/*,$MYVIMRC ++nested {
		echow "Config Change Detected. Reloading..."
		:source
	}

	# 设置 q 来退出窗口
	autocmd FileType startuptime,fugitive,fugitiveblame,gitcommit map <buffer> q <Cmd>q<CR>

augroup END

command! DiffOrig {
	vert new
	set bt=nofile
	r ++edit %%
	:0delete
	diffthis
	wincmd p
	diffthis
}

# update packages
import autoload "pack.vim"
command! PackUpdate pack.Update()

# Wipe all hidden buffers
command! WipeHiddenBuffers {
	const buffers = getbufinfo()->filter((_, v) => empty(v.windows))
	if !empty(buffers)
		execute 'confirm bwipeout' buffers->mapnew((_, v) => v.bufnr)->join()
	endif
}

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
	const v = winsaveview()
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

def RecentComplete(_, _, _): string
	const skip_lists: list<string> = get(g:, "startify_skiplist", [])
	return v:oldfiles->filter((_, val: string): bool => {
		for pattern in skip_lists
			if val =~# pattern || empty(val)
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

command! BackupVault exe "Git commit -am \"vault backup:" strftime("%Y-%m-%d %H:%M:%S\"")
