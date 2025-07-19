" Vim syntax file
" Language:	Markdown
" Maintainer:	Ben Williams <benw@plasticboy.com>
" URL:		http://plasticboy.com/markdown-vim-mode/
" Remark:	Uses HTML syntax file
" TODO: 	Handle stuff contained within stuff (e.g. headings within blockquotes)


" Read the HTML syntax to start with
if v:version < 600
  so <sfile>:p:h/html.vim
else
  runtime! syntax/html.vim

  if exists('b:current_syntax')
    unlet b:current_syntax
  endif
endif

if v:version < 600
  syntax clear
elseif exists('b:current_syntax')
  finish
endif

" don't use standard HiLink, it will not work with included syntax files
if v:version < 508
  command! -nargs=+ HtmlHiLink hi link <args>
else
  command! -nargs=+ HtmlHiLink hi def link <args>
endif

syn spell toplevel
syn case ignore
syn sync linebreaks=1

let s:conceal = ''
let s:concealends = ''
let s:concealcode = ''
if has('conceal') && get(g:, 'vim_markdown_conceal', 1)
  let s:conceal = ' conceal'
  let s:concealends = ' concealends'
endif
if has('conceal') && get(g:, 'vim_markdown_conceal_code_blocks', 1)
  let s:concealcode = ' concealends'
endif

" additions to HTML groups
if get(g:, 'vim_markdown_emphasis_multiline', 1)
    let s:oneline = ''
else
    let s:oneline = ' oneline'
endif

execute 'syn region htmlItalic matchgroup=mkdItalic start="\(\\\|\*\)\@<!\zs\*\ze\S" end="\S\zs\*" keepend contains=@Spell' . s:oneline . s:concealends
execute 'syn region htmlItalic matchgroup=mkdItalic start="\(\\\|_\)\@<!\zs_\ze\S" end="\S\zs_" keepend contains=@Spell' . s:oneline . s:concealends
execute 'syn region htmlBold matchgroup=mkdBold start="\(\\\|\*\)\@<!\zs\*\*\ze\S" end="\S\zs\*\*" keepend contains=@Spell' . s:oneline . s:concealends
execute 'syn region htmlBold matchgroup=mkdBold start="\(\\\|_\)\@<!\zs__\ze\S" end="\S\zs__" keepend contains=@Spell' . s:oneline . s:concealends
execute 'syn region htmlBoldItalic matchgroup=mkdBoldItalic start="\(\\\|\*\)\@<!\zs\*\*\*\ze\S" end="\S\zs\*\*\*" keepend contains=@Spell' . s:oneline . s:concealends
execute 'syn region htmlBoldItalic matchgroup=mkdBoldItalic start="\(\\\|_\)\@<!\zs___\ze\S" end="\S\zs___" keepend contains=@Spell' . s:oneline . s:concealends

delcommand HtmlHiLink
" vim: ts=8
