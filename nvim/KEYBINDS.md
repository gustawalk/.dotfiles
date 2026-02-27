# Neovim Keybinds

This document outlines the custom keybindings configured in your Neovim setup.
The `<leader>` key is set to **Space**.

---

## Global & Editor Keybinds

These keybinds are mostly defined in your `init.lua` and are available for general editor use.

| Mode     | Keybind       | Description                               |
|----------|---------------|-------------------------------------------|
| Normal   | `<leader>p`   | Replace word under cursor with last yank  |
| Normal   | `<A-j>`       | Move current line down                    |
| Normal   | `<A-k>`       | Move current line up                      |
| Normal   | `<Esc>`       | Clear search highlights                   |
| Normal   | `<leader>q`   | Open diagnostic [Q]uickfix list           |
| Visual   | `p`           | Paste without losing current yank         |
| Visual   | `<A-j>`       | Move selected lines down                  |
| Visual   | `<A-k>`       | Move selected lines up                    |
| Visual   | `<`           | Un-indent selection                       |
| Visual   | `>`           | Indent selection                          |
| Terminal | `<Esc><Esc>`   | Exit terminal mode                        |

### Window Navigation

| Mode   | Keybind | Description                      |
|--------|---------|----------------------------------|
| Normal | `<C-h>` | Move focus to the left window    |
| Normal | `<C-l>` | Move focus to the right window   |
| Normal | `<C-j>` | Move focus to the lower window   |
| Normal | `<C-k>` | Move focus to the upper window   |

### Custom Terminals

| Mode   | Keybind     | Description                               |
|--------|-------------|-------------------------------------------|
| Normal | `<space>st` | Open a new vertical terminal at the bottom|
| Normal | `<c-l>`     | Toggle a horizontal terminal (`toggleterm`) |

---

## Plugin: Telescope (Fuzzy Finder)

Prefix: `<leader>s`

| Mode   | Keybind         | Description                                       |
|--------|-----------------|---------------------------------------------------|
| Normal | `<leader>sh`    | [S]earch [H]elp                                   |
| Normal | `<leader>sk`    | [S]earch [K]eymaps                                |
| Normal | `<leader>sf`    | [S]earch [F]iles                                  |
| Normal | `<leader>ss`    | [S]earch [S]elect Telescope builtin               |
| Normal | `<leader>sw`    | [S]earch current [W]ord                           |
| Normal | `<leader>sg`    | [S]earch by [G]rep                                |
| Normal | `<leader>sd`    | [S]earch [D]iagnostics                            |
| Normal | `<leader>sr`    | [S]earch [R]esume last search                     |
| Normal | `<leader>s.`    | [S]earch Recent Files                             |
| Normal | `<leader><leader>`| Find existing buffers                           |
| Normal | `<leader>/`     | Fuzzily search in current buffer                  |
| Normal | `<leader>s/`    | [S]earch [/] in Open Files                        |
| Normal | `<leader>sn`    | [S]earch [N]eovim configuration files             |

---

## Plugin: LSP (Language Server Protocol)

These keybinds are available when an LSP server is attached to a buffer.

| Mode   | Keybind | Description                      |
|--------|---------|----------------------------------|
| Normal | `gd`    | Go to definition                 |
| Normal | `gD`    | Get definition in a floating window |
| Normal | `gi`    | Go to implementation             |
| Normal | `gr`    | Show References                  |
| Normal | `gl`    | Open diagnostic float            |
| Normal | `<C-k>` | Show signature help              |
| Normal | `K`     | Show hover documentation         |

---

## Plugin: Trouble

Prefixes: `<leader>x` and `<leader>c`

| Mode   | Keybind     | Description                                  |
|--------|-------------|----------------------------------------------|
| Normal | `<leader>xx`| Toggle diagnostics panel                     |
| Normal | `<leader>xX`| Toggle buffer-specific diagnostics           |
| Normal | `<leader>cs`| Toggle code symbols panel                    |
| Normal | `<leader>cl`| Toggle LSP definitions, references, etc.     |
| Normal | `<leader>xL`| Toggle location list panel                   |
| Normal | `<leader>xQ`| Toggle quickfix list panel                   |

---

## Plugin: GitSigns

Prefix: `<leader>h` (Hunk)

| Mode   | Keybind         | Description                             |
|--------|-----------------|-----------------------------------------|
| Normal | `]c`            | Jump to next git change                 |
| Normal | `[c`            | Jump to previous git change             |
| Normal | `<leader>hs`    | Stage hunk                              |
| Visual | `<leader>hs`    | Stage selected lines                    |
| Normal | `<leader>hr`    | Reset hunk                              |
| Visual | `<leader>hr`    | Reset selected lines                    |
| Normal | `<leader>hS`    | Stage buffer                            |
| Normal | `<leader>hu`    | Undo stage hunk                         |
| Normal | `<leader>hR`    | Reset buffer                            |
| Normal | `<leader>hp`    | Preview hunk                            |
| Normal | `<leader>hb`    | Blame line                              |
| Normal | `<leader>hd`    | Diff against index (staged)             |
| Normal | `<leader>hD`    | Diff against last commit                |
| Normal | `<leader>tb`    | Toggle line blame                       |
| Normal | `<leader>tD`    | Toggle display of deleted code          |

---

## Plugin: Debug Adapter Protocol (DAP)

| Mode   | Keybind     | Description                      |
|--------|-------------|----------------------------------|
| Normal | `<F5>`      | Start/Continue debugging         |
| Normal | `<F1>`      | Step Into                        |
| Normal | `<F2>`      | Step Over                        |
| Normal | `<F3>`      | Step Out                         |
| Normal | `<F7>`      | Toggle Debugger UI               |
| Normal | `<leader>b` | Toggle Breakpoint                |
| Normal | `<leader>B` | Set a conditional breakpoint     |

---

## Other Plugins

| Mode   | Keybind     | Plugin / Action                  | Description                      |
|--------|-------------|----------------------------------|----------------------------------|
| Normal | `<leader>f` | Conform                          | [F]ormat buffer                  |
| Normal | `<leader>e` | Neo-tree                         | Toggle file explorer             |
| Normal | `-`         | Oil                              | Open parent directory            |
| Insert | `<C-n>`     | nvim-cmp                         | Select next completion item      |
| Insert | `<C-p>`     | nvim-cmp                         | Select previous completion item  |
| Insert | `<C-y>`     | nvim-cmp                         | Confirm completion               |
| Insert | `<C-l>`     | nvim-cmp / Luasnip               | Jump forward in snippet          |
| Insert | `<C-h>`     | nvim-cmp / Luasnip               | Jump backward in snippet         |
| Insert | `<C-J>`     | Copilot                          | Accept Copilot suggestion        |
| Insert | `<M-]>`     | Copilot                          | Next Copilot suggestion          |
| Insert | `<M-[>`     | Copilot                          | Previous Copilot suggestion      |
