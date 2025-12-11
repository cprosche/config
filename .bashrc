# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# History settings
HISTCONTROL=ignoreboth
shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=2000

# Check window size after each command
shopt -s checkwinsize

# Make less more friendly for non-text input files
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Prompt
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt

# Enable color support of ls
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Bash completion
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

# Source machine-specific config
[ -f ~/.bashrc_local.sh ] && . ~/.bashrc_local.sh

# Source common shell config (aliases, exports, etc.)
[ -f ~/.shell_common ] && source ~/.shell_common

# Linux-specific: cargo
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# Linux-specific: ssh-agent via keychain
if command -v keychain &> /dev/null; then
    eval "$(keychain --quiet --eval id_rsa 2>/dev/null)"
fi

# zoxide (cd replacement)
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init --cmd cd bash)"
fi

# fzf
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
if command -v fzf &> /dev/null; then
    eval "$(fzf --bash 2>/dev/null)" || true
fi

# envman (if installed)
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"
