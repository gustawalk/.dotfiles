# Neovim shortcuts

`<leader>` is **Space**. Mappings described below are in Normal mode unless a mode is shown.

| Keys                              | Action                                                             |
| --------------------------------- | ------------------------------------------------------------------ |
| `<leader>sf` / `sg` / `sw`        | Search files / project text / word under cursor                    |
| `<leader>sb` / `sr`               | Search open buffers / recent files                                 |
| `<leader>sh` / `sk`               | Search help / keymaps by shortcut or description                   |
| `<leader>e`                      | Toggle the file tree on the left                                    |
| `-`                              | Browse files with Oil                                              |
| `<leader>ww` / `wq`               | Save file / close window                                           |
| `<leader>bn` / `bp` / `bd`        | Next / previous / close buffer                                     |
| `<leader>tn` / `tc` / `th` / `tl` | New / close / previous / next tab                                  |
| `<leader>wv` / `wh` / `wo` / `we` | Vertical split / horizontal split / keep one / equalize            |
| `Alt+h/j/k/l`                     | Move left / down / up / right through editor splits                |
| `Alt+Arrow`                       | Resize current Neovim split                                        |
| `<leader>tt`                      | Open a terminal below                                              |
| `Esc Esc` (Terminal)              | Return to Normal mode                                              |
| `<leader>ut`                      | Preview themes with `j/k` or `Ctrl+d/u`; Enter keeps, Esc cancels  |
| `<leader>uf`                      | Toggle format on save for this buffer                              |

## Code and diagnostics

LSP keys appear when a language server attaches.

| Keys                       | Action                                                      |
| -------------------------- | ----------------------------------------------------------- |
| `gd` / `gD`                | Definition / declaration                                    |
| `gr` / `gi`                | References / implementation                                 |
| `K`                        | Documentation at cursor                                     |
| `<leader>ca` / `cr` / `cs` | Code action / rename / signature help                       |
| `<leader>cf`               | Format current buffer                                       |
| `[d` / `]d`                | Previous / next diagnostic                                  |
| `<leader>xd` / `xq`        | Line diagnostics / all diagnostics in quickfix              |
| `<leader>xx` / `xb` / `xs` | Toggle all diagnostics / buffer diagnostics / symbols panel |

## Git and debugging

Git hunk keys are available inside files tracked by Git.

| Keys                       | Action                                                |
| -------------------------- | ----------------------------------------------------- |
| `[h` / `]h`                | Previous / next Git hunk                              |
| `<leader>gs` / `gr`        | Stage / reset hunk (also works on a visual selection) |
| `<leader>gp` / `gb` / `gd` | Preview hunk / blame line / diff against index        |
| `<leader>gS` / `gu` / `gg` | Stage buffer / undo stage / open Neogit               |
| `F5` / `F6` / `F7`         | Start or continue / stop / toggle debugger UI         |
| `F10` / `F11` / `F12`      | Step over / into / out                                |
| `<leader>db` / `dB`        | Toggle breakpoint / conditional breakpoint            |

## Editing

| Keys                         | Action                                  |
| ---------------------------- | --------------------------------------- |
| `<leader>mj` / `<leader>mk` | Move line or visual selection down / up |
| `<` / `>` (Visual)           | Indent and keep selection               |
| `p` (Visual)                 | Paste without replacing the last yank   |
| `<leader>p`                  | Replace word with the last yank         |
| `Esc`                        | Clear search highlighting               |
| `Ctrl+n` / `Ctrl+p` (Insert) | Next / previous completion              |
| `Ctrl+y` (Insert)            | Accept completion                       |
| `Tab` / `Shift+Tab` (Insert) | Move through snippet placeholders       |

`mini.surround` provides `sa` to add, `sd` to delete, and `sr` to replace surrounding characters. `mini.ai` adds improved `a` and `i` text objects. Run `:help mini.surround` or `:help mini.ai` for examples.
