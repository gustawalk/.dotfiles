vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'
vim.opt.showmode = false
vim.opt.termguicolors = true
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = 'yes'
vim.opt.updatetime = 250
vim.opt.timeoutlen = 350
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.scrolloff = 6
vim.opt.sidescrolloff = 6
vim.opt.cursorline = true
vim.opt.inccommand = ''
vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Use the desktop clipboard when a provider is available.
if vim.fn.executable('wl-copy') == 1 or vim.fn.executable('xclip') == 1 or vim.fn.executable('xsel') == 1 then
  vim.opt.clipboard = 'unnamedplus'
end

vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('HighlightYank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

vim.api.nvim_create_autocmd('TermOpen', {
  group = vim.api.nvim_create_augroup('TerminalOptions', { clear = true }),
  callback = function()
    vim.wo.number = false
    vim.wo.relativenumber = false
    vim.cmd.startinsert()
  end,
})
