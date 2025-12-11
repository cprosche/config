#!/usr/bin/env bash
# Reset and reinstall all neovim plugins

echo "Removing neovim plugin cache..."
rm -rf ~/.local/share/nvim/lazy
rm -rf ~/.local/state/nvim/lazy

echo "Reinstalling plugins..."
nvim --headless "+Lazy! sync" +qa

echo "Done! Run 'nvim' to verify."
