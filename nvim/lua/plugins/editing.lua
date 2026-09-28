local prettier_configs = {
  '.prettierrc',
  '.prettierrc.json',
  '.prettierrc.yaml',
  '.prettierrc.yml',
  '.prettierrc.js',
  '.prettierrc.cjs',
  '.prettierrc.mjs',
  '.prettierrc.toml',
  'prettier.config.js',
  'prettier.config.cjs',
  'prettier.config.mjs',
}
local eslint_configs = {
  'eslint.config.js',
  'eslint.config.cjs',
  'eslint.config.mjs',
  'eslint.config.ts',
  'eslint.config.cts',
  'eslint.config.mts',
  '.eslintrc',
  '.eslintrc.json',
  '.eslintrc.js',
  '.eslintrc.cjs',
  '.eslintrc.yaml',
  '.eslintrc.yml',
}

local function source_dir(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr)
  return name ~= '' and vim.fs.dirname(name) or nil
end

local function has_config(dir, names)
  return dir and #vim.fs.find(names, { path = dir, upward = true }) > 0
end

local function package_field(dir, field)
  if not dir then
    return false
  end
  for _, path in ipairs(vim.fs.find('package.json', { path = dir, upward = true, limit = math.huge })) do
    local ok, pkg = pcall(vim.json.decode, table.concat(vim.fn.readfile(path), '\n'))
    if ok and type(pkg) == 'table' and pkg[field] ~= nil then
      return true
    end
  end
  return false
end

local function local_binary(dir, name)
  if not dir then
    return false
  end
  for _, path in ipairs(vim.fs.find('node_modules', { path = dir, upward = true, limit = math.huge })) do
    if vim.fn.executable(path .. '/.bin/' .. name) == 1 then
      return true
    end
  end
  return false
end

local function web_formatters(bufnr)
  local dir = source_dir(bufnr)
  local has_eslint = has_config(dir, eslint_configs) or package_field(dir, 'eslintConfig')
  local has_prettier = has_config(dir, prettier_configs)
    or package_field(dir, 'prettier')
    or local_binary(dir, 'prettier')
  local formatters = {}
  if has_eslint then
    table.insert(formatters, 'eslint_d')
  end
  if has_prettier or not has_eslint then
    table.insert(formatters, 'prettier')
  end
  return formatters
end

return {
  { 'tpope/vim-sleuth', event = { 'BufReadPre', 'BufNewFile' } },
  {
    'echasnovski/mini.nvim',
    version = false,
    event = 'VeryLazy',
    config = function()
      require('mini.ai').setup()
      require('mini.surround').setup()
    end,
  },
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    dependencies = { 'hrsh7th/nvim-cmp' },
    opts = {},
    config = function(_, opts)
      require('nvim-autopairs').setup(opts)
      local ok, cmp = pcall(require, 'cmp')
      if ok then
        cmp.event:on('confirm_done', require('nvim-autopairs.completion.cmp').on_confirm_done())
      end
    end,
  },
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
    },
    config = function()
      local cmp = require('cmp')
      local luasnip = require('luasnip')
      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<C-p>'] = cmp.mapping.select_prev_item(),
          ['<C-y>'] = cmp.mapping.confirm({ select = true }),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.confirm({ select = true })
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'path' },
          { name = 'buffer' },
        }),
      })
    end,
  },
  {
    'stevearc/conform.nvim',
    event = 'BufWritePre',
    cmd = 'ConformInfo',
    keys = {
      {
        '<leader>cf',
        function()
          require('conform').format({ async = true, lsp_format = 'fallback' })
        end,
        desc = 'Format buffer',
      },
    },
    opts = {
      format_on_save = function(bufnr)
        if vim.b[bufnr].disable_autoformat then
          return
        end
        return { timeout_ms = 2000, lsp_format = 'fallback' }
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        javascript = web_formatters,
        javascriptreact = web_formatters,
        typescript = web_formatters,
        typescriptreact = web_formatters,
        html = { 'prettier' },
        css = { 'prettier' },
        scss = { 'prettier' },
        json = { 'prettier' },
        markdown = { 'prettier' },
        c = { 'clang_format' },
        cpp = { 'clang_format' },
        rust = { 'rustfmt' },
      },
      default_format_opts = { lsp_format = 'fallback' },
      notify_on_error = true,
    },
  },
}
