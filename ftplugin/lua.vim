call LspAddServer([#{name: 'luals',
                 \   filetype: 'lua',
                 \   path: 'lua-language-server.cmd',
                 \   args: [],
				 \   workspaceConfig: #{
				 \     Lua: #{
				 \       hint: #{
				 \         enable: v:true,
				 \       }
				 \     }
				 \   }
                 \ }])
