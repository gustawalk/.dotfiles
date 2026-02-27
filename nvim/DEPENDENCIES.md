# Dependencies

This file lists the dependencies required to use this Neovim configuration.

## System Dependencies

- **Neovim**: The editor itself.
- **Git**: For plugin management with `lazy.nvim`.
- **Nerd Font**: For icons and a better visual experience.
- **Build Tools**: `make`, `gcc`, and other essentials for building some plugins (e.g., `telescope`).
- **Node.js and npm**: For many LSPs and tools.
- **Python**: For Python LSPs.
- **Go**: For Go LSP.
- **Rust**: For Rust LSP and other tools.
- **Java**: For Java LSP.
- **Kotlin**: For Kotlin LSP.
- **Lua**: For Lua LSP.
- **C/C++**: For C/C++ LSP.
- **Typst**: For Typst LSP.
- **Shell Scripting**: For Bash LSP.

## Installation Scripts

Here are scripts to install the dependencies on different distributions.

### Fedora

```bash
#!/bin/bash

# Update package list
sudo dnf update -y

# Install essential build tools
sudo dnf groupinstall -y "Development Tools"

# Install Neovim, Git, and other dependencies
sudo dnf install -y neovim git curl wget unzip ripgrep fd-find

# Install Node.js and npm
sudo dnf install -y nodejs

# Install Python
sudo dnf install -y python3 python3-pip

# Install Go
sudo dnf install -y golang

# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Install Lua and Luarocks
sudo dnf install -y lua lua-devel
# You might need to build luarocks from source if not in repos

# Install Java (OpenJDK)
sudo dnf install -y java-latest-openjdk-devel

# Install Kotlin
# No official package, can be installed with SDKMAN! or from binaries

# Install C/C++ tools
sudo dnf install -y clang

# Install formatters and linters
sudo npm install -g prettier
sudo pip3 install ruff
cargo install stylua

# Nerd Font (example: FiraCode)
# Download from https://www.nerdfonts.com/ and install manually
# Or use a script to automate it.
```

### Arch Linux

```bash
#!/bin/bash

# Update package list
sudo pacman -Syu --noconfirm

# Install essential build tools
sudo pacman -S --noconfirm base-devel

# Install Neovim, Git, and other dependencies
sudo pacman -S --noconfirm neovim git curl wget unzip ripgrep fd

# Install Node.js and npm
sudo pacman -S --noconfirm nodejs npm

# Install Python
sudo pacman -S --noconfirm python python-pip

# Install Go
sudo pacman -S --noconfirm go

# Install Rust
sudo pacman -S --noconfirm rustup
rustup default stable

# Install Lua and Luarocks
sudo pacman -S --noconfirm lua luarocks

# Install Java (OpenJDK)
sudo pacman -S --noconfirm jdk-openjdk

# Install Kotlin
sudo pacman -S --noconfirm kotlin

# Install C/C++ tools
sudo pacman -S --noconfirm clang

# Install formatters and linters
sudo npm install -g prettier
sudo pip3 install ruff
cargo install stylua

# Nerd Font (example: FiraCode)
sudo pacman -S --noconfirm ttf-firacode-nerd
```

### Ubuntu

```bash
#!/bin/bash

# Update package list
sudo apt update && sudo apt upgrade -y

# Install essential build tools
sudo apt install -y build-essential

# Install Neovim, Git, and other dependencies
sudo apt install -y neovim git curl wget unzip ripgrep fd-find

# Install Node.js and npm
sudo apt install -y nodejs npm

# Install Python
sudo apt install -y python3 python3-pip

# Install Go
sudo apt install -y golang-go

# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Install Lua and Luarocks
sudo apt install -y lua5.4 luarocks

# Install Java (OpenJDK)
sudo apt install -y default-jdk

# Install Kotlin
# No official package, can be installed with SDKMAN! or from binaries

# Install C/C++ tools
sudo apt install -y clang

# Install formatters and linters
sudo npm install -g prettier
sudo pip3 install ruff
cargo install stylua

# Nerd Font (example: FiraCode)
# Download from https://www.nerdfonts.com/ and install manually
# Or use a script to automate it.
```
