return {
  {
    'OXY2DEV/markview.nvim',
    lazy = false,
    config = function()
      local separator_namespace = vim.api.nvim_create_namespace('markdown-section-separators')

      local function render_section_separators(buffer)
        if not vim.api.nvim_buf_is_valid(buffer) or vim.bo[buffer].filetype ~= 'markdown' then
          return
        end

        vim.api.nvim_buf_clear_namespace(buffer, separator_namespace, 0, -1)

        local lines = vim.api.nvim_buf_get_lines(buffer, 0, -1, false)
        for row, line in ipairs(lines) do
          if line:match('^%s*===+%s*$') then
            vim.api.nvim_buf_set_extmark(buffer, separator_namespace, row - 1, 0, {
              end_col = #line,
              conceal = '',
              virt_text = { { string.rep('─', math.max(#line, 48)), 'Comment' } },
              virt_text_pos = 'overlay',
            })
          end
        end
      end

      require('markview').setup({
        markdown = {
          headings = {
            setext_1 = {
              style = 'decorated',
              icon = '',
              sign = '',
              sign_hl = 'MarkviewHeading1Sign',
              hl = 'MarkviewHeading1',
              border = '─',
            },
            setext_2 = {
              style = 'decorated',
              icon = '',
              sign = '',
              sign_hl = 'MarkviewHeading2Sign',
              hl = 'MarkviewHeading2',
              border = '─',
            },
          },
        },
      })

      vim.api.nvim_create_autocmd({ 'BufEnter', 'TextChanged', 'TextChangedI' }, {
        group = vim.api.nvim_create_augroup('MarkdownSectionSeparators', { clear = true }),
        callback = function(event)
          vim.schedule(function()
            render_section_separators(event.buf)
          end)
        end,
      })

      vim.schedule(function()
        for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
          render_section_separators(buffer)
        end
      end)
    end,
    keys = {
      { '<leader>um', '<cmd>Markview Toggle<cr>', desc = 'Toggle Markdown preview' },
    },
  },
}
