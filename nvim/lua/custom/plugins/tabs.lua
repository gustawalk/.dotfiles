return {
  'akinsho/bufferline.nvim',
  version = '*',
  dependencies = 'nvim-tree/nvim-web-devicons',
  opts = {
    options = {
      mode = 'tabs',
      show_buffer_close_icons = true,
      show_close_icon = true,
      separator_style = 'slant',
      always_show_bufferline = true,
    },
  },
  config = function(_, opts)
    require('bufferline').setup(opts)
    vim.keymap.set('n', '<C-i>', 'gT', { desc = 'Previous tab' })
    vim.keymap.set('n', '<C-o>', 'gt', { desc = 'Next tab' })
    vim.keymap.set('n', '<leader>wc', '<cmd>tabclose<CR>', { desc = 'Close current tab' })

    -- Automatically close the previous buffer when opening a new one
    local group = vim.api.nvim_create_augroup('AutoClosePrevBuffer', { clear = true })
    vim.api.nvim_create_autocmd('BufEnter', {
      group = group,
      pattern = '*',
      callback = function()
        local prev_bufnr = vim.fn.bufnr('#')
        if
          prev_bufnr == -1
          or prev_bufnr == vim.api.nvim_get_current_buf()
          or not vim.api.nvim_buf_is_valid(prev_bufnr)
        then
          return
        end

        local prev_buf_info = vim.fn.getbufinfo(prev_bufnr)[1]
        -- Don't close modified, unlisted, or special buffers
        if not prev_buf_info or prev_buf_info.changed or not prev_buf_info.listed or prev_buf_info.buftype ~= '' then
          return
        end

        -- Don't close protected filetypes
        local prev_ft = vim.bo[prev_bufnr].filetype
        local protected_fts = { 'neo-tree', 'qf', 'help', 'man', 'TelescopePrompt', 'git' }
        for _, p_ft in ipairs(protected_fts) do
          if prev_ft == p_ft then
            return
          end
        end

        vim.cmd('bdelete ' .. prev_bufnr)
      end,
    })
  end,
}
