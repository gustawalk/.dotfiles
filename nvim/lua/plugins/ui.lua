return {
  { 'folke/tokyonight.nvim', lazy = false, priority = 1000 },
  { 'olimorris/onedarkpro.nvim', lazy = false, priority = 999 },
  { 'catppuccin/nvim', name = 'catppuccin', lazy = false, priority = 998 },
  { 'rebelot/kanagawa.nvim', lazy = false, priority = 997 },
  { 'EdenEast/nightfox.nvim', lazy = false, priority = 996 },
  { 'ellisonleao/gruvbox.nvim', lazy = false, priority = 995 },
  { 'tanvirtin/monokai.nvim', lazy = false, priority = 994 },
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {
      spec = {
        { '<leader>b', group = 'Buffers' },
        { '<leader>c', group = 'Code' },
        { '<leader>d', group = 'Debug' },
        { '<leader>g', group = 'Git' },
        { '<leader>m', group = 'Move lines' },
        { '<leader>s', group = 'Search' },
        { '<leader>t', group = 'Tabs / terminal' },
        { '<leader>u', group = 'UI' },
        { '<leader>w', group = 'Windows / write' },
        { '<leader>x', group = 'Diagnostics' },
      },
    },
  },
  {
    'nvim-lualine/lualine.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = { options = { theme = 'auto', globalstatus = true, section_separators = '', component_separators = '' } },
  },
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    cmd = 'Telescope',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable('make') == 1
        end,
      },
    },
    keys = {
      {
        '<leader>sf',
        function()
          require('telescope.builtin').find_files()
        end,
        desc = 'Search files',
      },
      {
        '<leader>sg',
        function()
          require('telescope.builtin').live_grep()
        end,
        desc = 'Search project text',
      },
      {
        '<leader>sb',
        function()
          require('telescope.builtin').buffers()
        end,
        desc = 'Search buffers',
      },
      {
        '<leader>sr',
        function()
          require('telescope.builtin').oldfiles()
        end,
        desc = 'Recent files',
      },
      {
        '<leader>sh',
        function()
          require('telescope.builtin').help_tags()
        end,
        desc = 'Search help',
      },
      {
        '<leader>sk',
        function()
          require('telescope.builtin').keymaps({ modes = { 'n', 'i', 'c', 'v', 'x', 's', 'o', 't' }, show_plug = false })
        end,
        desc = 'Search keymaps',
      },
      {
        '<leader>sw',
        function()
          require('telescope.builtin').grep_string()
        end,
        desc = 'Search word under cursor',
      },
    },
    config = function()
      local telescope = require('telescope')
      telescope.setup()
      pcall(telescope.load_extension, 'fzf')
    end,
  },
  {
    'stevearc/oil.nvim',
    keys = {
      { '-', '<cmd>Oil<cr>', desc = 'Browse parent directory' },
    },
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = { default_file_explorer = false, columns = { 'icon' }, view_options = { show_hidden = true } },
  },
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    lazy = false,
    dependencies = { 'nvim-lua/plenary.nvim', 'MunifTanjim/nui.nvim', 'nvim-tree/nvim-web-devicons' },
    keys = {
      { '<leader>e', '<cmd>Neotree toggle filesystem left<cr>', desc = 'Toggle file tree' },
    },
    opts = {
      window = { position = 'left', width = 34 },
      filesystem = {
        hijack_netrw_behavior = 'open_default',
        filtered_items = { visible = true, hide_dotfiles = false, hide_gitignored = false },
      },
    },
  },
  {
    'folke/trouble.nvim',
    cmd = 'Trouble',
    keys = {
      { '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', desc = 'Toggle diagnostics panel' },
      { '<leader>xb', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', desc = 'Buffer diagnostics' },
      { '<leader>xs', '<cmd>Trouble symbols toggle focus=false<cr>', desc = 'Document symbols' },
    },
    opts = {},
  },
}
