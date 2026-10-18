#!/bin/bash
# ========================================
# Script to Bootstrap Dotfiles with GNU Stow
# This script copies the .dotfiles folder to the home directory and uses GNU Stow to create symlinks for the configuration files.
# It also ensures that the correct PATH is set for Homebrew on macOS.
# ========================================

source "$(dirname "$0")/utils.sh"
cd "$(dirname "$0")"
print_step "Bootstrapping dotfiles with GNU Stow..."

# Copy .dotfiles folder to home folder if it doesn't exist, but don't overwrite if it does (to preserve any local changes)
cp -Rn .dotfiles $HOME

if [ "$(uname)" = "Darwin" ]; then # macOS specific alias
  # Replace /opt/homebrew/bin with /usr/local/bin if you're on an Intel Mac
  export PATH="/opt/homebrew/bin:$PATH"
fi

# Run Gnu Stow so it creates (or refreshes) the symlinks pointing to the $HOME/.dotfiles files
cd $HOME/.dotfiles
stow --restow --adopt . || print_error "Stow encountered conflicts."

# Enable jenv plugins for managing Java environment and Maven integration.
jenv enable-plugin export
jenv enable-plugin maven

print_ok "Dotfiles bootstrapped successfully! Please restart your terminal and log out/in to apply all changes."