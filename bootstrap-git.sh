#!/bin/bash
# ========================================
# Script to Bootstrap Git Configuration with GNU Stow
# This script copies the git folder to the home directory and uses GNU Stow to create symlinks for the Git configuration files.
# It also creates separate gitconfig files for personal and work use, allowing you to switch between them easily.
# ========================================

source "$(dirname "$0")/utils.sh"
cd "$(dirname "$0")"
print_step "Bootstrapping Git configuration with GNU Stow..."

# Copy git folder to home folder
cp -R git $HOME

# Create two separate git config files for personal and work use
# This allows you to have different configurations for each context
cp $HOME/git/.gitconfig $HOME/git/.gitconfig-personal
cp $HOME/git/.gitconfig $HOME/git/.gitconfig-work

# Make the corresponding symlinks, in your home folder, with Gnu Stow.
cd $HOME/git
stow .

echo "Don't forget to edit the following configuration files as you wish:"
echo "- $HOME/.gitconfig-personal"
echo "- $HOME/.gitconfig-work"
echo "You can switch between them by using the commands:"
echo "- git use-personal"
echo "- git use-work"

print_ok "Git configuration bootstrapped successfully! Please restart your terminal and log out/in to apply all changes."