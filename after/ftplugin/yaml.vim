let g:yaml_indent_multiline_scalar = 1
if executable("prettier")
	set formatprg=prettier\ --stdin-filepath\ %\ --parser\ yaml
endif
