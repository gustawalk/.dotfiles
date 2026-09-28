vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true

require('config.options')
require('config.keymaps')

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  local output = vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    '--branch=stable',
    'https://github.com/folke/lazy.nvim.git',
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    error('Could not install lazy.nvim:\n' .. output)
  end
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({ { import = 'plugins' } }, {
  change_detection = { notify = false },
  rocks = { enabled = false },
  ui = { border = 'rounded' },
})

require('config.theme').setup()
