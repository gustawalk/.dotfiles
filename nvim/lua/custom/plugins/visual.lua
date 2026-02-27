return {
  -- Animações suaves
  {
    'echasnovski/mini.animate',
    version = false,
    config = function()
      require('mini.animate').setup {
        cursor = {
          enable = true,
          timing = require('mini.animate').gen_timing.linear { duration = 100, unit = 'total' },
        },
        scroll = {
          enable = true,
          timing = require('mini.animate').gen_timing.linear { duration = 150, unit = 'total' },
        },
        resize = { enable = true },
        open = { enable = true },
        close = { enable = true },
      }
    end,
  },

  -- Barra de status estilosa
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('lualine').setup {
        options = {
          section_separators = '',
          component_separators = '',
        },
      }
    end,
  },

  -- Ícones bonitos (necessário para vários plugins visuais)
  { 'nvim-tree/nvim-web-devicons', lazy = true },

  -- UI moderna para : e mensagens
  {
    'folke/noice.nvim',
    event = 'VeryLazy',
    dependencies = {
      'MunifTanjim/nui.nvim',
      'rcarriga/nvim-notify',
    },
    config = function()
      require('noice').setup {
        presets = {
          bottom_search = true, -- coloca a barra de busca / no canto inferior
          command_palette = true, -- divide :comandos e /busca com layout bonito
          long_message_to_split = true, -- mensagens longas vão pra split
          inc_rename = false, -- se quiser integrar com incremental rename
          lsp_doc_border = true, -- bordas nas popups LSP
        },
      }
    end,
  },
}
