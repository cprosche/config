# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="gruvbox"
SOLARIZED_THEME="dark"

# Plugins
plugins=(git)

source $ZSH/oh-my-zsh.sh

# Source common shell config (aliases, exports, etc.)
[ -f ~/.shell_common ] && source ~/.shell_common

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# zoxide (cd replacement)
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init --cmd cd zsh)"
fi
