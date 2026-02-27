return {
  'NvChad/nvim-colorizer.lua',
  event = 'BufRead',
  config = function()
    require('colorizer').setup({
      filetypes = { '*' },
      user_default_options = {
        css = true,
        tailwind = true, -- Enable for tailwind files
      },
    })
  end,
}
