-- Initially taken from [NTBBloodbath](https://github.com/NTBBloodbath/nvim/blob/main/lua/core/lsp.lua)
-- modified almost 80% by me

return {
  {
    'neovim/nvim-lspconfig',
    event = 'VeryLazy',
    dependencies = {
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
    },

    config = function()
      vim.lsp.config('*', {})
      vim.lsp.enable {
        'gopls',
        'jdtls',
        'kotlin_language_server',
        'lua_ls',
        'pylsp',
        'rust_analyzer',
        'ts_ls',
      }
      -- Diagnostics {{{
      local config = {
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = '',
            [vim.diagnostic.severity.WARN] = '',
            [vim.diagnostic.severity.HINT] = '',
            [vim.diagnostic.severity.INFO] = '',
          },
        },
        update_in_insert = true,
        underline = true,
        severity_sort = true,
        float = {
          focusable = false,
          style = 'minimal',
          border = 'single',
          source = 'always',
          header = '',
          prefix = '',
          suffix = '',
        },
      }
      vim.diagnostic.config(config)
      -- }}}

      local servers = {
        -- Vue 3
        volar = {
          init_options = {
            vue = {
              hybridMode = false,
            },
          },
          settings = {
            typescript = {
              inlayHints = {
                enumMemberValues = {
                  enabled = true,
                },
                functionLikeReturnTypes = {
                  enabled = true,
                },
                propertyDeclarationTypes = {
                  enabled = true,
                },
                parameterTypes = {
                  enabled = true,
                  suppressWhenArgumentMatchesName = true,
                },
                variableTypes = {
                  enabled = true,
                },
              },
            },
          },
        },
        -- ...
      }

      -- Improve LSPs UI {{{
      local icons = {
        Class = ' ',
        Color = ' ',
        Constant = ' ',
        Constructor = ' ',
        Enum = ' ',
        EnumMember = ' ',
        Event = ' ',
        Field = ' ',
        File = ' ',
        Folder = ' ',
        Function = '󰊕 ',
        Interface = ' ',
        Keyword = ' ',
        Method = 'ƒ ',
        Module = '󰏗 ',
        Property = ' ',
        Snippet = ' ',
        Struct = ' ',
        Text = ' ',
        Unit = ' ',
        Value = ' ',
        Variable = ' ',
      }

      local completion_kinds = vim.lsp.protocol.CompletionItemKind
      for i, kind in ipairs(completion_kinds) do
        completion_kinds[i] = icons[kind] and icons[kind] .. kind or kind
      end
      -- }}}

      -- Lsp capabilities and on_attach {{{
      local capabilities = vim.lsp.protocol.make_client_capabilities()

      capabilities.textDocument.foldingRange = {
        dynamicRegistration = true,
        lineFoldingOnly = true,
      }

      capabilities.textDocument.semanticTokens.multilineTokenSupport = true
      capabilities.textDocument.completion.completionItem.snippetSupport = true

      vim.lsp.config('*', {
        capabilities = capabilities,
        on_attach = function(client, bufnr)
          local ok, diag = pcall(require, 'rj.extras.workspace-diagnostic')
          if ok then
            diag.populate_workspace_diagnostics(client, bufnr)
          end
        end,
      })
      -- }}}

      -- Disable default binds
      for _, bind in ipairs { 'grn', 'gra', 'gri', 'grr', 'grt' } do
        pcall(vim.keymap.del, 'n', bind)
      end

      -- LspAttach keymaps
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(ev)
          local bufnr = ev.buf
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if not client then
            return
          end
          if client.server_capabilities.completionProvider then
            vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'
          end
          if client.server_capabilities.definitionProvider then
            vim.bo[bufnr].tagfunc = 'v:lua.vim.lsp.tagfunc'
          end
          client.server_capabilities.semanticTokensProvider = nil
          local keymap = vim.keymap.set
          local lsp = vim.lsp
          local opts = { silent = true }
          local function opt(desc, others)
            return vim.tbl_extend('force', opts, { desc = desc }, others or {})
          end
          keymap('n', 'gd', lsp.buf.definition, opt 'Go to definition')
          keymap('n', 'gD', function()
            local ok, diag = pcall(require, 'rj.extras.definition')
            if ok then
              diag.get_def()
            end
          end, opt 'Get definition in float')
          keymap('n', 'gi', function()
            lsp.buf.implementation { border = 'single' }
          end, opt 'Go to implementation')
          keymap('n', 'gr', lsp.buf.references, opt 'Show References')
          keymap('n', 'gl', vim.diagnostic.open_float, opt 'Open diagnostic float')
          keymap('n', '<C-k>', lsp.buf.signature_help, opts)
          pcall(vim.keymap.del, 'n', 'K', { buffer = ev.buf })
          keymap('n', 'K', function()
            lsp.buf.hover { border = 'single', max_height = 30, max_width = 120 }
          end, opt 'Hover')
          keymap('n', '<leader>la', lsp.buf.code_action, opt 'LSP code action')
          keymap('v', '<leader>la', lsp.buf.code_action, opt 'LSP code action')
        end,
      })

      -- Servers {{{

      -- Lua {{{
      vim.lsp.config.lua_ls = {
        cmd = { 'lua-language-server' },
        filetypes = { 'lua' },
        root_markers = { '.luarc.json', '.git', vim.uv.cwd() },
        settings = { Lua = { telemetry = { enable = false } } },
      }
      vim.lsp.enable 'lua_ls'
      -- }}}

      -- Python {{{
      vim.lsp.config.basedpyright = {
        name = 'basedpyright',
        filetypes = { 'python' },
        cmd = { 'basedpyright-langserver', '--stdio' },
        settings = {
          python = { venvPath = vim.fn.expand '~' .. '/.virtualenvs' },
          basedpyright = {
            disableOrganizeImports = true,
            analysis = {
              autoSearchPaths = true,
              autoImportCompletions = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = 'openFilesOnly',
              typeCheckingMode = 'strict',
              inlayHints = {
                variableTypes = true,
                callArgumentNames = true,
                functionReturnTypes = true,
                genericTypes = false,
              },
            },
          },
        },
      }

      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'python',
        callback = function()
          local ok, venv = pcall(require, 'rj.extras.venv')
          if ok then
            venv.setup()
          end
          local root = vim.fs.root(0, {
            'pyproject.toml',
            'setup.py',
            'setup.cfg',
            'requirements.txt',
            'Pipfile',
            'pyrightconfig.json',
            '.git',
            vim.uv.cwd(),
          })
          local client = vim.lsp.start(vim.tbl_extend('force', vim.lsp.config.basedpyright, { root_dir = root }), { attach = false })
          if client then
            vim.lsp.buf_attach_client(0, client)
          end
        end,
      })
      -- }}}

      -- Go {{{
      vim.lsp.config.gopls = {
        cmd = { 'gopls' },
        filetypes = { 'go', 'gotempl', 'gowork', 'gomod' },
        root_markers = { '.git', 'go.mod', 'go.work', vim.uv.cwd() },
        settings = {
          gopls = {
            completeUnimported = true,
            usePlaceholders = true,
            analyses = { unusedparams = true },
            ['ui.inlayhint.hints'] = {
              compositeLiteralFields = true,
              constantValues = true,
              parameterNames = true,
              rangeVariableTypes = true,
            },
          },
        },
      }
      vim.lsp.enable 'gopls'
      -- }}}

      -- C/C++ {{{
      vim.lsp.config.clangd = {
        cmd = {
          'clangd',
          '-j=2',
          '--background-index',
          '--clang-tidy',
          '--inlay-hints',
          '--fallback-style=llvm',
          '--all-scopes-completion',
          '--completion-style=detailed',
          '--header-insertion=iwyu',
          '--header-insertion-decorators',
          '--pch-storage=memory',
        },
        filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda', 'proto' },
        root_markers = {
          'CMakeLists.txt',
          '.clangd',
          '.clang-tidy',
          '.clang-format',
          'compile_commands.json',
          'compile_flags.txt',
          'configure.ac',
          '.git',
          vim.uv.cwd(),
        },
      }
      vim.lsp.enable 'clangd'
      -- }}}

      -- TypeScript LSP (necessário pro Volar funcionar) {{{
      vim.lsp.config.ts_ls = {
        cmd = { 'typescript-language-server', '--stdio' },
        filetypes = {
          'javascript',
          'javascriptreact',
          'javascript.jsx',
          'typescript',
          'typescriptreact',
          'typescript.tsx',
        },
        root_markers = { 'tsconfig.json', 'jsconfig.json', 'package.json', '.git' },
        init_options = {
          hostInfo = 'neovim',
          plugins = {
            {
              name = '@vue/typescript-plugin',
              location = vim.fn.stdpath 'data' .. '/mason/packages/vue-language-server/node_modules/@vue/language-server',
              languages = { 'vue' },
            },
          },
        },
        settings = {
          typescript = {
            tsserver = {
              useSyntaxServer = false,
            },
            inlayHints = {
              includeInlayParameterNameHints = 'all',
              includeInlayParameterNameHintsWhenArgumentMatchesName = true,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
              includeInlayVariableTypeHintsWhenTypeMatchesName = true,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayEnumMemberValueHints = true,
            },
          },
        },
      }
      vim.lsp.enable 'ts_ls'
      -- }}}

      -- Vue / Volar {{{
      vim.lsp.config.vue_ls = {
        on_init = function(client)
          client.handlers['tsserver/request'] = function(_, result, context)
            local clients = vim.lsp.get_clients { bufnr = context.bufnr, name = 'vtsls' }
            if #clients == 0 then
              vim.notify('Could not find `vtsls` lsp client, `vue_ls` would not work without it.', vim.log.levels.ERROR)
              return
            end
            local ts_client = clients[1]

            local param = unpack(result)
            local id, command, payload = unpack(param)
            ts_client:exec_cmd({
              title = 'vue_request_forward', -- You can give title anything as it's used to represent a command in the UI, `:h Client:exec_cmd`
              command = 'typescript.tsserverRequest',
              arguments = {
                command,
                payload,
              },
            }, { bufnr = context.bufnr }, function(_, r)
              local response = r and r.body
              -- TODO: handle error or response nil here, e.g. logging
              -- NOTE: Do NOT return if there's an error or no response, just return nil back to the vue_ls to prevent memory leak
              local response_data = { { id, response } }

              ---@diagnostic disable-next-line: param-type-mismatch
              client:notify('tsserver/response', response_data)
            end)
          end
        end,
        cmd = { 'vue-language-server', '--stdio' },
        filetypes = { 'vue' },
        root_markers = { 'package.json', 'tsconfig.json', 'jsconfig.json', '.git' },
        init_options = {
          typescript = {
            tsdk = vim.fn.stdpath 'data' .. '/mason/packages/typescript-language-server/node_modules/typescript/lib',
          },
        },
        settings = {
          vue = {
            hybridMode = true,
          },
        },
      }
      vim.lsp.enable 'vue_ls'
      -- }}}

      -- Rust {{{
      vim.lsp.config.rust_analyzer = {
        filetypes = { 'rust' },
        cmd = { 'rust-analyzer' },
        workspace_required = true,
        root_dir = function(buf, cb)
          local root = vim.fs.root(buf, { 'Cargo.toml', 'rust-project.json' })
          local out = vim.system({ 'cargo', 'metadata', '--no-deps', '--format-version', '1' }, { cwd = root }):wait()
          if out.code ~= 0 then
            return cb(root)
          end
          local ok, result = pcall(vim.json.decode, out.stdout)
          if ok and result.workspace_root then
            return cb(result.workspace_root)
          end
          return cb(root)
        end,
        settings = {
          autoformat = false,
          ['rust-analyzer'] = { check = { command = 'clippy' } },
        },
      }
      vim.lsp.enable 'rust_analyzer'
      -- }}}

      -- Typst {{{
      vim.lsp.config.tinymist = {
        cmd = { 'tinymist' },
        filetypes = { 'typst' },
        root_markers = { '.git', vim.uv.cwd() },
      }
      vim.lsp.enable 'tinymist'
      -- }}}

      -- Bash {{{
      vim.lsp.config.bashls = {
        cmd = { 'bash-language-server', 'start' },
        filetypes = { 'bash', 'sh', 'zsh' },
        root_markers = { '.git', vim.uv.cwd() },
        settings = {
          bashIde = { globPattern = vim.env.GLOB_PATTERN or '*@(.sh|.inc|.bash|.command)' },
        },
      }
      vim.lsp.enable 'bashls'
      -- }}}

      -- Web-dev {{{

      vim.lsp.config.svelte = {
        cmd = { 'svelteserver', '--stdio' },
        filetypes = { 'svelte' },
        root_markers = { 'tsconfig.json', 'jsconfig.json', 'package.json', '.git' },
      }

      vim.lsp.config.cssls = {
        cmd = { 'vscode-css-language-server', '--stdio' },
        filetypes = { 'css', 'scss' },
        root_markers = { 'package.json', '.git' },
        init_options = { provideFormatter = true },
      }

      vim.lsp.config.tailwindcssls = {
        cmd = { 'tailwindcss-language-server', '--stdio' },
        filetypes = {
          'ejs',
          'html',
          'css',
          'scss',
          'javascript',
          'javascriptreact',
          'typescript',
          'typescriptreact',
        },
        root_markers = {
          'tailwind.config.js',
          'tailwind.config.cjs',
          'tailwind.config.mjs',
          'tailwind.config.ts',
          'postcss.config.js',
          'postcss.config.cjs',
          'postcss.config.mjs',
          'postcss.config.ts',
          'package.json',
          'node_modules',
        },
        settings = {
          tailwindCSS = {
            classAttributes = { 'class', 'className', 'class:list', 'classList', 'ngClass' },
            includeLanguages = {
              eelixir = 'html-eex',
              eruby = 'erb',
              htmlangular = 'html',
              templ = 'html',
            },
            lint = {
              cssConflict = 'warning',
              invalidApply = 'error',
              invalidConfigPath = 'error',
              invalidScreen = 'error',
              invalidTailwindDirective = 'error',
              invalidVariant = 'error',
              recommendedVariantOrder = 'warning',
            },
            validate = true,
          },
        },
      }

      vim.lsp.config.htmlls = {
        cmd = { 'vscode-html-language-server', '--stdio' },
        filetypes = { 'html' },
        root_markers = { 'package.json', '.git' },
        init_options = {
          configurationSection = { 'html', 'css', 'javascript' },
          embeddedLanguages = { css = true, javascript = true },
          provideFormatter = true,
        },
      }

      vim.lsp.enable { 'ts_ls', 'cssls', 'tailwindcssls', 'htmlls', 'svelte' }
      -- }}}

      -- Commands {{{
      vim.api.nvim_create_user_command('LspStart', function()
        vim.cmd.e()
      end, { desc = 'Start LSP clients' })

      vim.api.nvim_create_user_command('LspStop', function(opts)
        for _, client in ipairs(vim.lsp.get_clients { bufnr = 0 }) do
          if opts.args == '' or opts.args == client.name then
            client:stop(true)
            vim.notify(client.name .. ': stopped')
          end
        end
      end, {
        desc = 'Stop all LSP clients or one by name',
        nargs = '?',
        complete = function()
          local clients = vim.lsp.get_clients { bufnr = 0 }
          local names = {}
          for _, c in ipairs(clients) do
            table.insert(names, c.name)
          end
          return names
        end,
      })

      vim.api.nvim_create_user_command('LspRestart', function()
        local detach = {}
        for _, client in ipairs(vim.lsp.get_clients { bufnr = 0 }) do
          client:stop(true)
          if vim.tbl_count(client.attached_buffers) > 0 then
            detach[client.name] = { client, vim.lsp.get_buffers_by_client_id(client.id) }
          end
        end
        local timer = vim.uv.new_timer()
        if not timer then
          return vim.notify 'Servers stopped but not restarted'
        end
        timer:start(
          100,
          50,
          vim.schedule_wrap(function()
            for name, client in pairs(detach) do
              local id = vim.lsp.start(client[1].config, { attach = false })
              if id then
                for _, buf in ipairs(client[2]) do
                  vim.lsp.buf_attach_client(buf, id)
                end
                vim.notify(name .. ': restarted')
              end
              detach[name] = nil
            end
            if next(detach) == nil and not timer:is_closing() then
              timer:close()
            end
          end)
        )
      end, { desc = 'Restart all LSP clients' })

      vim.api.nvim_create_user_command('LspLog', function()
        vim.cmd.vsplit(vim.lsp.log.get_filename())
      end, { desc = 'Show LSP logs' })

      vim.api.nvim_create_user_command('LspInfo', function()
        vim.cmd 'silent checkhealth vim.lsp'
      end, { desc = 'Show LSP info' })
      -- }}}
    end,
  },
}
