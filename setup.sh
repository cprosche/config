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

install_fzf_linux() {
    echo "Installing fzf from GitHub..."
    FZF_VERSION=$(curl -s "https://api.github.com/repos/junegunn/fzf/releases/latest" | grep -Po '"tag_name": "v?\K[^"]*')
    curl -Lo /tmp/fzf.tar.gz "https://github.com/junegunn/fzf/releases/latest/download/fzf-${FZF_VERSION}-linux_amd64.tar.gz"
    tar xf /tmp/fzf.tar.gz -C /tmp fzf
    sudo install /tmp/fzf /usr/local/bin
    rm /tmp/fzf.tar.gz /tmp/fzf
}

install_zoxide_linux() {
    if command -v zoxide &> /dev/null; then
        echo "zoxide already installed"
        return
    fi
    echo "Installing zoxide from GitHub..."
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
}

install_delta_linux() {
    if command -v delta &> /dev/null; then
        echo "delta already installed"
        return
    fi
    echo "Installing git-delta from GitHub..."
    DELTA_VERSION=$(curl -s "https://api.github.com/repos/dandavison/delta/releases/latest" | grep -Po '"tag_name": "\K[^"]*')
    curl -Lo /tmp/delta.deb "https://github.com/dandavison/delta/releases/latest/download/git-delta_${DELTA_VERSION}_amd64.deb"
    sudo dpkg -i /tmp/delta.deb || sudo apt-get install -f -y
    rm /tmp/delta.deb
}

install_tmux_linux() {
    # tmux 3.5+ required to fix SIXEL bug with neovim 0.11+
    local current_version=$(tmux -V 2>/dev/null | grep -oP '\d+\.\d+' || echo "0")
    if [ "$(printf '%s\n' "3.5" "$current_version" | sort -V | head -n1)" = "3.5" ]; then
        echo "tmux $current_version already installed"
        return
    fi
    echo "Installing tmux from source (need 3.5+ for neovim compatibility)..."
    sudo apt install -y libevent-dev ncurses-dev build-essential bison pkg-config
    TMUX_VERSION=$(curl -s "https://api.github.com/repos/tmux/tmux/releases/latest" | grep -Po '"tag_name": "\K[^"]*')
    curl -Lo /tmp/tmux.tar.gz "https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz"
    tar xf /tmp/tmux.tar.gz -C /tmp
    cd /tmp/tmux-${TMUX_VERSION}
    ./configure && make
    sudo make install
    cd - > /dev/null
    rm -rf /tmp/tmux-${TMUX_VERSION} /tmp/tmux.tar.gz
}

install_node_linux() {
    if command -v node &> /dev/null && command -v npm &> /dev/null; then
        echo "Node.js and npm already installed"
        return
    fi
    echo "Installing Node.js via NodeSource..."
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt install -y nodejs
}

install_rust_linux() {
    # Remove system rust to avoid conflicts
    if command -v apt &> /dev/null; then
        echo "Removing system rust packages..."
        sudo apt remove -y rustc cargo 2>/dev/null || true
    fi

    # Clean up any existing rustup state to avoid cross-device link issues in containers
    rm -rf "$HOME/.rustup"

    echo "Installing latest rust via rustup..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
}

install_linux_packages() {
    if command -v apt &> /dev/null; then
        sudo apt update
        sudo apt install -y bat neofetch stow keychain golang \
            python3 python3-pip cmake make gcc unzip curl git sshfs jq
        install_rust_linux
        install_node_linux
        # tmux from source (apt version too old), others from GitHub (not in older Ubuntu repos)
        install_tmux_linux
        install_fzf_linux
        install_lazygit_linux
        install_zoxide_linux
        install_delta_linux
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y tmux fzf bat zoxide neofetch stow keychain golang rust cargo \
            nodejs npm python3 python3-pip cmake make gcc unzip curl git lazygit fuse-sshfs jq git-delta
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm tmux fzf bat zoxide neofetch stow keychain go rust \
            nodejs npm python python-pip cmake make gcc unzip curl git lazygit sshfs jq git-delta
    else
        echo "Unsupported Linux package manager"
        exit 1
    fi
}

install_macos_packages() {
    install_brew
    brew bundle --file="$SCRIPT_DIR/Brewfile"
}

setup_lazygit_macos() {
    # lazygit uses ~/Library/Application Support on macOS instead of ~/.config
    local lg_dir="$HOME/Library/Application Support/lazygit"
    mkdir -p "$lg_dir"
    if [ -f "$lg_dir/config.yml" ] && [ ! -L "$lg_dir/config.yml" ]; then
        rm "$lg_dir/config.yml"
    fi
    ln -sf "$HOME/.config/lazygit/config.yml" "$lg_dir/config.yml"
}

install_windows_packages() {
    if ! command -v scoop &> /dev/null; then
        echo "Installing Scoop..."
        powershell -Command "Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force; irm get.scoop.sh | iex"
    fi
    scoop bucket add extras
    scoop bucket add nerd-fonts
    scoop install tmux fzf bat zoxide neofetch go rust nodejs python cmake make lazygit jq sshfs delta
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

install_claude_code() {
    if command -v claude &> /dev/null; then
        echo "Claude Code CLI already installed"
        return
    fi
    echo "Installing Claude Code CLI..."
    case "$OS" in
        linux|macos)
            curl -fsSL https://claude.ai/install.sh | bash
            ;;
        windows)
            powershell -Command "irm https://claude.ai/install.ps1 | iex"
            ;;
    esac
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

        # Build telescope-fzf-native (requires make)
        local fzf_native_dir="$HOME/.local/share/nvim/lazy/telescope-fzf-native.nvim"
        if [ -d "$fzf_native_dir" ] && [ ! -f "$fzf_native_dir/build/libfzf.so" ]; then
            echo "Building telescope-fzf-native..."
            make -C "$fzf_native_dir"
        fi
    fi
}

# Run installation based on OS
case "$OS" in
    linux)
        install_linux_packages
        install_neovim
        install_nerd_font_linux
        install_claude_code
        ;;
    macos)
        install_macos_packages
        install_neovim
        install_oh_my_zsh
        setup_lazygit_macos
        install_claude_code
        ;;
    windows)
        install_windows_packages
        install_neovim
        install_claude_code
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
