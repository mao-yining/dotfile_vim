vim9script
g:ale_tex_chktex_executable = '' # 不使用 chktex
g:vimtex_quickfix_mode = 0
g:tex_flavor = "latex"
g:vimtex_compiler_latexmk = {
  "aux_dir": "",
  "out_dir": "",
  "callback": 1,
  "continuous": 1,
  "executable": "latexmk",
  "hooks": [],
  "options": [
    "-verbose",
    "-file-line-error",
    "-shell-escape",
    "-synctex=1",
    "-interaction=nonstopmode",
  ],
}
# gvim -v --not-a-term -T dumb -c "VimtexInverseSearch %l '%f'"
