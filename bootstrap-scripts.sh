#!/bin/bash
# ========================================
# Create a ~/scripts directory, copy all scripts from the current directory to it, and add it to the PATH for easy access.
# ========================================

source "$(dirname "$0")/utils.sh"
cd "$(dirname "$0")"
print_step "Setting up scripts directory and adding to PATH..."

if [ ! -d "$HOME/scripts" ]; then
    mkdir -p "$HOME/scripts"
fi
cp ./scripts/*.sh ~/scripts
cp ./utils.sh ~/scripts
chmod +x ~/scripts/*.sh

# Add to PATH (append to ~/.zshrc or ~/.zprofile):
if ! grep -qxF 'export PATH="$HOME/scripts:$PATH"' ~/.zshrc; then
    echo 'export PATH="$HOME/scripts:$PATH"' >> ~/.zshrc
fi

print_ok "Scripts directory set up and added to PATH! You can now run the scripts from anywhere in the terminal using their names. Please restart your terminal and log out/in to apply all changes."