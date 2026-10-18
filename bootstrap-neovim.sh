#!/bin/bash
# ========================================
# Script to Bootstrap Neovim Configuration with LazyVim
# This script checks if Neovim is already set up in the home directory. If not, it clones the LazyVim starter configuration and copies the custom Neovim configuration files from the neovim folder to the appropriate locations in the LazyVim setup.
# If Neovim is already set up, it provides instructions for updating the configuration manually.
# ========================================

source "$(dirname "$0")/utils.sh"
cd "$(dirname "$0")"
print_step "Bootstrapping Neovim configuration with LazyVim..."

# Neovim setup with LazyVim
if [[ ! -d "$HOME/.config/nvim" ]]; then
  git clone https://github.com/LazyVim/starter ~/.config/nvim
  rm -rf ~/.config/nvim/.git
  print_ok "LazyVim installed! Start Neovim with 'nvim' and refer to the comments in the files to customize."

  # Copy neovim config to ~/.config/nvim folder
  cp -R neovim/config/* $HOME/.config/nvim/lua/config
  cp -R neovim/plugins/* $HOME/.config/nvim/lua/plugins
else
  print_warning "Neovim is already set up. If you want to update the configuration, please check the files in the neovim folder and copy them to ~/.config/nvim/lua/config and ~/.config/nvim/lua/plugins."
fi