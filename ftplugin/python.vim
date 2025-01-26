vim9script

# 开启警告
g:pymode_warnings = 1
# 保存文件时自动删除无用空格
g:pymode_trim_whitespaces = 1
g:pymode_options = 1
# 显示允许的最大长度的列
g:pymode_options_colorcolumn = 1
# 设置QuickFix窗口的最大，最小高度
g:pymode_quickfix_minheight = 3
g:pymode_quickfix_maxheight = 10
# 使用python3
g:pymode_python = 'python3'
# 使用PEP8风格的缩进
g:pymode_indent = 1
# 取消代码折叠
g:pymode_folding = 0
# 开启python-mode定义的移动方式
g:pymode_motion = 1
# 启用python-mode内置的python文档，使用K进行查找
g:pymode_doc = 1
g:pymode_doc_bind = 'K'
# 自动检测并启用virtualenv
g:pymode_virtualenv = 1
# 不使用python-mode运行python代码
g:pymode_run = 0
# g:pymode_run_bind = '<localleader>r'
# 不使用python-mode设置断点
g:pymode_breakpoint = 0
# g:pymode_breakpoint_bind = '<localleader>b'
# 启用python语法检查
g:pymode_lint = 0
# 修改后保存时进行检查
g:pymode_lint_on_write = 0
# 编辑时进行检查
g:pymode_lint_on_fly = 0
g:pymode_lint_checkers = ['pyflakes', 'pep8']
# 发现错误时不自动打开QuickFix窗口
g:pymode_lint_cwindow = 0
# 侧边栏不显示python-mode相关的标志
g:pymode_lint_signs = 0
# g:pymode_lint_todo_symbol = 'WW'
# g:pymode_lint_comment_symbol = 'CC'
# g:pymode_lint_visual_symbol = 'RR'
# g:pymode_lint_error_symbol = 'EE'
# g:pymode_lint_info_symbol = 'II'
# g:pymode_lint_pyflakes_symbol = 'FF'
# 启用重构
g:pymode_rope = 1
# 不在父目录下查找.ropeproject，能提升响应速度
g:pymode_rope_lookup_project = 0
# 光标下单词查阅文档
g:pymode_rope_show_doc_bind = '<C-c>d'
# 项目修改后重新生成缓存
g:pymode_rope_regenerate_on_write = 1
# 开启补全，并设置<C-Tab>为默认快捷键
g:pymode_rope_completion = 1
g:pymode_rope_complete_on_dot = 1
g:pymode_rope_completion_bind = '<C-Tab>'
# <C-c>g跳转到定义处，同时新建竖直窗口打开
g:pymode_rope_goto_definition_bind = '<C-c>g'
g:pymode_rope_goto_definition_cmd = 'vnew'
# 重命名光标下的函数，方法，变量及类名
g:pymode_rope_rename_bind = 'rr'
# 重命名光标下的模块或包
g:pymode_rope_rename_module_bind = '<C-c>r1r'
# 开启python所有的语法高亮
g:pymode_syntax = 1
g:pymode_syntax_all = 1
# 高亮缩进错误
g:pymode_syntax_indent_errors = g:pymode_syntax_all
# 高亮空格错误
g:pymode_syntax_space_errors = g:pymode_syntax_all
