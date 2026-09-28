# External dependencies

The editor requires Neovim 0.12+, Git, `curl`, `tar`, `make`, a C compiler, and `ripgrep`. `fd` is optional for faster file finding. A Nerd Font improves icons; set `vim.g.have_nerd_font = false` in `init.lua` if you do not use one.

| Purpose | Command / package |
| --- | --- |
| JavaScript and TypeScript servers, Prettier | Node.js and npm |
| Rust server and formatting | Rust toolchain with `rust-analyzer` and `rustfmt` |
| C language server and formatting | `clangd` and `clang-format` |
| C/Rust debugging | GDB 14+ with DAP support; build programs with debug symbols |
| Clipboard on Wayland | `wl-copy` / `wl-paste` (`wl-clipboard`) |
| Clipboard on X11 | `xclip` or `xsel` |
| Tree-sitter parsers | `tree-sitter-cli` 0.26.1+ |

Mason installs the configured language servers, `stylua`, `prettier`, `eslint_d`, and `tree-sitter-cli` into Neovim's data directory when downloads are available. `eslint_d` runs only for JavaScript and TypeScript projects with ESLint configuration. `clang-format`, `rustfmt`, and GDB are expected from your system/toolchain. Check `:Mason`, `:ConformInfo`, and `:checkhealth vim.lsp` if a feature is unavailable.

Health checks may still mention optional Ruby or Julia commands.
