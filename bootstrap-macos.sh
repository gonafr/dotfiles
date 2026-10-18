#!/bin/bash
# ========================================
# Main Bootstrap Script for macOS
# This script orchestrates the setup of the macOS environment by calling various other scripts to install applications, set up dotfiles, and configure Vim, Neovim, and Finder.
# =================================

source "$(dirname "$0")/utils.sh"
cd "$(dirname "$0")"
print_step "Starting bootstrap process for macOS..."

cd rosetta
bash rosetta.sh
cd ..
cd homebrew
bash homebrew-install.sh
bash homebrew-install-applications.sh
cd ..
cd macos
bash set-defaults.sh
bash add-login-items.sh
cd ..
bash bootstrap-dotfiles.sh
bash bootstrap-iterm.sh
bash bootstrap-vim.sh
bash bootstrap-neovim.sh
bash bootstrap-finder.sh

print_ok "Bootstrap for macOS process completed! Please restart your terminal and log out/in to apply all changes."