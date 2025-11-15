vim9script
# The MIT License (MIT)
#
# Copyright (c) 2025 Mao-Yining
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

def EchoWarn(message: string)
	echohl WarningMsg | echom message | echohl None
enddef

def EchoShrug()
	EchoWarn('¯\_(ツ)_/¯')
enddef

const begin = '^[^0-9]*[0-9]\{4}-[0-9]\{2}-[0-9]\{2}\s\+'

def GvSha(...args: list<any>): string
	return matchstr(get(args, 0, getline('.')), begin .. '\zs[a-f0-9]\+')
enddef

def Move(flag: string): string
	const [l, c] = searchpos(begin, flag)
	return !empty(l) ? printf('%dG%d|', l, c) : null_string
enddef

def Browse(url: string)
	dist#vim9#Open(b:git_origin .. url)
enddef

def TabNew()
	execute $":{tabpagenr() - 1} .. tabnew"
enddef

def GBrowse()
	const sha = GvSha()
	if empty(sha)
		EchoShrug()
		return
	endif
	execute 'GBrowse' sha
enddef

def Type(visual: bool): list<any>
	if visual
		const shas = getline(min((line("."), line("v"))), max((line("."), line("v"))))
			->map((_, val) => GvSha(val))->filter((_, val) => !empty(val))
		if len(shas) < 2
			return [0, 0]
		endif
		return ['diff', g:FugitiveShellCommand(['diff', shas[-1], shas[0]])]
	endif

	if exists('b:git_origin')
		const syn = synIDattr(synID(line('.'), col('.'), 0), 'name')
		if syn == 'gvGitHub'
			return ['link', '/issues/' .. expand('<cword>')[1 : ]]
		elseif syn == 'gvTag'
			return ['link', '/releases/' .. getline('.')
				->matchstr('(tag: \zs[^ ,)]\+')]
		endif
	endif

	const sha = GvSha()
	if !empty(sha)
		return ['commit', g:FugitiveFind(sha)]
	endif
	return [0, 0]
enddef

def Split(tab: bool)
	if tab
		TabNew()
	else
		const w = range(1, winnr('$'))
			->filter((_, val) => val->getwinvar("gv", false))
			->get(0)
		if w > 0
			execute $":{w}wincmd w"
			enew
		else
			vertical botright new
		endif
	endif
	w:gv = true
enddef

def Open(visual: bool, tab = false)
	const [type, target] = Type(visual)

	if empty(type)
		EchoShrug()
		return
	elseif type == 'link'
		Browse(target)
		return
	endif

	Split(tab)
	Scratch()
	if type == 'commit'
		execute 'e' escape(target, ' ')
		nnoremap <buffer> gb <Cmd>GBrowse<CR>
	elseif type == 'diff'
		Fill(target)
		setf diff
	endif
	nnoremap <buffer> q <Cmd>close<CR>
	const bang = tab ? '!' : ''
	if exists('#User#GV' .. bang)
		execute 'doautocmd <nomodeline> User GV' .. bang
	endif
	wincmd p
	echo
enddef

def Dot(): string
	const sha = GvSha()
	return empty(sha) ? null_string : $":Git  {sha}\<s-left>\<left>"
enddef

def Maps()
	nnoremap <buffer> q    <Cmd>$wincmd w <bar> close<CR>
	nnoremap <buffer> ZZ   <Cmd>$wincmd w <bar> close<CR>
	nnoremap <buffer> <nowait> gq <Cmd>$wincmd w <bar> close<CR>
	nnoremap <buffer> gb   <ScriptCmd>GBrowse()<CR>
	nnoremap <buffer> <CR> <ScriptCmd>Open(false)<CR>
	nnoremap <buffer> o    <ScriptCmd>Open(false)<CR>
	nnoremap <buffer> O    <ScriptCmd>Open(false, true)<CR>
	xnoremap <buffer> <CR> <ScriptCmd>Open(true)<CR>
	xnoremap <buffer> o    <ScriptCmd>Open(true)<CR>
	xnoremap <buffer> O    <ScriptCmd>Open(true, true)<CR>
	nnoremap <buffer> <expr> .  Dot()
	nnoremap <buffer> <expr> ]] Move('')
	nnoremap <buffer> <expr> ][ Move('')
	nnoremap <buffer> <expr> [[ Move('b')
	nnoremap <buffer> <expr> [] Move('b')
	xnoremap <buffer> <expr> ]] Move('')
	xnoremap <buffer> <expr> ][ Move('')
	xnoremap <buffer> <expr> [[ Move('b')
	xnoremap <buffer> <expr> [] Move('b')

	nmap     <buffer> <C-n> ]]o
	nmap     <buffer> <C-p> [[o
	xmap     <buffer> <C-n> ]]ogv
	xmap     <buffer> <C-p> [[ogv
enddef

def SetGitOrigin()
	const domain  = exists('g:fugitive_github_domains') ? ['github.com']
		->extend(g:fugitive_github_domains)
		->map((_, val) => val->split("://")[-1]->substitute("/*$", "", "")->escape("."))
		->join('\|') : '.*github.\+'
	# https://  github.com  /  junegunn/gv.vim  .git
	# git@      github.com  :  junegunn/gv.vim  .git
	const pat = '^\(https\?://\|git@\)\(' .. domain .. '\)[:/]\([^@:/]\+/[^@:/]\{-}\)\%(.git\)\?$'
	const origin = g:FugitiveRemoteUrl()->matchlist(pat)
	if !empty(origin)
		b:git_origin = printf('%s%s/%s',
			origin[1] =~ '^http' ? origin[1] : 'https://', origin[2], origin[3])
	endif
enddef

def Scratch()
	setlocal buftype=nofile bufhidden=wipe noswapfile nomodeline
enddef

def Fill(cmd: string)
	setlocal modifiable
	:%delete _
	silent execute 'read' escape('!' .. cmd, '%')
	normal! gg"_dd
	setlocal nomodifiable

	# TODO: Test Async Read
	# cmd->job_start({
	# 	out_io: "buffer",
	# 	out_buf: bufnr,
	# 	out_modifiable: false,
	# })
enddef

def Tracked(file: string): bool
	system(g:FugitiveShellCommand(['ls-files', '--error-unmatch', file]))
	return !v:shell_error
enddef

def CheckBuffer(current: string)
	if empty(current)
		throw 'untracked buffer'
	elseif !Tracked(current)
		throw current .. ' is untracked'
	endif
enddef

def LogOpts(bang: bool, visual: bool, line1: number, line2: number): tuple<list<string>, list<any>>
	if visual || bang
		const current = expand('%')
		CheckBuffer(current)
		return visual ? ([printf('-L%d,%d:%s', line1, line2, current)], []) : (['--follow'], ['--', current])
	endif
	return (['--graph'], [])
enddef

def List(log_opts: list<string>)
	const default_opts = ['--color=never', '--date=short', '--format=%cd %h%d %s (%an)']
	const git_args = ['log'] + default_opts + log_opts
	const git_log_cmd = g:FugitiveShellCommand(git_args)

	const repo_short_name = g:FugitiveGitDir()->substitute('[\\/]\.git[\\/]\?$', '', '')->fnamemodify(':t')
	const bufname = repo_short_name .. ' ' .. join(log_opts)
	silent exe (bufexists(bufname) ? 'buffer' : 'file') fnameescape(bufname)

	Scratch()
	setlocal nowrap tabstop=8 cursorline iskeyword+=#
	if !exists(':GBrowse')
		doautocmd <nomodeline> User Fugitive
	endif
	Maps()
	setfiletype GV
	echo 'o: open split / O: open tab / gb: GBrowse / q: quit'

	Fill(git_log_cmd)
enddef

def Trim(arg: string): string
	const trimmed = arg->substitute('\s*$', '', '')
	return trimmed =~ "^'.*'$" ? trimmed[1 : -2]->substitute("''", '', 'g')
		: trimmed =~ '^".*"$' ? trimmed[1 : -2]->substitute('""', '', 'g')->substitute('\\"', '"', 'g')
		: trimmed->substitute('""\|''''', '', 'g')->substitute('\\ ', ' ', 'g')
enddef

def GvShellwords(arg: string): list<string>
	var words: list<string> = []
	var contd = false
	for token in arg->split('\%(\%(''\%([^'']\|''''\)\+''\)\|\%("\%(\\"\|[^"]\)\+"\)\|\%(\%(\\ \|\S\)\+\)\)\s*\zs')
		const trimmed = Trim(token)
		if contd
			words[-1] ..= trimmed
		else
			words->add(trimmed)
		endif
		contd = token !~ '\s\+$'
	endfor
	return words
enddef

def SplitPathspec(args: list<string>): tuple<list<string>, list<any>>
	const split = args->index('--')
	if split < 0
		return (args, [])
	elseif split == 0
		return ([], args)
	endif
	return (args[0 : split - 1], args[split :])
enddef

def Gl(buf: number, visual: bool)
	if !exists(':Gllog')
		return
	endif
	tab split
	silent execute visual ? "'<,'>Gllog" : ':0Gllog'
	getloclist(0)->insert({bufnr: buf}, 0)->setloclist(0)
	noautocmd b %%

	lopen
	xnoremap <buffer> o <ScriptCmd>Gld(line("v"), line("."))<CR>
	nnoremap <buffer> o <CR><C-W><C-W>
	nnoremap <buffer> O <ScriptCmd>Gld(line("."), line("."))<CR>
	nnoremap <buffer> q <Cmd>tabclose<CR>
	nnoremap <buffer> gq <Cmd>tabclose<CR>
	"Conceal"->matchadd('^fugitive://.\{-}\.git//')
	"Conceal"->matchadd('^fugitive://.\{-}\.git//\x\{7}\zs.\{-}||')
	setlocal concealcursor=nv conceallevel=3 nowrap
	w:quickfix_title = "o: open / o (in visual): diff / O: open (tab) / q: quit"
enddef

def Gld(start: number, end: number)
	const to   = (start, end)->min()->getline()->split("|")[0]
	const from = (start, end)->max()->getline()->split("|")[0]
	execute $":{tabpagenr() - 1}tabedit" escape(to, ' ')
	if from !=# to
		execute 'vsplit' escape(from, ' ')
		windo diffthis
	endif
enddef

def GV(bang: bool, visual: bool, line1: number, line2: number, args: string)
	if !exists('g:loaded_fugitive')
		EchoWarn('fugitive not found')
		return
	endif

	if empty(g:FugitiveGitDir())
		EchoWarn('not in git repo')
		return
	endif

	const cd = exists('*haslocaldir') && haslocaldir() ? 'lcd' : 'cd'
	const cwd = getcwd()
	const root = g:FugitiveFind(':/')
	try
		if cwd !=# root
			execute cd escape(root, ' ')
		endif
		if args =~ '?$'
			if len(args) > 1
				EchoWarn('invalid arguments')
				return
			endif
			CheckBuffer(expand('%'))
			Gl(bufnr(), visual)
		else
			const [opts1, paths1] = LogOpts(bang, visual, line1, line2)
			const [opts2, paths2] = SplitPathspec(GvShellwords(args))
			const log_opts = opts1 + opts2 + paths1 + paths2
			TabNew()
			List(log_opts)
			# SetGitOrigin() # TODO: too slow
			g:FugitiveDetect(@#)
		endif
	catch
		EchoWarn(v:exception)
	finally
		if getcwd() !=# cwd
			execute cd escape(cwd, ' ')
		endif
	endtry
enddef

command! -bang -nargs=* -range=0 -complete=customlist,fugitive#CompleteObject GV GV(<bang>0, <count>, <line1>, <line2>, <q-args>)
