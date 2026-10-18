#!/bin/bash
# ========================================
# Script to Add "Open in VS Code" Finder Extension on macOS
# ========================================

source "$(dirname "$0")/utils.sh"
cd "$(dirname "$0")"
print_step "Adding 'Open in VS Code' Finder extension..."

if [[ -d "$HOME/Library/Services/Open in VS Code.workflow" ]]; then
  print_ok "'Open in VS Code' Finder extension is already installed. Skipping."
else
  open finder/Open\ in\ VS\ Code.workflow
  print_ok "'Open in VS Code' Finder extension added successfully! You can now right-click on folders in Finder and select 'Open in VS Code' to open them directly in Visual Studio Code."
fi


