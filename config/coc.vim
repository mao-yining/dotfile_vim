vim9script
# https://raw.githubusercontent.com/neoclide/coc.nvim/master/doc/coc-example-config.vim
Plug 'tpope/vim-dadbod'
Plug 'kristijanhusak/vim-dadbod-ui' # Optional
Plug 'Shougo/neco-vim'
Plug 'neoclide/coc-neco'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'honza/vim-snippets'

if has('win32')
	set pythonthreedll=$HOME\AppData\Roaming\uv\python\cpython-3.13.3-windows-x86_64-none\python313.dll
	set pythonthreehome=$HOME\AppData\Roaming\uv\python\cpython-3.13.3-windows-x86_64-none\
endif
# Use tab for trigger completion with characters ahead and navigate
# NOTE: There's always complete item selected by default, you may want to enable
# no select by `"suggest.noselect": true` in your configuration file
# NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
# other plugin before putting this into your config
inoremap <silent><expr> <TAB> coc#pum#visible() ? coc#_select_confirm() : coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" : CheckBackspace() ? "\<TAB>" : coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

def CheckBackspace(): bool
	var col = col('.') - 1
	return !col || getline('.')[col - 1]  =~# '\s'
enddef

# Make <CR> to accept selected completion item or notify coc.nvim to format
# <C-g>u breaks current undo, please make your own choice
# inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
# \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

# Use <c-space> to trigger completion
if has('nvim')
	inoremap <silent><expr> <c-space> coc#refresh()
else
	inoremap <silent><expr> <c-@> coc#refresh()
endif

# Use `[d` and `]d` to navigate diagnostics
# Use `:CocDiagnostics` to get all diagnostics of current buffer in location list
# Use ALE to Diagnostic

# GoTo code navigation
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

# Use K to show documentation in preview window
nnoremap <silent> K <cmd>call ShowDocumentation()<cr>
command! -nargs=0 Hover call CocAction('doHover')
def g:ShowDocumentation()
	if index(['vim', 'help'], &filetype) >= 0
		execute 'help ' .. expand('<cword>')
	elseif &filetype ==# 'tex'
		VimtexDocPackage
	else
		Hover
	endif
enddef

# Highlight the symbol and its references when holding the cursor
autocmd CursorHold * silent call CocActionAsync('highlight')

# Symbol renaming
nmap <f2> <Plug>(coc-rename)

augroup mygroup
	autocmd!
	# Setup formatexpr specified filetype(s)
	autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
	# Update signature help on jump placeholder
	autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

# Applying code actions to the selected code block
# Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

# Remap keys for applying code actions at the cursor position
nmap <leader>cc  <Plug>(coc-codeaction-cursor)
# Remap keys for apply code actions affect whole buffer
nmap <leader>cs  <Plug>(coc-codeaction-source)
# Apply the most preferred quickfix action to fix diagnostic on the current line
nmap <leader>.  <Plug>(coc-fix-current)
nmap <leader>ca  <Plug>(coc-fix-current)

# Remap keys for applying refactor code actions
xmap <silent> <localleader>r  <Plug>(coc-codeaction-refactor-selected)
nmap <silent> <localleader>r  <Plug>(coc-codeaction-refactor-selected)

# Run the Code Lens action on the current line
nmap <leader>cl  <Plug>(coc-codelens-action)

# Map function and class text objects
# NOTE: Requires 'textDocument.documentSymbol' support from the language server
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

# Remap <C-f> and <C-b> to scroll float windows/popups
if has('nvim-0.4.0') || has('patch-8.2.0750')
	nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
	nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
	inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr># : "\<Right>"
	inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr># : "\<Left>"
	vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
	vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif

# Use CTRL-S for selections ranges
# Requires 'textDocument/selectionRange' support of language server
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

# Add `:Format` command to format current buffer
command! -nargs=0 Format call CocActionAsync('format')

# Add `:Fold` command to fold current buffer
command! -nargs=? Fold call CocAction('fold', <f-args>)

# Add `:OR` command for organize imports of the current buffer
command! -nargs=0 OR   call CocActionAsync('runCommand', 'editor.action.organizeImport')

# Add (Neo)Vim's native statusline support
# NOTE: Please see `:h coc-status` for integrations with external plugins that
# provide custom statusline: lightline.vim, vim-airline
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

# Use <C-j> for select text for visual placeholder of snippet.
vmap <C-j> <Plug>(coc-snippets-select)

# Use <C-j> for jump to next placeholder, it's default of coc.nvim
g:coc_snippet_next = '<c-j>'

# Use <C-k> for jump to previous placeholder, it's default of coc.nvim
g:coc_snippet_prev = '<c-k>'

# Use <C-j> for both expand and jump (make expand higher priority.)
imap <C-j> <Plug>(coc-snippets-expand-jump)

# Use <leader>x for convert visual selected code to snippet
xmap <leader>x  <Plug>(coc-convert-snippet)

# Mappings for CoCList
# Manage extensions
nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
# Find symbol of current document
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
# Search workspace symbols
nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
# Do default action for next item
nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
# Do default action for previous item
nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
# Resume latest coc list
nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>

nnoremap <silent><nowait> <leader>b <cmd>CocList buffers<CR>
nnoremap <silent><nowait> <leader>: <cmd>CocList commands<CR>
# nnoremap <silent> <leader>f <cmd>CocList files<CR>
nnoremap <silent><nowait> <leader><space> <cmd>CocList files<CR>
nnoremap <silent><nowait> <leader>f <cmd>CocList grep<CR>
nnoremap <silent><nowait> <leader>h <cmd>CocList helptags<CR>
nnoremap <silent><nowait> <leader>r <cmd>CocList mru<CR>
nnoremap <silent><nowait> <leader>m <cmd>CocList marketplace<CR>
nnoremap <silent><nowait> <leader>t <cmd>CocList tasks<CR>
