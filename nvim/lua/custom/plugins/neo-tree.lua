return {
  'nvim-neo-tree/neo-tree.nvim',
  branch = 'v3.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
    -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
  },
  cmd = 'Neotree',
  keys = {
    {
      '<leader>e',
      function()
        require('neo-tree.command').execute { toggle = true }
      end,
    },
  },
  opts = {
    event_handlers = {
      {
        event = 'neo_tree_buffer_enter',
        handler = function()
          vim.bo.buflisted = false
        end,
      },
    },
    filesystem = {
      commands = {
        open_or_toggle_tab = function(state)
          local node = state.tree:get_node()
          if node.type == 'directory' then
            require('neo-tree.sources.filesystem').toggle_directory(state, node)
          else
            vim.cmd('tabnew ' .. vim.fn.fnameescape(node.path))
          end
        end,
      },
      window = {
        position = 'right',
        mappings = {
          ['<CR>'] = 'open',
          ['<S-Enter>'] = 'open_or_toggle_tab',
        },
      },
    },
    git_status = {
      window = {
        position = 'right',
      },
    },
  },
}
