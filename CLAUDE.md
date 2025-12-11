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
- `.shell_common` - Shared shell config (aliases, exports) sourced by both zsh and bash
- `.shell_local` - Machine-specific config (gitignored, create manually)
- `.zshrc` - Zsh config (oh-my-zsh, gruvbox theme, sources .shell_common)
- `.bashrc` - Bash config (sources .shell_common and .bashrc_local.sh for machine-specific settings)
- `Makefile` - Quick SSH shortcuts
- `Brewfile` - macOS packages (install with `brew bundle`)
- `.nvim-version` - Pinned neovim version (managed by bob)
- `versions.sh` - Display versions of all installed tools

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
| `nvg` | nvim git changed files |
| `versions` | show tool versions |

## Key Neovim Settings

- Leader key: `;`
- Tabs: 4 spaces
- Format on save enabled
- Spell checking enabled

## Neovim Keybindings

**Telescope:**
- `;fg` - Git files
- `;ff` - Find files
- `;fr` - Recent files
- `;fs` - Live grep
- `;fm` - Git modified files
- `;fc` - Grep string under cursor

**LSP:**
- `gd` - Go to definition
- `gD` - Go to declaration
- `gr` - References
- `gi` - Implementation
- `K` - Hover docs
- `;rn` - Rename symbol
- `;D` - Type definition
- `;d` - Show diagnostics
- `[d` / `]d` - Prev/next diagnostic
- `;ca` - Code actions

**Trouble/Diagnostics:**
- `;xx` - Toggle diagnostics list
- `;xX` - Buffer diagnostics only
- `;xq` - Quickfix list
- `;xt` - TODOs in Trouble
- `;ft` - Find TODOs (Telescope)

**Surround:**
- `ys{motion}{char}` - Add surround (e.g. `ysiw"` wraps word in quotes)
- `ds{char}` - Delete surround (e.g. `ds"` removes quotes)
- `cs{old}{new}` - Change surround (e.g. `cs"'` changes `"` to `'`)

**Other:**
- `;l` - Trigger linting
- `;mp` - Format file
- `gcc` - Comment line
- `gc` - Comment selection
