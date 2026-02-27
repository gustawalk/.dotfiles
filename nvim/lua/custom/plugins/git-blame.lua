return {
  'f-person/git-blame.nvim',
  event = 'BufRead',
  config = function()
    -- Disable by default
    vim.g.gitblame_enabled = 0
    vim.keymap.set('n', '<leader>gb', '<cmd>GitBlameToggle<CR>', { desc = 'Toggle Git Blame' })
  end,
}
