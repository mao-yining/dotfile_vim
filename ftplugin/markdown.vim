vim9script

b:table_mode_corner = '|'
b:table_mode_always_active = 1
nnoremap <buffer><leader>cp <cmd>MarkdownPreviewToggle<cr>

g:vim_markdown_frontmatter = 1 # YAML
g:vim_markdown_math = 1
# g:vim_markdown_toml_frontmatter = 1
# g:vim_markdown_json_frontmatter = 1
g:vim_markdown_strikethrough = 1
g:vim_markdown_no_extensions_in_markdown = 1
g:vim_markdown_autowrite = 1
# g:vim_markdown_auto_extension_ext = 'txt'
g:vim_markdown_edit_url_in = 'tab'
# g:vim_markdown_borderless_table = 1
call LspAddServer([{name: 'marksman',
		    filetype: ['markdown'],
		    path: 'marksman.cmd',
		    args: [],
		  }])
