#!/bin/bash
# ========================================
# Script to Install Rosetta on macOS
# Rosetta allows Intel macOS applications to run on Apple Silicon macOS.
# Note that it is very difficult to remove Rosetta 2 once it is installed.
# ========================================

source "$(dirname "$0")/../utils.sh"
print_step "Installing Rosetta 2 for Apple Silicon compatibility..."

softwareupdate --install-rosetta --agree-to-license

print_ok "Rosetta 2 installed successfully! This will allow you to run Intel-based applications on your Apple Silicon Mac. Please restart your terminal to apply the changes."