vim9script

var templates_cache: list<string>
augroup CmdCompleteResetTemplate
    au!
    au CmdlineEnter : templates_cache = []
augroup END

def TemplateComplete(_, _, _): string
    const path = $"{$MYVIMDIR}templates/"
    const ft = bufnr()->getbufvar('&filetype')
    const ft_path = path .. ft

    if empty(templates_cache)
        if !empty(ft) && isdirectory(ft_path)
            templates_cache = ft_path->readdirex((e) => e.type == 'file')->mapnew((_, v) => $"{ft}/{v.name}")
        endif
        if isdirectory(path)
            templates_cache->extend(path->readdirex((e) => e.type == 'file')->mapnew((_, v) => v.name))
        endif
    endif

    return templates_cache->join("\n")
enddef

def InsertTemplate(template: string)
    if &l:readonly
        echo "Buffer is read-only!"
        return
    endif
    var template_path = $"{$MYVIMDIR}templates/{template}"
    if !filereadable(template_path)
        echo $"Can't read {template_path}"
        return
    endif
    readfile(template_path)->mapnew((_, v) => v->substitute('!!\(.\{-}\)!!', '\=eval(submatch(1))', 'g'))->append(line('.'))
    if getline('.') =~ '^\s*$'
        delete _
    else
        join
    endif
enddef
command! -nargs=1 -complete=custom,TemplateComplete InsertTemplate InsertTemplate(<f-args>)
