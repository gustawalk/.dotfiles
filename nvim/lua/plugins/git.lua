return {
  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end
        map('n', ']h', function()
          gs.nav_hunk('next')
        end, 'Next Git hunk')
        map('n', '[h', function()
          gs.nav_hunk('prev')
        end, 'Previous Git hunk')
        map('n', '<leader>gs', gs.stage_hunk, 'Stage hunk')
        map('n', '<leader>gr', gs.reset_hunk, 'Reset hunk')
        map('n', '<leader>gp', gs.preview_hunk, 'Preview hunk')
        map('n', '<leader>gb', gs.blame_line, 'Blame line')
        map('n', '<leader>gd', gs.diffthis, 'Diff against index')
        map('n', '<leader>gS', gs.stage_buffer, 'Stage buffer')
        map('n', '<leader>gu', gs.undo_stage_hunk, 'Undo stage hunk')
        map('x', '<leader>gs', function()
          gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
        end, 'Stage selected lines')
        map('x', '<leader>gr', function()
          gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
        end, 'Reset selected lines')
      end,
    },
  },
  {
    'NeogitOrg/neogit',
    cmd = 'Neogit',
    keys = { { '<leader>gg', '<cmd>Neogit<cr>', desc = 'Open Git status' } },
    dependencies = { 'nvim-lua/plenary.nvim', 'sindrets/diffview.nvim', 'nvim-telescope/telescope.nvim' },
    opts = {},
  },
}
