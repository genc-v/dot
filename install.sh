#!/usr/bin/env bash

set -e

echo "Starting dotfiles installation..."

# Define directories
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"

# Backup existing configs
backup_config() {
    local config_name=$1
    local target_path=$2
    if [ -e "$target_path" ] && [ ! -L "$target_path" ]; then
        echo "Backing up existing $config_name config..."
        mv "$target_path" "${target_path}.backup-$(date +%Y%m%d%H%M%S)"
    fi
}

# Symlink configurations
link_config() {
    local source=$1
    local target=$2
    
    mkdir -p "$(dirname "$target")"
    backup_config "$(basename "$source")" "$target"
    
    if [ ! -L "$target" ]; then
        echo "Linking $source to $target..."
        ln -s "$source" "$target"
    else
        echo "$target is already a symlink."
    fi
}

# Apply symlinks
echo "==> Setting up Neovim"
link_config "$DOTFILES_DIR/nvim" "$CONFIG_DIR/nvim"

echo "==> Setting up Tmux"
link_config "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"

echo "==> Setting up Fish"
link_config "$DOTFILES_DIR/fish" "$CONFIG_DIR/fish"

echo "==> Setting up Hyprland"
link_config "$DOTFILES_DIR/hypr" "$CONFIG_DIR/hypr"

echo "Done! Your dotfiles have been applied."
