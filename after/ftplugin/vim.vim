vim9script

nmap <buffer> <F5> <Cmd>source<CR>

def SentenceForward()
    const rx = '\v<((else(if)?)|(end(if|def|for|while|func|try)))>'
    const res = search(rx, 'e')
    const stx = map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
    while res != 0 && (!empty(stx) && stx[-1] =~ 'Comment\|String')
        res = search(rx, 'e')
        stx = map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
    endwhile
enddef

def SentenceBackward()
    const rxDef = '<((export\s+)?def\s+\k+\s*\()'
    const rxFunc = '(<(^\s*func\s+\k+\s*\())'
    const rxRest = '(<(try|finally|catch|if|else|elseif|for|while)>)'
    const rx = $'\v{rxDef}|{rxFunc}|{rxRest}'
    const res = search(rx, 'b')
    const stx = map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
    while res != 0 && (!empty(stx) && stx[-1] =~ 'Comment\|String')
        res = search(rx, 'b')
        stx = map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
    endwhile
enddef

nmap <buffer> ) <ScriptCmd>SentenceForward()<CR>
xmap <buffer> ) <ScriptCmd>SentenceForward()<CR>
omap <buffer> ) v<ScriptCmd>SentenceForward()<CR>
nmap <buffer> ( <ScriptCmd>SentenceBackward()<CR>
xmap <buffer> ( <ScriptCmd>SentenceBackward()<CR>
omap <buffer> ( v<ScriptCmd>SentenceBackward()<CR>
