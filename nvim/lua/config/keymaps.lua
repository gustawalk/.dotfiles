local map = vim.keymap.set

map('n', '<Esc>', '<cmd>nohlsearch<cr>', { desc = 'Clear search highlight' })
map('x', 'p', '"_dP', { desc = 'Paste without replacing the yank' })
map('n', '<leader>p', 'viw"_dP', { desc = 'Replace word with last yank' })
map('x', '<', '<gv', { desc = 'Indent left and reselect' })
map('x', '>', '>gv', { desc = 'Indent right and reselect' })
map('n', '<leader>mj', ':m .+1<cr>==', { desc = 'Move line down' })
map('n', '<leader>mk', ':m .-2<cr>==', { desc = 'Move line up' })
map('x', '<leader>mj', ":m '>+1<cr>gv=gv", { desc = 'Move selection down' })
map('x', '<leader>mk', ":m '<-2<cr>gv=gv", { desc = 'Move selection up' })

map('n', '<leader>ww', '<cmd>w<cr>', { desc = 'Save file' })
map('n', '<leader>wq', '<cmd>q<cr>', { desc = 'Close window' })
map('n', '<leader>wv', '<cmd>vsplit<cr>', { desc = 'Split vertically' })
map('n', '<leader>wh', '<cmd>split<cr>', { desc = 'Split horizontally' })
map('n', '<leader>wo', '<cmd>only<cr>', { desc = 'Keep this split' })
map('n', '<leader>we', '<C-w>=', { desc = 'Equalize splits' })
map('n', '<A-Left>', '<cmd>vertical resize -5<cr>', { desc = 'Narrow split' })
map('n', '<A-Right>', '<cmd>vertical resize +5<cr>', { desc = 'Widen split' })
map('n', '<A-Up>', '<cmd>resize +3<cr>', { desc = 'Taller split' })
map('n', '<A-Down>', '<cmd>resize -3<cr>', { desc = 'Shorter split' })

map('n', '<leader>bn', '<cmd>bnext<cr>', { desc = 'Next buffer' })
map('n', '<leader>bp', '<cmd>bprevious<cr>', { desc = 'Previous buffer' })
map('n', '<leader>bd', '<cmd>bdelete<cr>', { desc = 'Close buffer' })
map('n', '<leader>tn', '<cmd>tabnew<cr>', { desc = 'New tab' })
map('n', '<leader>tc', '<cmd>tabclose<cr>', { desc = 'Close tab' })
map('n', '<leader>th', '<cmd>tabprevious<cr>', { desc = 'Previous tab' })
map('n', '<leader>tl', '<cmd>tabnext<cr>', { desc = 'Next tab' })

-- The same keys navigate Neovim windows and tmux panes.
for key, direction in pairs({ h = 'L', j = 'D', k = 'U', l = 'R' }) do
  local function navigate()
    local previous = vim.api.nvim_get_current_win()
    vim.cmd.wincmd(key)
    if previous == vim.api.nvim_get_current_win() and vim.env.TMUX then
      vim.fn.system({ 'tmux', 'select-pane', '-' .. direction })
    end
  end
  local description = 'Move to ' .. ({ h = 'left', j = 'below', k = 'above', l = 'right' })[key] .. ' pane'
  map('n', '<A-' .. key .. '>', navigate, { desc = description })
end

map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Leave terminal mode' })
map('n', '<leader>tt', function()
  vim.cmd('botright 12split')
  vim.cmd.term()
end, { desc = 'Open terminal below' })

map('n', '<leader>uf', function()
  vim.b.disable_autoformat = not vim.b.disable_autoformat
  vim.notify('Format on save ' .. (vim.b.disable_autoformat and 'off' or 'on') .. ' for this buffer')
end, { desc = 'Toggle format on save for buffer' })

map('n', '[d', function()
  vim.diagnostic.jump({ count = -1, float = true })
end, { desc = 'Previous diagnostic' })
map('n', ']d', function()
  vim.diagnostic.jump({ count = 1, float = true })
end, { desc = 'Next diagnostic' })
map('n', '<leader>xd', vim.diagnostic.open_float, { desc = 'Line diagnostics' })
map('n', '<leader>xq', vim.diagnostic.setqflist, { desc = 'All diagnostics' })
