# Cade Rosche's Dotfiles

Dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Quick Start

```bash
git clone git@github.com:cprosche/config.git ~/config
cd ~/config
./setup.sh
```

## What's Included

| Tool | Config |
|------|--------|
| Neovim | lazy.nvim, gruvbox, LSP, Telescope |
| Alacritty | Hack Nerd Font, gruvbox |
| Tmux | gruvbox, mouse support |
| Zsh | oh-my-zsh, gruvbox |
| Bash | fzf, zoxide |

## Manual Setup

If you just want to symlink without installing dependencies:

```bash
cd ~/config
stow .
```
