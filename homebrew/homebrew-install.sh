#!/bin/bash
# ========================================
# Script to Install Homebrew on macOS
# ========================================

source "$(dirname "$0")/../utils.sh"

print_step "Installing Homebrew..."
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Check if Homebrew is installed
if [[ -f "/opt/homebrew/bin/brew" ]]; then
  # Initialize Homebrew's environment variables
  eval "$(/opt/homebrew/bin/brew shellenv)"
  print_ok "Homebrew environment initialized."
else
  print_error "Homebrew is not installed or not found at /opt/homebrew/bin/brew."
fi

# Think of it like refreshing a catalog - it doesn't actually upgrade any of your installed packages.
# It just makes sure Homebrew knows about all the latest available versions.
if command -v brew &>/dev/null; then
  print_step "Updating Homebrew catalog..."
  brew update
else
  print_error "Homebrew is not installed or not found in PATH."
fi