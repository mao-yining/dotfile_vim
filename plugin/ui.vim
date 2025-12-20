vim9script
g:startify_enable_special      = 0
g:startify_relative_path       = 1
g:startify_change_to_dir       = 1
g:startify_update_oldfiles     = 1
g:startify_fortune_use_unicode = 1
g:startify_files_number        = 3
g:startify_session_sort        = 1
g:startify_custom_header       = "startify#pad(startify#fortune#boxed())"
g:startify_session_autoload    = 1
g:startify_session_persistence = 1
g:startify_change_to_vcs_root  = 1
g:startify_session_delete_buffers = 1
g:startify_lists = [
	{ type: "files",     header: ["   MRU"]       },
	{ type: "sessions",  header: ["   Sessions"]  },
	{ type: "bookmarks", header: ["   Bookmarks"] },
	{ type: "commands",  header: ["   Commands"]  },
]
if !isdirectory($MYVIMDIR .. "/sessions")
	mkdir($MYVIMDIR .. "/sessions", "p")
endif
g:startify_session_dir = $MYVIMDIR .. "/sessions"
g:startify_skiplist = ["runtime/doc/", "/plugged/.*/doc/", "/.git/", "\\Temp\\"]
g:startify_skiplist += ["fugitiveblame$", "^dir:", "^fugitive:"]
g:startify_bookmarks = [{ "c": $MYVIMRC }]
g:startify_bookmarks += [{ "b": "~/Documents/vault/projects/accounts/main.bean" }]
g:startify_custom_footer = ["", "   Vim is charityware. Please read \":help uganda\".", ""]

packadd vim-airline
g:airline#extensions#whitespace#checks = [ 'trailing', 'conflicts' ]
