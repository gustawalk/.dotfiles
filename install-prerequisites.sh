#!/usr/bin/env bash
set -euo pipefail

# Installs packages used by the configs. It never changes or links dotfiles.
dry_run=false
os_override=''

usage() {
  cat <<'EOF'
Usage: ./install-prerequisites.sh [--dry-run] [--os arch|debian|fedora|macos]

Interactively select dependency groups for this dotfiles repository.
--dry-run prints the commands without installing anything.
--os previews another OS and is accepted only with --dry-run.
EOF
}

while (($#)); do
  case "$1" in
    --dry-run) dry_run=true ;;
    --os)
      (($# >= 2)) || { echo 'Missing value for --os' >&2; exit 2; }
      os_override=$2
      shift
      ;;
    --help|-h) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

if [[ -n $os_override && $dry_run != true ]]; then
  echo '--os is only available with --dry-run.' >&2
  exit 2
fi

detect_os() {
  if [[ -n $os_override ]]; then
    case "$os_override" in arch|debian|fedora|macos) printf '%s' "$os_override" ;; *) return 1 ;; esac
    return
  fi
  if [[ $(uname -s) == Darwin ]]; then
    printf macos
    return
  fi
  [[ -r /etc/os-release ]] || return 1
  # os-release is shell-compatible and supplied by the operating system.
  . /etc/os-release
  case " ${ID:-} ${ID_LIKE:-} " in
    *' arch '*|*' manjaro '*) printf arch ;;
    *' debian '*|*' ubuntu '*) printf debian ;;
    *' fedora '*|*' rhel '*) printf fedora ;;
    *) return 1 ;;
  esac
}

os=$(detect_os) || { echo 'Unsupported OS. Supported: Arch, Debian/Ubuntu, Fedora, macOS.' >&2; exit 1; }

ask() {
  local question=$1 default=$2 answer
  while true; do
    if [[ $default == yes ]]; then
      printf '%s [Y/n] ' "$question" >&2
    else
      printf '%s [y/N] ' "$question" >&2
    fi
    IFS= read -r answer || { echo 'Input ended before selection.' >&2; exit 1; }
    case "${answer,,}" in
      y|yes) return 0 ;;
      n|no) return 1 ;;
      '') [[ $default == yes ]] ; return ;;
      *) echo 'Please answer y or n.' >&2 ;;
    esac
  done
}

echo "Detected package family: $os"
core=false editor=false languages=false desktop=false aur=false
if ask 'Install shell tools (Fish, tmux, Git, search, build tools)?' yes; then core=true; fi
if ask 'Install Neovim, Node.js and editor dependencies?' yes; then editor=true; fi
if ask 'Install optional C and Rust language tools?' no; then languages=true; fi
if [[ $os == arch ]]; then
  if ask 'Install the Arch Hyprland/Waybar desktop dependencies?' no; then desktop=true; fi
fi

declare -a packages=()
declare -A seen=()
add_packages() {
  local package
  for package in "$@"; do
    if [[ ! -v seen[$package] ]]; then
      seen[$package]=1
      packages+=("$package")
    fi
  done
}

case "$os" in
  arch)
    if $core; then add_packages git curl tar unzip base-devel ripgrep fd fzf jq fish tmux; fi
    if $editor; then add_packages git curl tar unzip make gcc ripgrep neovim nodejs npm tree-sitter-cli ttf-jetbrains-mono-nerd; fi
    if $languages; then add_packages clang gdb rustup; fi
    if $desktop; then
      add_packages hyprland hyprlock hypridle hyprpicker xdg-desktop-portal-hyprland \
        waybar swaync rofi wl-clipboard cliphist grim slurp playerctl brightnessctl \
        network-manager-applet blueman kitty foot imagemagick ffmpeg libnotify \
        bc pavucontrol pamixer yad sox xdg-user-dirs swappy polkit-gnome jq
    fi
    ;;
  debian)
    if $core; then add_packages git curl tar unzip build-essential ripgrep fd-find fzf jq fish tmux; fi
    if $editor; then add_packages git curl tar unzip build-essential ripgrep neovim nodejs npm; fi
    if $languages; then add_packages clang clangd clang-format gdb rustc cargo rustfmt; fi
    ;;
  fedora)
    if $core; then add_packages git curl tar unzip make gcc ripgrep fd-find fzf jq fish tmux; fi
    if $editor; then add_packages git curl tar unzip make gcc ripgrep neovim nodejs nodejs-npm; fi
    if $languages; then add_packages clang clang-tools-extra gdb rust cargo rustfmt; fi
    ;;
  macos)
    if $core; then add_packages git ripgrep fd fzf jq fish tmux; fi
    if $editor; then add_packages git ripgrep neovim node; fi
    if $languages; then add_packages clang-format rust; fi
    ;;
esac

if ((${#packages[@]} == 0)); then
  echo 'No groups selected.'
  exit 0
fi

declare -a command=()
case "$os" in
  arch) command=(pacman -Syu --needed --noconfirm "${packages[@]}") ;;
  debian) command=(apt-get install -y "${packages[@]}") ;;
  fedora) command=(dnf install -y "${packages[@]}") ;;
  macos) command=(brew install "${packages[@]}") ;;
esac

print_command() {
  printf '  '
  printf '%q ' "$@"
  printf '\n'
}

echo
echo 'Planned package commands:'
if [[ $os == debian ]]; then print_command sudo apt-get update; fi
if [[ $os == macos ]]; then print_command "${command[@]}"; else print_command sudo "${command[@]}"; fi

aur_helper=''
if $desktop; then
  aur_helper=$(command -v paru || command -v yay || true)
  if [[ -n $aur_helper ]]; then
    if ask 'Install wallust, wlogout and swww from the AUR with your existing helper?' no; then aur=true; fi
    if $aur; then print_command "$aur_helper" -S --needed wallust wlogout swww; fi
  else
    echo 'AUR extras wallust, wlogout and swww need a separately installed AUR helper.'
  fi
  echo 'The optional AGS panel and any other AUR-only apps need separate setup.'
fi

if $dry_run; then
  echo 'Dry run complete; no packages were installed.'
  exit 0
fi

if ! ask 'Run these package commands now?' no; then
  echo 'Cancelled.'
  exit 0
fi

if [[ $os == macos ]]; then
  command -v brew >/dev/null || { echo 'Install Homebrew first: https://brew.sh/' >&2; exit 1; }
  xcode-select -p >/dev/null 2>&1 || { echo 'Install Xcode Command Line Tools first: xcode-select --install' >&2; exit 1; }
  "${command[@]}"
else
  command -v "${command[0]}" >/dev/null || { echo "Missing package manager: ${command[0]}" >&2; exit 1; }
  if ((EUID == 0)); then
    if [[ $os == debian ]]; then apt-get update; fi
    "${command[@]}"
  else
    command -v sudo >/dev/null || { echo 'sudo is required for system packages.' >&2; exit 1; }
    if [[ $os == debian ]]; then sudo apt-get update; fi
    sudo "${command[@]}"
  fi
fi

if $aur; then "$aur_helper" -S --needed wallust wlogout swww; fi
if $languages && [[ $os == arch ]] && command -v rustup >/dev/null; then
  rustup default stable
fi
if $editor && command -v nvim >/dev/null; then
  version=$(nvim --version | head -n 1)
  if [[ $version =~ NVIM[[:space:]]v([0-9]+)\.([0-9]+) ]]; then
    major=${BASH_REMATCH[1]} minor=${BASH_REMATCH[2]}
    if ((major == 0 && minor < 12)); then
      echo "Warning: $version is older than the required Neovim 0.12. Install a newer release from https://neovim.io/." >&2
    fi
  fi
fi
echo 'Dependencies installed. Read README.md to link only the configs you want.'
