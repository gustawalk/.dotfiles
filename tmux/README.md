# tmux for programming

The config is `~/.config/tmux/tmux.conf` and uses a Tokyo Night dark palette. Start with `tmux new -s project`; later use `tmux attach -t project`.

## Save sessions across reboots

Install [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect) once:

```sh
git clone https://github.com/tmux-plugins/tmux-resurrect.git ~/.config/tmux/plugins/tmux-resurrect
tmux source-file ~/.config/tmux/tmux.conf
```

Before rebooting, press **Ctrl+b**, then **Ctrl+s** to save. After rebooting, start tmux (`tmux` or `tmux new -s project`) and press **Ctrl+b**, then **Ctrl+r** to restore. These shortcuts also work with the secondary **Ctrl+a** prefix. A save includes all current sessions, window names and order, pane arrangement and sizes, active panes, and each pane's working directory. Restore into a fresh tmux server for the closest match.

Tmux-resurrect restores common terminal programs such as Neovim by default, but it does not preserve a program's in-memory state or restore arbitrary commands unless configured separately. Save files live in tmux-resurrect's data directory (usually `~/.local/share/tmux/resurrect` or `~/.tmux/resurrect`). To check that a save exists, run `ls -l ~/.local/share/tmux/resurrect/last ~/.tmux/resurrect/last 2>/dev/null`.

For a tmux server that was already running when this file was added, run `tmux source-file ~/.config/tmux/tmux.conf` once to load it.

The main prefix is **Ctrl+b**. Press **Ctrl+b Ctrl+b** to send Ctrl+b to the shell. **Ctrl+a** remains a secondary prefix so **Ctrl+a s** still opens the session list; press **Ctrl+a Ctrl+a** to send Ctrl+a to the shell. A tmux **window** is a tab; a **pane** is a split within a window.

The dim dot beside the session name turns amber while tmux is waiting for the next key after either prefix. It returns to its dim color after the command.

| Keys | Action |
| --- | --- |
| `Ctrl+b |` / `Ctrl+b -` | Split left/right / top/bottom in the current directory |
| `Alt+h/j/k/l` | Move between tmux panes and Neovim splits, without a prefix |
| `Alt+Shift+h/j/k/l` | Resize the current tmux pane, without a prefix |
| `Ctrl+b h/j/k/l` | Move between panes when Alt is unavailable |
| `Ctrl+b H/J/K/L` | Swap the current pane with its neighbor; the split layout stays the same |
| `Ctrl+b Ctrl+m` or `Ctrl+a Ctrl+m`, then `h/j/k/l` | Enter pane-move mode; move the active pane left / down / up / right and change the split layout. Keep pressing directions; `q` or Esc exits |
| `Ctrl+b Ctrl+Arrow` | Resize the current pane when Alt+Shift is unavailable |
| `Ctrl+b z` | Zoom or restore a pane |
| `Ctrl+b e` | Tile panes evenly |
| `Ctrl+b c` | New window in the current directory |
| `Ctrl+b n/p` | Next / previous window |
| `Ctrl+b 1` through `9` | Jump to a numbered window |
| `Ctrl+b <` / `Ctrl+b >` | Move the current window left / right, keeping focus on it |
| `Ctrl+b ,` | Rename window |
| `Ctrl+b .` | Move window to a chosen index |
| `Ctrl+b x` / `Ctrl+b X` | Close the current pane / window, with confirmation |
| `Ctrl+b s` or `Ctrl+a s` | Show available sessions using the full window with a preview; `+` expands a session to select a pane, and `v` toggles the preview |
| `Ctrl+b w` | Show the window and pane tree |
| `Ctrl+b [` | Enter scroll and copy mode; use `v` to select and `y` to copy |
| `Ctrl+b d` | Detach from the session |
| `Ctrl+b Ctrl+s` / `Ctrl+b Ctrl+r` | Save all sessions / restore the last save |
| `Ctrl+b R` | Reload this configuration |

Pane-move mode changes which panes span a row or column. For example, with pane 2 filling the left side and panes 1 and 3 stacked on the right, focus pane 3 and press `Ctrl+b Ctrl+m h`: pane 1 then fills the right side while panes 2 and 3 stack on the left. With pane 3 filling the bottom and panes 1 and 2 across the top, focus pane 2 and press `Ctrl+b Ctrl+m j`: pane 1 then fills the top while panes 3 and 2 share the bottom. Direction keys select a neighboring pane as the insertion point; if there is no pane in that direction, the layout stays as it is.

Most terminals send `Ctrl+m` and Enter as the same key, so `Ctrl+b Enter` and `Ctrl+a Enter` also enter pane-move mode.

Mouse selection and scrolling are enabled. The `y` copy shortcut uses `wl-copy`; install `wl-clipboard` on Wayland. For another clipboard provider, change that command in `tmux.conf`. Your terminal should support `tmux-256color` and true color for the intended appearance.

To change the theme, edit the hex colors near the end of `tmux.conf` and press `Ctrl+b R`. To add a shortcut, use `bind` for a prefix key or `bind -n` for a direct key. Test direct keys carefully because they replace the terminal application's own shortcut.

Some terminals do not send a distinct Alt+Shift+letter key. If resizing does not respond, check the terminal's Alt/Meta key handling; use `Ctrl+b Ctrl+Arrow` as a fallback.
