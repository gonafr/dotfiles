#!/bin/bash
# ========================================
# Script to Bootstrap iTerm2 Configuration on macOS
# This script copies the iterm folder to the home directory, which contains the iTerm2 color scheme and font configuration.
# It also provides instructions for setting up the iTerm2 theme and font manually, as these settings cannot be applied via command line.
# ========================================

source "$(dirname "$0")/utils.sh"
cd "$(dirname "$0")"
print_step "Bootstrapping iTerm2 configuration..."

# Copy iterm theme to home folder
cp -R iterm $HOME

# Set the font.
# Click on the Text tab under the selected profile.
# In the Font section, click on the font name or "Change Font" button.
# In the font picker dialog, search for Hack Nerd Font and select the desired variant (e.g., Regular, Bold, Italic).
# Set font size to 14.
# Enable Nerd Font Glyphs (Optional):
# - Ensure that Use built-in Powerline glyphs is unchecked, as Nerd Fonts include their own glyphs.

print_step "Manual step — Set the font:"
echo "  1. Click on the Text tab under the selected profile."
echo "  2. In the Font section, click on the font name or 'Change Font' button."
echo "  3. Search for 'Hack Nerd Font' and select the desired variant (e.g., Regular, Bold, Italic)."
echo "  4. Set font size to 14."
echo "  5. Ensure 'Use built-in Powerline glyphs' is unchecked (Nerd Fonts include their own glyphs)."

# Set the theme.
# Import the Theme:
# Go to the Colors tab in the profile settings.
# Open the Color Presets... dropdown and select Import....
# Navigate to and select the .itermcolors file you downloaded.
# Apply the Theme:
# - After importing, the theme will appear in the Color Presets... dropdown.
# - Select the imported theme to apply it.

print_step "Manual step — Set the theme:"
echo "  1. Go to the Colors tab in the profile settings."
echo "  2. Open the 'Color Presets...' dropdown and select 'Import...'."
echo "  3. Navigate to and select the .itermcolors file copied to your home folder."
echo "  4. After importing, select the imported theme from the 'Color Presets...' dropdown to apply it."

print_ok "iTerm2 configuration bootstrapped successfully! Please follow the instructions above to complete the setup. Restart iTerm2 to apply all changes."
