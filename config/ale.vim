vim9script
Plug 'dense-analysis/ale'

g:ale_sign_column_always = true
g:ale_disable_lsp = true
g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
g:ale_virtualtext_prefix = ""
g:ale_sign_error = '>>'
g:ale_sign_warning = '--'
nmap <localleader>d <Plug>(ale_detail)
nmap <silent> [d <Plug>(ale_previous)
nmap <silent> ]d <Plug>(ale_next)

Plug 'maximbaz/lightline-ale'
g:lightline.component_expand = {
  'linter_checking': 'lightline#ale#checking',
  'linter_infos': 'lightline#ale#infos',
  'linter_warnings': 'lightline#ale#warnings',
  'linter_errors': 'lightline#ale#errors',
  'linter_ok': 'lightline#ale#ok',
}
g:lightline.component_type = {
  'linter_checking': 'right',
  'linter_infos': 'right',
  'linter_warnings': 'warning',
  'linter_errors': 'error',
  'linter_ok': 'right',
}
g:lightline.active.right += [[ 'linter_checking', 'linter_errors', 'linter_warnings', 'linter_infos', 'linter_ok' ]]
