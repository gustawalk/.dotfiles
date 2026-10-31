if status is-interactive; and not set -q RICE_SKIP_BANNER
    set -l pokemon (random choice haunter gengar sylveon vaporeon eevee fennekin)
    set -l sprite "$__fish_config_dir/pokemon/$pokemon"
    if test -r "$sprite"
        cat "$sprite"
        echo
    end
end

# Settings {{{
set -g fish_greeting
set -g fish_color_command magenta
set -g fish_color_param blue
set -x PATH /usr/local/bin /usr/bin /bin /usr/sbin /sbin $PATH

set -gx CONFIG_DIR "$HOME/.config/"
set -gx DOTFILES_DIRECTORY "$HOME/.dotfiles"
set -gx ASDF_CONFIG_FILE "$HOME/.config/asdf/asdfrc"
if test -f "$HOME/.config/ripgrep/ripgreprc"
    set -gx RIPGREP_CONFIG_PATH "$HOME/.config/ripgrep/ripgreprc"
else
    set -e RIPGREP_CONFIG_PATH
end
set -gx FZF_DEFAULT_OPTS '--height=50% --layout=reverse'
set -gx FZF_DEFAULT_COMMAND 'rg --files --no-ignore-vcs --hidden'
set -gx SHELL (status fish-path)
if status is-interactive; and isatty stdin
    set -gx GPG_TTY (tty)
end
set -gx EDITOR nvim
set -gx EVENT_NOKQUEUE 1
set -gx HOMEBREW_FORCE_VENDOR_RUBY 1
set -gx HOMEBREW_NO_ENV_HINTS 1
# }}}

# Aliases {{{

alias notes "nvim $HOME/notes.md"

# don't send terminal type 'alacritty' through ssh
alias ssh "env TERM=xterm-256color ssh"
alias rails "env TERM=xterm-256color rails"
alias startvenv "source ~/.venv/bin/activate.fish"
# config files
alias nc "cd $CONFIG_DIR/nvim"
alias fc "cd $CONFIG_DIR/fish"
alias hc "cd $CONFIG_DIR/hypr"

alias tt "cd $DOTFILES_DIRECTORY && $EDITOR ~/.config/tmux/tmux.conf && cd -"
alias aa "cd $DOTFILES_DIRECTORY && $EDITOR ~/.config/alacritty/alacritty.yml && cd -"
alias vv "cd $DOTFILES_DIRECTORY && $EDITOR ~/.config/nvim/init.lua && cd -"
alias ff "cd $DOTFILES_DIRECTORY && $EDITOR ~/.config/fish/config.fish && cd -"
alias zx "source ~/.config/fish/config.fish"
alias cls clear
# gpg-agent
alias gpg-add "echo | gpg -s >/dev/null >&1"
alias myip "curl -4 ifconfig.me"
#}}}

# Abbreviations {{{
# git
abbr n. 'nvim .'
abbr n, 'nvim .'
abbr g. 'git add .'
abbr gc 'git commit -m'
abbr gco 'git checkout'
abbr gd 'git diff'
abbr gl 'git log'
abbr gp 'git push'
abbr gpl 'git pull'
abbr gg 'git status'
abbr gs 'git stash'
abbr gsp 'git stash pop'
abbr nr 'npm run dev'
abbr upup 'sudo pacman -Syu --noconfirm'

# vim / vim-isms
abbr v "$EDITOR ."
abbr vip "nvim '+Lazy sync'"
abbr vup "nvim '+Lazy update'"
# }}}

# Utility functions {{{

function replay-buffer --description "Toggle GPU-SR Service"
    if systemctl --user is-active --quiet gpu-screen-recorder.service
        systemctl --user stop gpu-screen-recorder.service
        echo "GPU Screen Buffer stopped"
        notify-send "Screen Buffer stopped"
    else
        systemctl --user start --now gpu-screen-recorder.service
        echo "GPU Screen Buffer started"
        notify-send "Screen Buffer started"
    end
end

function kp --description "Kill processes"
    set -l __kp__pid ''
    set __kp__pid (ps -ef | sed 1d | eval "fzf $FZF_DEFAULT_OPTS -m --header='[kill:process]'" | awk '{print $2}')

    if test "x$__kp__pid" != x
        if test "x$argv[1]" != x
            echo $__kp__pid | xargs kill $argv[1]
        else
            echo $__kp__pid | xargs kill -9
        end
        kp
    end
end

function gcb --description "Delete git branches"
    set delete_mode -d

    if contains -- --force $argv
        set force_label ':force'
        set delete_mode -D
    end

    set -l branches_to_delete (git branch | sed -E 's/^[* ] //g' | fzf -m --header="[git:branch:delete$force_label]")

    if test -n "$branches_to_delete"
        git branch $delete_mode $branches_to_delete
    end
end

function fish_prompt --description 'Write out the prompt'
    switch $status
        case 0
            set_color green
        case 127
            set_color yellow
        case '*'
            set_color red
    end

    set_color --bold
    echo -n 'Walk '
    set_color blue
    echo -n (prompt_pwd)

    # One Git invocation per redraw, without refreshing the index on disk.
    set -l git_info (command git --no-optional-locks status --porcelain=v1 --branch 2>/dev/null)
    if set -q git_info[1]
        set -l branch (string replace -r '^## (.*?)(\.\.\..*)?$' '$1' -- $git_info[1])
        set branch (string replace -r '^(No commits yet on|Initial commit on) ' '' -- $branch)
        set_color yellow
        echo -n " on "
        set_color green
        echo -n $branch

        if set -q git_info[2]
            set_color magenta
        end

        echo -n ' ⚑'
    end

    set_color blue
    echo -n ' ❯ '
    set_color normal
end
# }}}

# GPG {{{
# }}}

# Sourcing {{{
[ -f /opt/homebrew/share/autojump/autojump.fish ]; and source /opt/homebrew/share/autojump/autojump.fish
[ -f /opt/homebrew/opt/asdf/libexec/asdf.fish ]; and source /opt/homebrew/opt/asdf/libexec/asdf.fish
# }}}

# pnpm
set -gx PNPM_HOME "$HOME/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end
fish_add_path "$HOME/.local/bin"

# opencode
if test -d "$HOME/.opencode/bin"
    fish_add_path "$HOME/.opencode/bin"
end
set -gx POKEMON_ICAT_DATA "$HOME/.local/share/pokemon-icat"
