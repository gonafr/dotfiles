#!/bin/bash
# ========================================
# Script to Set macOS Defaults
# Inspired by: 
# - https://github.com/nikitavoloboev/config
# - https://github.com/mathiasbynens/dotfiles
# - https://gist.github.com/brandonb927/3195465
# - https://gist.github.com/DAddYE/2108403
# ========================================

# If not ran on macOS, exit
if [ "$(uname -s)" != "Darwin" ]; then
	exit 0
fi

# This disables the "exit on error" mode.
# With set +e, the shell continues running subsequent commands even if one of them fails.
# set +e

# ========================================
# General defaults
# ========================================
# Some general defaults regarding Security, UI, Finder, Trackpad, Dock, etc...

# Enabling full keyboard access for all controls (enable Tab in modal dialogs, menu windows, etc.)
defaults write -g AppleKeyboardUIMode -int 3
echo 'Enabling full keyboard access for all controls (enable Tab in modal dialogs, menu windows, etc.).'

# Mouse tracking speed
defaults write -g com.apple.mouse.scaling 1

# On Trackpad enable Tap to Click
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true

# Show all filename extensions in Finder
defaults write -g AppleShowAllExtensions -bool true
echo 'Show all filename extensions in Finder.'

# Show path bar in Finder
defaults write com.apple.finder ShowPathbar -bool true
echo 'Show path bar in Finder.'

# Show status bar
defaults write com.apple.finder ShowStatusBar -bool true
echo 'Show status bar.'

# Set Finder to Open Folders in Tabs
defaults write com.apple.finder FinderSpawnTab -bool true
echo 'Set Finder to Open Folders in Tabs.'

# Show Library folder
chflags nohidden ~/Library
echo 'Show Library folder.'

# Show hidden files
defaults write com.apple.finder AppleShowAllFiles YES
echo 'Show hidden files.'

# Avoid creating .DS_Store files on network volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
echo 'Avoid creating .DS_Store files on network volumes.'

# Disable Natural Scroll Direction
defaults write -g com.apple.swipescrolldirection -bool false
echo 'Disable Natural Scroll Direction.'

# Show indicator lights for open applications in the Dock
defaults write com.apple.dock show-process-indicators -bool true; killall Dock
echo 'Show indicator lights for open applications in the Dock.'

# Set the icon size of the Dock to 36 pixels
defaults write com.apple.dock tilesize -int 36
echo 'Set the icon size of the Dock to 36 pixels.'

defaults write ~/Library/Preferences/.GlobalPreferences CGDisableCursorLocationMagnification -bool YES
echo 'Disable shake mouse pointer to locate.'

# Set Liquid Glass to Tinted (more opaque) instead of Clear (requires logout)
defaults write -g NSGlassTintAmount -float 1
echo 'Set Liquid Glass to Tinted.'

# ========================================
# Keyboard defaults
# ========================================
# Adjusting the keyboard settings in macOS.

# Set Key Repeat to Fast
defaults write -g KeyRepeat -int 1
echo 'Set Key Repeat to Fast.'

# Set Delay Until Repeat to Short
defaults write -g InitialKeyRepeat -int 15
echo 'Set Delay Until Repeat to Short.'

# Disable "Correct spelling automatically"
defaults write -g NSAutomaticSpellingCorrection -bool false
echo 'Disable "Correct spelling automatically".'

# Disable "Capitalize words automatically"
defaults write -g NSAutomaticCapitalizationEnabled -bool false
echo 'Disable "Capitalize words automatically".'

# Disable "Add period with double-space"
defaults write -g NSAutomaticPeriodSubstitutionEnabled -bool false
echo 'Disable "Add period with double-space".'

# Disable Use smart quotes and dashes"
defaults write -g NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write -g NSAutomaticDashSubstitutionEnabled -bool false
echo 'Disable "Use smart quotes and dashes".'

# ========================================
# Energy saving settings
# ========================================

# Display sleep setting for AC power (15 minutes)
sudo pmset -b displaysleep 15

# Display sleep setting for AC power (3 hours)
sudo pmset -c displaysleep 180

# ========================================
# Applications defaults
# ========================================

# Make Chrome the default browser
open -a "Google Chrome" --args --make-default-browser
echo 'Make Chrome the default browser.'

# Prevent left and right swipe through history in Chrome
defaults write com.google.Chrome AppleEnableSwipeNavigateWithScrolls -bool false
echo 'Prevent left and right swipe through history in Chrome.'

# Disable "Displays have separate Spaces" (requires logout)
defaults write com.apple.spaces spans-displays -bool true

# Restart the user interface processes without needing to log out
killall -HUP SystemUIServer
echo 'Restart the user interface processes without needing to log out.'

echo '========================================'
echo 'Some commands require restart!'
echo 'Please do that for them to take effect.'
echo '========================================'