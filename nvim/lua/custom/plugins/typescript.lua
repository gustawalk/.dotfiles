return {
  'pmizio/typescript-tools.nvim',
  dependencies = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' },
  config = function()
    require('typescript-tools').setup {
      
      settings = {
        -- These are the suggested settings from the plugin's documentation
        publish_diagnostic_on = 'change',
        expose_as_code_action = 'all',
      },
    }

    -- A helper function to add a which-key group.
    -- We need this because we want to add the group whenever this plugin is loaded.
    local function add_which_key_group()
      local wk = pcall(require, 'which-key')
      if not wk then
        return
      end
      require('which-key').add {
        { '<leader>c', group = '[C]ode Actions' },
      }
    end

    add_which_key_group()

    -- Add keymaps for the plugin's commands
    vim.keymap.set('n', '<leader>co', '<cmd>TSToolsOrganizeImports<CR>', { desc = 'Organize Imports' })
    vim.keymap.set('n', '<leader>ca', '<cmd>TSToolsAddMissingImports<CR>', { desc = 'Add Missing Imports' })
    vim.keymap.set('n', '<leader>cr', '<cmd>TSToolsRenameFile<CR>', { desc = 'Rename File and Update Imports' })
  end,
}
