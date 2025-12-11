# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a dotfiles repository managed with GNU Stow. Configuration files are symlinked to the home directory.

## Setup

```bash
cd ~/config
./setup.sh  # installs dependencies + runs stow
```

Or manually with just stow: `stow .`

## Structure

- `.config/nvim/init.lua` - Neovim configuration (lazy.nvim plugin manager, gruvbox theme)
- `.config/alacritty/` - Alacritty terminal configuration
- `.tmux.conf` - Tmux configuration (gruvbox theme)
- `.zshrc` - Zsh config (oh-my-zsh, gruvbox theme)
- `.bashrc` - Bash config (sources `.bashrc_local.sh` for machine-specific settings)
- `Makefile` - Quick SSH shortcuts
- `Brewfile` - macOS packages (install with `brew bundle`)
- `.nvim-version` - Pinned neovim version (managed by bob)

## Shell Aliases

| Alias | Command |
|-------|---------|
| `nv`, `vim` | nvim |
| `m` | make |
| `t` | task |
| `y` | yarn |
| `d` | docker |
| `lg` | lazygit |
| `tm` | tmux |
| `tma` | tmux attach -t |
| `tmkill` | tmux kill-session -t |
| `cat` | bat/batcat |
| `cdf` | cd with fzf |
| `nvf` | nvim with fzf |

## Key Neovim Settings

- Leader key: `;`
- Tabs: 4 spaces
- Format on save enabled
- Spell checking enabled

## Neovim Keybindings

- `;fg` - Telescope git files
- `;ff` - Telescope find files
- `;fr` - Telescope recent files
- `;fs` - Telescope live grep
- `;fc` - Grep string under cursor
- `;l` - Trigger linting
- `;mp` - Format file
- `;ca` - Code actions
- `gcc` - Comment line
- `gc` - Comment selection
