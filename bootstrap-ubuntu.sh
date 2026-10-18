#!/bin/bash
# ========================================
# Main Bootstrap Script for Ubuntu
# This script orchestrates the setup of the Ubuntu environment by calling various other scripts to install applications, set up dotfiles, and configure Vim and Neovim.
# ========================================

source "$(dirname "$0")/utils.sh"
cd "$(dirname "$0")"
print_step "Starting bootstrap process for Ubuntu..."

cd apt
bash apt-install-applications.sh

# Change default shell to zsh (zsh was installed in the previous step)
if command -v zsh &>/dev/null && [ "$SHELL" != "$(which zsh)" ]; then
  print_step "Changing default shell to zsh..."
  chsh -s "$(which zsh)"
  print_ok "Default shell changed to zsh. Please re-login and re-run this script to continue setup."
  exit 0
elif ! command -v zsh &>/dev/null; then
  print_error "zsh not found, skipping shell change."
fi

cd ..
bash bootstrap-dotfiles.sh
bash bootstrap-vim.sh
bash bootstrap-neovim.sh

print_ok "Bootstrap process completed! Please restart your terminal and log out/in to apply all changes."

