# Neovim for programming

This setup targets web development, Rust, and C on Neovim 0.12+. Space is the leader key. It uses `lazy.nvim` for plugins and Mason for language servers and formatting tools.

## First run

1. Start `nvim` and let `lazy.nvim` install missing plugins. Run `:Lazy sync` if installation was interrupted.
2. Run `:Mason` to inspect language tools and `:checkhealth` to inspect editor dependencies.
3. Run `:TSUpdate` after updating the Tree-sitter plugin. Its current branch requires `tree-sitter-cli` for parser installation.
4. Open a project file and use `:checkhealth vim.lsp` to see active LSP configurations. `:ConformInfo` shows the formatter chosen for the current file.

See [DEPENDENCIES.md](DEPENDENCIES.md) for external commands and [KEYBINDS.md](KEYBINDS.md) for the full shortcut list.

Tailwind IntelliSense is off by default because its language server consumed excessive RAM. In a Tailwind project, run `:MasonInstall tailwindcss-language-server` once, then `:lsp enable tailwindcss` when needed. `:lsp disable tailwindcss` stops it; the next Neovim start returns to the lighter default.

For Bun tests, add `@types/bun` to each project's development dependencies, list `bun` in that project's `tsconfig.json` `compilerOptions.types`, and include test files in the TypeScript project. The Bun executable alone does not provide editor type declarations.

## Everyday workflow

- `<Space>sf` finds a file; `<Space>sg` searches text in the project; `<Space>e` toggles the file tree on the left; `-` opens the current directory in Oil.
- `gd` jumps to a definition, `gr` finds references, `<Space>ca` opens code actions, and `<Space>cf` formats.
- `<Space>wv` and `<Space>wh` split the editor. `Alt+h/j/k/l` moves through editor splits; `Alt+Arrow` resizes them.
- `<Space>gg` opens Neogit; `<Space>gp` previews the current Git hunk.
- `F5` starts debugging C/Rust programs with GDB. Build with debug symbols first; the launch prompt asks for the executable path.
- `<Space>ut` opens the live theme picker. Move through themes with `j/k`, press Enter to keep one, or `q`/Esc to restore the previous theme. The selected theme is remembered across restarts.

For JavaScript and TypeScript, formatting follows the project's tool files. ESLint configuration enables ESLint autofixes; Prettier configuration or a local Prettier install enables Prettier afterward. With neither configured, the Mason Prettier installation is the fallback. Conform prefers `node_modules/.bin/prettier` over Mason's executable and reads the project's Prettier settings. Use `:ConformInfo` to see the active tools. The live `:substitute` preview is disabled to keep command entry responsive.

## Change this setup yourself

| Goal | Edit or command |
| --- | --- |
| Editor options | `lua/config/options.lua` |
| General shortcuts | `lua/config/keymaps.lua` |
| Plugin settings | `lua/plugins/*.lua` |
| LSP servers and Tree-sitter parsers | `lua/plugins/languages.lua` |
| Formatters | `lua/plugins/editing.lua` |
| Theme choices | `lua/config/theme.lua` |
| Update plugins | `:Lazy update` |
| Install another language server | `:Mason` and `lua/plugins/languages.lua` |

To add a plugin, create another Lua file in `lua/plugins/` that returns a [lazy.nvim plugin specification](https://lazy.folke.io/spec). For example, a file returning `{ 'folke/todo-comments.nvim', opts = {} }` adds highlighted TODO comments. Use `:Lazy sync` after adding or removing plugins. The lockfile records the installed plugin revisions once sync succeeds.

Optional additions to consider after using the core setup: [todo-comments.nvim](https://github.com/folke/todo-comments.nvim) for task markers, [nvim-dap-vscode-js](https://github.com/mxsdev/nvim-dap-vscode-js) for browser/Node debugging, and [image.nvim](https://github.com/3rd/image.nvim) for terminal image previews. Each adds dependencies or configuration; keep only the ones you use. AI completion is intentionally opt-in. The previous config and its settings are preserved in the timestamped `nvim.backup-*` folder beside this directory.

## Quick tips

- Press Space to see grouped shortcuts; `<Space>sk` searches mapped keys and descriptions across editor modes. Add `desc = 'Your action'` to a `vim.keymap.set` mapping to make it easy to find. Buffer-local mappings appear when that buffer is active.
- `<Space>uf` disables or enables format on save for the current buffer.
- `:Theme onelight` switches to a light theme; `:Theme monokai_pro` or `:Theme kanagawa-wave` selects another. `:Theme` previews every available theme, including four Monokai variants.
- `:Lazy profile` helps identify slow plugins, and `:Lazy health` checks plugin manager health.
- To restore the previous config, move this `nvim` folder aside and rename the chosen `nvim.backup-*` folder to `nvim`.
