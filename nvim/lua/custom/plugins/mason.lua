return {
  -- Automatically install LSPs, formatters, and linters
  {
    'williamboman/mason.nvim',
    config = function()
      require('mason').setup()
    end,
  },
  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = {
      'williamboman/mason.nvim',
      'neovim/nvim-lspconfig',
    },
    config = function()
      -- Here, we are telling mason-lspconfig to automatically install the LSPs we want.
      -- This should fix the error you are seeing with lua_ls.
      require('mason-lspconfig').setup {
        ensure_installed = {
          'lua_ls',
          'prismals',
        },
      }
    end,
  },
}
