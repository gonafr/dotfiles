#!/bin/bash
# ========================================
# Script to Install Applications on Linux (Debian/Ubuntu) that are not available in the default apt repositories
# ========================================

# Oxker CLI
mkdir -p /tmp/oxker-install && cd /tmp/oxker-install
curl https://raw.githubusercontent.com/mrjackwills/oxker/main/install.sh | bash

# Oxker CLI uninstall (for future reference)
# rm ~/.local/bin/oxker

# tree-sitter
curl -L https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-linux-x64.gz | gunzip > tree-sitter
chmod +x tree-sitter
sudo mv tree-sitter /usr/local/bin/
hash -r

# tree-sitter uninstall (for future reference)
# sudo rm /usr/local/bin/tree-sitter
# hash -r