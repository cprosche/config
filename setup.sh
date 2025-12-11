#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
NVIM_VERSION=$(cat "$SCRIPT_DIR/.nvim-version")

# Detect OS
case "$(uname -s)" in
    Linux*)  OS=linux;;
    Darwin*) OS=macos;;
    MINGW*|MSYS*|CYGWIN*) OS=windows;;
    *)       echo "Unsupported OS"; exit 1;;
esac

echo "Detected OS: $OS"

# Package manager install functions
install_brew() {
    if ! command -v brew &> /dev/null; then
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
}

install_bob() {
    if ! command -v bob &> /dev/null; then
        echo "Installing bob (neovim version manager)..."
        case "$OS" in
            macos)
                brew install bob
                ;;
            linux)
                cargo install bob-nvim
                ;;
            windows)
                scoop install bob
                ;;
        esac
    fi
}

install_neovim() {
    install_bob
    echo "Installing neovim $NVIM_VERSION via bob..."
    bob install "$NVIM_VERSION"
    bob use "$NVIM_VERSION"
}

install_lazygit_linux() {
    if ! command -v lazygit &> /dev/null; then
        echo "Installing lazygit..."
        LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
        curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
        tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
        sudo install /tmp/lazygit /usr/local/bin
        rm /tmp/lazygit.tar.gz /tmp/lazygit
    fi
}

install_linux_packages() {
    if command -v apt &> /dev/null; then
        sudo apt update
        sudo apt install -y tmux fzf bat zoxide neofetch stow keychain golang rustc cargo \
            nodejs npm python3 python3-pip cmake make gcc unzip curl git sshfs jq
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y tmux fzf bat zoxide neofetch stow keychain golang rust cargo \
            nodejs npm python3 python3-pip cmake make gcc unzip curl git lazygit fuse-sshfs jq
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm tmux fzf bat zoxide neofetch stow keychain go rust \
            nodejs npm python python-pip cmake make gcc unzip curl git lazygit sshfs jq
    else
        echo "Unsupported Linux package manager"
        exit 1
    fi
    # lazygit not in apt, install from GitHub
    if command -v apt &> /dev/null; then
        install_lazygit_linux
    fi
}

install_macos_packages() {
    install_brew
    brew bundle --file="$SCRIPT_DIR/Brewfile"
}

install_windows_packages() {
    if ! command -v scoop &> /dev/null; then
        echo "Installing Scoop..."
        powershell -Command "Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force; irm get.scoop.sh | iex"
    fi
    scoop bucket add extras
    scoop bucket add nerd-fonts
    scoop install tmux fzf bat zoxide neofetch go rust nodejs python cmake make lazygit jq sshfs
    scoop install alacritty
    scoop install Hack-NF
}

install_oh_my_zsh() {
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo "Installing oh-my-zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        # Install gruvbox theme
        curl -fsSL https://raw.githubusercontent.com/sbugzu/gruvbox-zsh/master/gruvbox.zsh-theme \
            -o "$HOME/.oh-my-zsh/themes/gruvbox.zsh-theme"
    fi
}

install_nerd_font_linux() {
    FONT_DIR="$HOME/.local/share/fonts"
    mkdir -p "$FONT_DIR"
    if [ ! -f "$FONT_DIR/HackNerdFont-Regular.ttf" ]; then
        echo "Installing Hack Nerd Font..."
        curl -fsSL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip -o /tmp/Hack.zip
        unzip -o /tmp/Hack.zip -d "$FONT_DIR"
        fc-cache -fv
        rm /tmp/Hack.zip
    fi
}

check_nvim_dependencies() {
    echo "Checking neovim plugin dependencies..."
    local missing=()

    command -v node &> /dev/null || missing+=("node")
    command -v npm &> /dev/null || missing+=("npm")
    command -v python3 &> /dev/null || missing+=("python3")
    command -v pip3 &> /dev/null || missing+=("pip3")
    command -v go &> /dev/null || missing+=("go")
    command -v cargo &> /dev/null || missing+=("cargo")
    command -v make &> /dev/null || missing+=("make")
    command -v gcc &> /dev/null && command -v cc &> /dev/null || missing+=("gcc/cc")

    if [ ${#missing[@]} -ne 0 ]; then
        echo "WARNING: Missing dependencies: ${missing[*]}"
        echo "Some neovim plugins may not work correctly."
        return 1
    fi
    echo "All dependencies found!"
}

setup_neovim_plugins() {
    echo "Setting up neovim plugins..."
    # Restore pinned plugin versions from lazy-lock.json
    if command -v nvim &> /dev/null; then
        nvim --headless "+Lazy! restore" +qa 2>/dev/null || true
        echo "Neovim plugins restored to pinned versions"
    fi
}

# Run installation based on OS
case "$OS" in
    linux)
        install_linux_packages
        install_neovim
        install_nerd_font_linux
        install_oh_my_zsh
        ;;
    macos)
        install_macos_packages
        install_neovim
        install_oh_my_zsh
        ;;
    windows)
        install_windows_packages
        install_neovim
        ;;
esac

# Stow dotfiles
echo "Symlinking dotfiles with stow..."
cd "$SCRIPT_DIR"
stow .

# Check dependencies and setup neovim
check_nvim_dependencies || true
setup_neovim_plugins

echo "Setup complete!"
echo "Neovim version: $NVIM_VERSION (managed by bob)"
echo "Run 'bob list' to see installed versions"
