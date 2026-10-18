#!/bin/bash
# ========================================
# Script to Bootstrap Vim Configuration
# This script copies the Vim configuration files from the vim folder to the appropriate locations in the home directory. It sets up the .vimrc file and the colorscheme for Vim.
# ========================================

source "$(dirname "$0")/utils.sh"
cd "$(dirname "$0")"
print_step "Bootstrapping Vim configuration..."

# Copy vim themes to ~/.vim/colors/ folder
cp -R vim/.vim $HOME
# Copy .vimrc to home folder
cp vim/.vimrc $HOME

print_ok "Vim configuration bootstrapped successfully! Please restart your terminal and log out/in to apply all changes."