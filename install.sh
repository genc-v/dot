#!/usr/bin/env bash

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"

# --- Package manager detection ---

detect_pkg_manager() {
    if command -v dnf &>/dev/null; then
        echo "dnf"
    elif command -v apt &>/dev/null; then
        echo "apt"
    elif command -v pacman &>/dev/null; then
        echo "pacman"
    elif command -v zypper &>/dev/null; then
        echo "zypper"
    else
        echo "unknown"
    fi
}

pkg_install() {
    local pm="$1"
    shift
    case "$pm" in
        dnf)    sudo dnf install -y "$@" ;;
        apt)    sudo apt install -y "$@" ;;
        pacman) sudo pacman -S --needed --noconfirm "$@" ;;
        zypper) sudo zypper install -y "$@" ;;
    esac
}

# --- Package installation ---

install_packages() {
    local pm
    pm=$(detect_pkg_manager)

    if [ "$pm" = "unknown" ]; then
        echo "Could not detect a supported package manager (dnf, apt, pacman, zypper)."
        echo "Skipping package installation."
        return 1
    fi

    echo "==> Detected package manager: $pm"

    # Common packages (same name across distros)
    local packages=(neovim tmux fish zoxide fzf kitty alacritty)

    # hyprland package name
    case "$pm" in
        pacman) packages+=(hyprland) ;;
        dnf)    packages+=(hyprland) ;;
        apt)    echo "Note: hyprland is not in default apt repos. Install manually or via hyprland.org instructions." ;;
        zypper) echo "Note: hyprland is not in default zypper repos. Install manually or via hyprland.org instructions." ;;
    esac

    echo "Installing packages: ${packages[*]}"
    if [ "$pm" = "apt" ]; then
        sudo apt update
    fi
    pkg_install "$pm" "${packages[@]}"

    # lazygit
    if ! command -v lazygit &>/dev/null; then
        echo "Installing lazygit..."
        case "$pm" in
            dnf)
                sudo dnf copr enable -y dejan/lazygit
                sudo dnf install -y lazygit
                ;;
            pacman)
                sudo pacman -S --needed --noconfirm lazygit
                ;;
            apt)
                LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
                curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
                sudo tar xf /tmp/lazygit.tar.gz -C /usr/local/bin lazygit
                rm /tmp/lazygit.tar.gz
                ;;
            zypper)
                LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
                curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
                sudo tar xf /tmp/lazygit.tar.gz -C /usr/local/bin lazygit
                rm /tmp/lazygit.tar.gz
                ;;
        esac
    else
        echo "lazygit is already installed."
    fi

    # lazydocker (GitHub release script — works everywhere)
    if ! command -v lazydocker &>/dev/null; then
        echo "Installing lazydocker..."
        curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
    else
        echo "lazydocker is already installed."
    fi

    # opencode (npm — works everywhere)
    if ! command -v opencode &>/dev/null; then
        if command -v npm &>/dev/null; then
            echo "Installing opencode..."
            npm install -g opencode-ai
        else
            echo "npm not found — skipping opencode. Install Node.js first."
        fi
    else
        echo "opencode is already installed."
    fi

    echo "==> Packages done."
}

# --- Symlink helpers ---

backup_config() {
    local config_name=$1
    local target_path=$2
    if [ -e "$target_path" ] && [ ! -L "$target_path" ]; then
        echo "Backing up existing $config_name config..."
        mv "$target_path" "${target_path}.backup-$(date +%Y%m%d%H%M%S)"
    fi
}

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

# --- Main ---

echo "Starting dotfiles installation..."

read -rp "Install packages? [y/N] " install_pkgs
if [[ "$install_pkgs" =~ ^[Yy]$ ]]; then
    install_packages
fi

echo "==> Setting up Neovim"
link_config "$DOTFILES_DIR/nvim" "$CONFIG_DIR/nvim"

echo "==> Setting up Tmux"
link_config "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"

echo "==> Setting up Fish"
link_config "$DOTFILES_DIR/fish" "$CONFIG_DIR/fish"

echo "==> Setting up Bash"
link_config "$DOTFILES_DIR/bash/.bashrc" "$HOME/.bashrc"

echo "==> Setting up Hyprland"
link_config "$DOTFILES_DIR/hypr" "$CONFIG_DIR/hypr"

echo "Done! Your dotfiles have been applied."
