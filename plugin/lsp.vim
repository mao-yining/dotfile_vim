if "coc"->getcompletion("packadd")->empty()|finish|endif
vim9script
se complete=
packadd coc
# Use tab for trigger completion with characters ahead and navigate
# NOTE: There's always complete item selected by default, you may want to enable
# no select by `"suggest.noselect": true` in your configuration file
# NOTE: Use command ":verbose imap <Tab>" to make sure tab is not mapped by
# other plugin before putting this into your config
inoremap <silent><expr> <Tab>
				\ coc#pum#visible() ? coc#pum#next(1) :
				\ CheckBackspace() ? "\<Tab>" :
				\ coc#refresh()
inoremap <expr><S-Tab> coc#pum#visible() ? coc#pum#prev(1) : "\<C-H>"

# Make <CR> to accept selected completion item or notify coc.nvim to format
# <C-g>u breaks current undo, please make your own choice
# Remove "\<C-R>=coc#on_enter()" as it not used
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
				\ : "\<C-G>u\<CR>"

def CheckBackspace(): bool
		var col = col(".") - 1
		return !col || getline(".")[col - 1] =~# "\\s"
enddef

# Use <C-l> for trigger snippet expand.
imap <C-l> <Plug>(coc-snippets-expand)

# Use <C-j> for select text for visual placeholder of snippet.
vmap <C-j> <Plug>(coc-snippets-select)

# Use <C-j> for jump to next placeholder, it's default of coc.nvim
g:coc_snippet_next = "<C-j>"

# Use <C-k> for jump to previous placeholder, it's default of coc.nvim
g:coc_snippet_prev = "<C-k>"

# Use <Leader>x for convert visual selected code to snippet
xmap <Leader>x  <Plug>(coc-convert-snippet)

# Use <C-space> to trigger completion
if has("nvim")
		inoremap <silent><expr> <C-space> coc#refresh()
else
		inoremap <silent><expr> <C-@> coc#refresh()
endif

# GoTo code navigation
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

# Use K to show documentation in preview window
nnoremap <silent> K <ScriptCmd>ShowDocumentation()<CR>
command! -nargs=0 Hover call CocAction("doHover")
def ShowDocumentation()
		if index(["vim", "help"], &filetype) >= 0
			execute "help " .. expand("<cword>")
		elseif &filetype ==# "tex"
			execute "VimtexDocPackage"
		else
			execute "Hover"
		endif
enddef

# Highlight the symbol and its references when holding the cursor
autocmd CursorHold * silent call CocActionAsync("highlight")

# Symbol renaming
nmap <F2> <Plug>(coc-rename)

augroup mygroup
		autocmd!
		# Setup formatexpr specified filetype(s)
		autocmd FileType typescript,json setl formatexpr=CocAction("formatSelected")
		# Update signature help on jump placeholder
		autocmd User CocJumpPlaceholder call CocActionAsync("showSignatureHelp")
augroup end

# Applying code actions to the selected code block
# Example: `<Leader>aap` for current paragraph
xmap <Leader>a  <Plug>(coc-codeaction-selected)
nmap <Leader>a  <Plug>(coc-codeaction-selected)

# Remap keys for applying code actions at the cursor position
nmap <Leader>cc  <Plug>(coc-codeaction-cursor)
# Remap keys for apply code actions affect whole buffer
nmap <Leader>cs  <Plug>(coc-codeaction-source)
# Apply the most preferred quickfix action to fix diagnostic on the current line
nmap <Leader>.  <Plug>(coc-fix-current)
nmap <Leader>ca  <Plug>(coc-fix-current)

# Remap keys for applying refactor code actions
xmap <silent> <LocalLeader>r  <Plug>(coc-codeaction-refactor-selected)
nmap <silent> <LocalLeader>r  <Plug>(coc-codeaction-refactor-selected)

# Run the Code Lens action on the current line
nmap <Leader>cl  <Plug>(coc-codelens-action)

nmap [oI  <Cmd>CocCommand document.enableInlayHint<CR>
nmap ]oI  <Cmd>CocCommand document.disableInlayHint<CR>
nmap yoI  <Cmd>CocCommand document.toggleInlayHint<CR>

# Map function and class text objects
# NOTE: Requires "textDocument.documentSymbol" support from the language server
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

# Remap <C-f> and <C-b> to scroll float windows/popups
if has("nvim-0.4.0") || has("patch-8.2.0750")
		nnoremap <silent><nowait><expr> <C-F> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-F>"
		nnoremap <silent><nowait><expr> <C-B> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-B>"
		inoremap <silent><nowait><expr> <C-F> coc#float#has_scroll() ? "\<C-R>=coc#float#scroll(1)\<CR>" : "\<Right>"
		inoremap <silent><nowait><expr> <C-B> coc#float#has_scroll() ? "\<C-R>=coc#float#scroll(0)\<CR>" : "\<Left>"
		vnoremap <silent><nowait><expr> <C-F> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-F>"
		vnoremap <silent><nowait><expr> <C-B> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-B>"
endif

# Use CTRL-S for selections ranges
# Requires "textDocument/selectionRange" support of language server
nmap <silent> <C-S> <Plug>(coc-range-select)
xmap <silent> <C-S> <Plug>(coc-range-select)

# Add `:Format` command to format current buffer
command! -nargs=0 Format call CocActionAsync("format")

# Add `:Fold` command to fold current buffer
command! -nargs=? Fold call CocAction("fold", <f-args>)

# Add `:OR` command for organize imports of the current buffer
command! -nargs=0 OR   call CocActionAsync("runCommand", "editor.action.organizeImport")

nnoremap <Leader>v  <Cmd>CocList outline<CR>
nnoremap <Leader>s  <Cmd>CocList symbols<CR>
nnoremap <Leader>m <Cmd>CocList marketplace<CR>

g:copilot_no_tab_map = v:true
imap <silent><script><expr> <C-y> copilot#Accept("\<CR>")
