# Language tools
> One native LSP configuration per language; Mason installs tools

Entry: `lua/plugins/languages.lua`

- `lua/plugins/languages.lua`: Mason installs configured servers; `automatic_enable = false` leaves activation to `vim.lsp.enable()`. This avoids activating unrelated installed servers and duplicate TypeScript clients.
- Tailwind CSS LSP is omitted from both installation and activation lists. Its upstream config can use `.git` as a fallback root and start in non-Tailwind projects; a live process consumed about 7 GB RAM.
- `lua/plugins/languages.lua`: Tree-sitter uses the `main` branch for Neovim 0.12, with parsers in `stdpath('data')/site`. Mason installs `tree-sitter-cli`; run `:TSUpdate` after plugin updates.
- Bun's `bun:test` types are project-local: the project needs `@types/bun`, a `types` entry in `tsconfig.json`, and test files included in that TypeScript project. Installing Bun alone does not supply these declarations to `ts_ls`.
- `lua/plugins/editing.lua`: Conform selects ESLint autofixes when project ESLint configuration exists, then Prettier when project Prettier configuration or a local Prettier binary exists. With neither, it uses Prettier as a fallback. Conform's Prettier command searches `node_modules/.bin` upward before Mason. Mason installs `eslint_d`, Prettier, and StyLua; clang-format and rustfmt come from the system toolchain.
- `lua/plugins/debug.lua`: GDB DAP adapter handles C, C++, and Rust launch configurations; it prompts for an executable built with debug symbols.

Updated: 2026-09-27
