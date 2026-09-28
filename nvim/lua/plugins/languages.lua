return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    config = function()
      local languages = {
        'bash',
        'c',
        'cpp',
        'css',
        'html',
        'javascript',
        'json',
        'lua',
        'markdown',
        'markdown_inline',
        'rust',
        'tsx',
        'typescript',
        'vim',
        'vimdoc',
      }
      require('nvim-treesitter').setup({ install_dir = vim.fn.stdpath('data') .. '/site' })
      require('nvim-treesitter').install(languages)
      vim.api.nvim_create_autocmd('FileType', {
        pattern = languages,
        callback = function(event)
          pcall(vim.treesitter.start, event.buf)
        end,
      })
    end,
  },
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {},
  },
  {
    'mason-org/mason.nvim',
    opts = {},
  },
  {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    dependencies = { 'mason-org/mason.nvim' },
    opts = { ensure_installed = { 'stylua', 'prettier', 'eslint_d', 'tree-sitter-cli' } },
  },
  {
    'mason-org/mason-lspconfig.nvim',
    dependencies = { 'mason-org/mason.nvim', 'neovim/nvim-lspconfig' },
    opts = {
      automatic_enable = false,
      ensure_installed = {
        'lua_ls',
        'ts_ls',
        'html',
        'cssls',
        'jsonls',
        'clangd',
        'rust_analyzer',
        'bashls',
      },
    },
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = { 'hrsh7th/cmp-nvim-lsp' },
    config = function()
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      vim.lsp.config('*', { capabilities = capabilities })
      vim.lsp.config(
        'lua_ls',
        { settings = { Lua = { workspace = { checkThirdParty = false }, telemetry = { enable = false } } } }
      )
      vim.lsp.config('rust_analyzer', { settings = { ['rust-analyzer'] = { check = { command = 'clippy' } } } })
      -- Tailwind is available on demand; it does not start in every Git-backed web project.
      vim.lsp.config('tailwindcss', {
        settings = {
          tailwindCSS = {
            files = { exclude = { '**/.git/**', '**/node_modules/**', '**/.history/**', '**/dist/**', '**/build/**' } },
          },
        },
      })
      vim.lsp.enable({
        'lua_ls',
        'ts_ls',
        'html',
        'cssls',
        'jsonls',
        'clangd',
        'rust_analyzer',
        'bashls',
      })

      vim.diagnostic.config({
        severity_sort = true,
        update_in_insert = false,
        virtual_text = { spacing = 2, source = 'if_many' },
        float = { border = 'rounded', source = 'if_many' },
      })

      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('LspKeymaps', { clear = true }),
        callback = function(event)
          local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = event.buf, desc = desc })
          end
          map('n', 'gd', vim.lsp.buf.definition, 'Go to definition')
          map('n', 'gD', vim.lsp.buf.declaration, 'Go to declaration')
          map('n', 'gr', vim.lsp.buf.references, 'Find references')
          map('n', 'gi', vim.lsp.buf.implementation, 'Go to implementation')
          map('n', 'K', vim.lsp.buf.hover, 'Show documentation')
          map('n', '<leader>cr', vim.lsp.buf.rename, 'Rename symbol')
          map({ 'n', 'x' }, '<leader>ca', vim.lsp.buf.code_action, 'Code action')
          map('n', '<leader>cs', vim.lsp.buf.signature_help, 'Signature help')
        end,
      })
    end,
  },
}
