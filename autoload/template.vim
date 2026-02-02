vim9script
# Name: autoload/template.vim
# Author: Mao-Yining <mao.yining@outlook.com>
# Desc: Search, expand and insert templates.
# Usage:
# import autoload "template.vim"
# command! -nargs=1 -complete=custom,template.Complete InsertTemplate template.Insert(<f-args>)

var paths: list<string>
var templates_cache: list<string>
augroup CmdCompleteResetTemplate
	au!
	au CmdlineEnter : templates_cache = []
	au CmdlineEnter : paths = []
augroup END

const dir_name = "templates"
const default_dir = dir_name->finddir($MYVIMDIR)
def GetPaths(): list<string>
	if empty(paths)
		paths = dir_name->finddir('.;', -1)
		if paths->index(default_dir) == -1 && isdirectory(default_dir)
			paths->add(default_dir)
		endif
		const ft = bufnr()->getbufvar('&filetype')
	endif
	return paths
enddef

def Echo(str: string)
	echo "[template.vim]:" str
enddef

export def Complete(_, _, _): string
	if empty(templates_cache)
		const ft = bufnr()->getbufvar('&filetype')
		for path in GetPaths()
			const ft_path = $"{path}/{ft}"
			if !empty(ft) && isdirectory(ft_path)
				templates_cache = ft_path->readdirex((e) => e.type == 'file')->mapnew((_, v) => $"{ft}/{v.name}")
			endif
			if isdirectory(path)
				templates_cache->extend(path->readdirex((e) => e.type == 'file')->mapnew((_, v) => v.name))
			endif
		endfor
	endif
	return templates_cache->join("\n")
enddef

export def Insert(template: string)
	if &l:readonly
		Echo("Buffer is read-only!")
		return
	endif
	for path in GetPaths()
		const template_path = template->findfile(path)
		if empty(template_path)
			continue
		endif
		readfile(template_path)->mapnew((_, v) => v->substitute('!!\(.\{-}\)!!', '\=eval(submatch(1))', 'g'))->append(line('.'))
		if getline('.') =~ '^\s*$'
			delete _
		else
			normal j^
		endif
		return
	endfor
	Echo($"Can't find template: {template}")
	return
enddef
