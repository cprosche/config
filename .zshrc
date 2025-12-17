# History settings
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory
setopt sharehistory
setopt hist_ignore_dups

# Key bindings
bindkey -e

# Completion
autoload -Uz compinit && compinit

# Source common shell config (aliases, exports, etc.)
[ -f ~/.shell_common ] && source ~/.shell_common

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
