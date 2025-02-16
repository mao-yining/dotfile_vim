vim9script

#  ALE [[[
Plug 'dense-analysis/ale'
noremap ]d <Plug>(ale_previous_wrap)
noremap [d <Plug>(ale_next_wrap)
noremap <leader>cr <cmd>ALERename<cr>
noremap <leader>cR <cmd>ALEFileRename<cr>
noremap gr <cmd>ALEFindReferences<cr>
noremap gd <cmd>ALEGoToDefinition<cr>
noremap gI <cmd>ALEGoToImplementation<cr>
noremap gy <cmd>ALEGoToTypeDefinition<cr>
noremap K <cmd>ALEHover<cr>
au Filetype vim noremap <buffer>K K
noremap gK <cmd>ALESymbolSearch<cr>
noremap <leader>ca <cmd>ALECodeAction<cr>
#  g:ale_sign_column_always = 1
g:ale_echo_msg_format = '[%linter%] %code: %%s'
g:ale_lsp_suggestions = 1
g:ale_detail_to_floating_preview = 1
g:ale_hover_to_preview = 1
g:ale_floating_preview = 1
g:ale_lint_on_text_changed = "normal"
g:ale_lint_on_insert_leave = 1
#  ]]]

#  complete [[[
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'laixintao/asyncomplete-gitcommit'
Plug 'prabirshrestha/asyncomplete-file.vim'
Plug 'prabirshrestha/asyncomplete-ultisnips.vim'
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'prabirshrestha/asyncomplete-necovim.vim'
Plug 'Shougo/neco-vim'
Plug 'prabirshrestha/asyncomplete-tags.vim'
#  au User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#emoji#get_source_options({
#			\ 'name': 'emoji',
#			\ 'allowlist': ['*'],
#			\ 'completor': function('asyncomplete#sources#emoji#completor'),
#			\ }))
au User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#ultisnips#get_source_options({
			\ 'name': 'ultisnips',
			\ 'allowlist': ['*'],
			\ 'priority': 20,
			\ 'completor': function('asyncomplete#sources#ultisnips#completor'),
			\ }))
#  inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
#  inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <cr>    pumvisible() ? asyncomplete#close_popup() : "\<cr>"
au User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#file#get_source_options({
			\ 'name': 'file',
			\ 'allowlist': ['*'],
			\ 'priority': 10,
			\ 'completor': function('asyncomplete#sources#file#completor')
			\ }))
au User asyncomplete_setup call asyncomplete#register_source({
			\ 'name': 'gitcommit',
			\ 'whitelist': ['gitcommit'],
			\ 'priority': 10,
			\ 'completor': function('asyncomplete#sources#gitcommit#completor')
			\ })
au User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#necovim#get_source_options({
			\ 'name': 'necovim',
			\ 'allowlist': ['vim'],
			\ 'completor': function('asyncomplete#sources#necovim#completor'),
			\ }))
au User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#tags#get_source_options({
			\ 'name': 'tags',
			\ 'allowlist': ['c'],
			\ 'completor': function('asyncomplete#sources#tags#completor'),
			\ 'config': {
			\    'max_file_size': 50000000,
			\  },
			\ }))
au User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#ale#get_source_options({
			\ 'priority': 10,
			\ }))
#  ]]]

