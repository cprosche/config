#!/usr/bin/env bash
# Display versions of installed tools

printf "%-15s %s\n" "Tool" "Version"
printf "%-15s %s\n" "----" "-------"

check_version() {
    local name=$1
    local cmd=$2
    if version=$(eval "$cmd" 2>/dev/null); then
        printf "%-15s %s\n" "$name" "$version"
    else
        printf "%-15s %s\n" "$name" "not installed"
    fi
}

check_version "neovim" "nvim --version | head -1 | cut -d' ' -f2"
check_version "bob" "bob --version | cut -d' ' -f2"
check_version "tmux" "tmux -V | cut -d' ' -f2"
check_version "alacritty" "alacritty --version | cut -d' ' -f2"
check_version "lazygit" "lazygit --version | sed 's/.*version=\([^,]*\),.*/\1/'"
check_version "fzf" "fzf --version | cut -d' ' -f1"
check_version "bat" "bat --version | cut -d' ' -f2"
check_version "zoxide" "zoxide --version | cut -d' ' -f2"
check_version "stow" "stow --version | head -1 | awk '{print \$NF}'"
check_version "go" "go version | cut -d' ' -f3 | sed 's/go//'"
check_version "rust" "rustc --version | cut -d' ' -f2"
check_version "node" "node --version | sed 's/v//'"
check_version "python" "python3 --version | cut -d' ' -f2"
check_version "zsh" "zsh --version | cut -d' ' -f2"
check_version "bash" "bash --version | head -1 | sed -n 's/.*version \([^ ]*\).*/\1/p'"

echo ""
echo "Pinned versions:"
printf "%-15s %s\n" "nvim (pinned)" "$(cat ~/.config/../nvim-version 2>/dev/null || cat "$(dirname "$0")/.nvim-version" 2>/dev/null || echo 'not set')"

if [ -f "${XDG_CONFIG_HOME:-$HOME/.config}/nvim/lazy-lock.json" ]; then
    echo ""
    echo "Neovim plugins (from lazy-lock.json):"
    jq -r 'to_entries | .[] | "  \(.key): \(.value.commit[0:7])"' "${XDG_CONFIG_HOME:-$HOME/.config}/nvim/lazy-lock.json" 2>/dev/null || echo "  (jq not installed)"
fi
