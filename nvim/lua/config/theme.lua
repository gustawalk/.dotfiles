local M = {}

local themes = {
  'tokyonight-night',
  'tokyonight-storm',
  'tokyonight-moon',
  'tokyonight-day',
  'onedark',
  'onelight',
  'catppuccin-latte',
  'catppuccin-frappe',
  'catppuccin-macchiato',
  'catppuccin-mocha',
  'kanagawa-wave',
  'kanagawa-dragon',
  'kanagawa-lotus',
  'nightfox',
  'dawnfox',
  'duskfox',
  'nordfox',
  'terafox',
  'carbonfox',
  'gruvbox',
  'monokai',
  'monokai_pro',
  'monokai_soda',
  'monokai_ristretto',
  'rose-pine-main',
  'rose-pine-moon',
  'rose-pine-dawn',
  'everforest',
  'dracula',
  'dracula-soft',
  'cyberdream',
}
local state_file = vim.fn.stdpath('state') .. '/theme'
local active_theme

local function apply(name, remember)
  if not vim.tbl_contains(themes, name) then
    vim.notify('Unknown theme: ' .. name, vim.log.levels.ERROR)
    return false
  end
  local ok, err = pcall(vim.cmd.colorscheme, name)
  if not ok then
    vim.notify('Could not load theme ' .. name .. ': ' .. err, vim.log.levels.ERROR)
    return false
  end
  active_theme = name
  if remember then
    vim.fn.mkdir(vim.fn.stdpath('state'), 'p')
    vim.fn.writefile({ name }, state_file)
  end
  return true
end

local function preview_picker()
  local original = active_theme or vim.g.colors_name
  local buffer = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buffer, 0, -1, false, themes)
  vim.bo[buffer].modifiable = false
  local width = 28
  local height = math.min(#themes, math.max(1, vim.o.lines - 4))
  local window = vim.api.nvim_open_win(buffer, true, {
    relative = 'editor',
    row = math.max(0, math.floor((vim.o.lines - height) / 2) - 1),
    col = math.max(0, vim.o.columns - width - 3),
    width = width,
    height = height,
    border = 'rounded',
    title = ' Theme preview ',
    style = 'minimal',
  })
  vim.wo[window].cursorline = true
  local current_index = original and vim.fn.index(themes, original) + 1 or 1
  vim.api.nvim_win_set_cursor(window, { math.max(current_index, 1), 0 })
  local committed = false
  local function close()
    if vim.api.nvim_win_is_valid(window) then
      vim.api.nvim_win_close(window, true)
    end
  end
  vim.api.nvim_create_autocmd('CursorMoved', {
    buffer = buffer,
    callback = function()
      local index = vim.api.nvim_win_get_cursor(window)[1]
      apply(themes[index], false)
    end,
  })
  vim.api.nvim_create_autocmd('WinClosed', {
    pattern = tostring(window),
    once = true,
    callback = function()
      if not committed and original then
        vim.schedule(function()
          if vim.tbl_contains(themes, original) then
            apply(original, false)
          else
            pcall(vim.cmd.colorscheme, original)
          end
        end)
      end
    end,
  })
  vim.keymap.set('n', '<cr>', function()
    local index = vim.api.nvim_win_get_cursor(window)[1]
    if apply(themes[index], true) then
      committed = true
      close()
    end
  end, { buffer = buffer, desc = 'Keep selected theme' })
  for _, key in ipairs({ 'q', '<esc>' }) do
    vim.keymap.set('n', key, close, { buffer = buffer, desc = 'Cancel theme preview' })
  end
end

function M.setup()
  vim.api.nvim_create_autocmd('ColorScheme', {
    callback = function(event)
      active_theme = vim.tbl_contains(themes, event.match) and event.match or nil
    end,
  })
  local saved = vim.fn.filereadable(state_file) == 1 and vim.fn.readfile(state_file)[1] or nil
  apply(vim.tbl_contains(themes, saved) and saved or 'tokyonight-night', false)
  vim.api.nvim_create_user_command('Theme', function(opts)
    if opts.args ~= '' then
      apply(opts.args, true)
    else
      preview_picker()
    end
  end, {
    nargs = '?',
    complete = function()
      return themes
    end,
    desc = 'Choose and remember a color theme',
  })
  vim.keymap.set('n', '<leader>ut', '<cmd>Theme<cr>', { desc = 'Choose theme' })
end

return M
