#!/bin/bash
# ========================================
# Script to Install Applications on macOS using Homebrew
# ========================================
source "$(dirname "$0")/../utils.sh"

print_step "Updating Homebrew..."
# Think of it like refreshing a catalog - it doesn't actually upgrade any of your installed packages
# It just makes sure Homebrew knows about all the latest available versions
brew update

print_step "Installing Homebrew Shell applications..."
# Shell Programs
brew install \
  bat \
  commitizen \
  514-labs/tap/dnsglobe \
  eza \
  fastfetch \
  fd \
  fzf \
  gh \
  git \
  htop \
  imagemagick \
  jenv \
  kondo \
  latexindent \
  lazygit \
  markdownlint-cli2 \
  maven \
  neovim \
  nvm \
  opencode \
  oxker \
  pnpm \
  pyenv \
  ripgrep \
  shellcheck \
  stow \
  telnet \
  tldr \
  tree \
  zoxide

# Enable jenv plugins required for JAVA_HOME to update dynamically
mkdir -p ~/.jenv/plugins
JENV_PLUGINS="$(brew --prefix)/opt/jenv/available-plugins"
[[ -f ~/.jenv/plugins/export.bash ]] || ln -sf "$JENV_PLUGINS/export" ~/.jenv/plugins/export.bash
[[ -f ~/.jenv/plugins/maven.bash  ]] || ln -sf "$JENV_PLUGINS/maven" ~/.jenv/plugins/maven.bash

# Update tldr cache if tldr is installed
if command -v tldr &> /dev/null; then
    echo "Updating tldr cache..."
    # Clear old cache to avoid git branch issues (master -> main migration)
    rm -rf ~/.local/share/tldr
    tldr --update
fi

# GUI programs
print_step "Installing Homebrew GUI applications..."
brew install --cask \
  1password \
  appcleaner \
  balenaetcher \
  copilot-cli \
  crossover \
  cyberduck \
  darktable \
  discord \
  font-hack-nerd-font \
  gimp \
  imageoptim \
  inkscape \
  iterm2 \
  keka \
  keyclu \
  logi-options+ \
  mactex-no-gui \
  microsoft-edge \
  NotProtonNot/notproton/notproton \
  obs \
  openemu \
  orbstack \
  postman \
  crmne/tap/spotifast \
  temurin@21 \
  upscayl \
  visual-studio-code \
  vlc \
  vorssaint \
