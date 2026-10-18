#!/bin/bash
# ========================================
# Script to Install Applications on Linux (Debian/Ubuntu)
# ========================================

source "$(dirname "$0")/../utils.sh"

# System update 
print_step "Updating apt..."
sudo apt update -y && sudo apt upgrade -y

# Locale
print_step "Configuring locale (en_US.UTF-8) to avoid potential issues with non-ASCII characters..."
sudo apt install -y locales
sudo locale-gen en_US.UTF-8
sudo update-locale LANG=en_US.UTF-8
print_ok "Locale configured."

# Shell tools 
print_step "Installing shell tools..."
sudo apt install -y \
  bat \
  eza \
  fastfetch \
  fzf \
  git \
  htop \
  lsof \
  net-tools \
  neovim \
  openjdk-21-jdk \
  python3 \
  python3-pip \
  ripgrep \
  shellcheck \
  stow \
  tealdeer \
  tree \
  zoxide \
  zsh

# Opencode CLI
print_step "Installing Opencode CLI..."
if ! command -v opencode &>/dev/null; then
  curl -fsSL https://opencode.ai/install | bash
  print_ok "Opencode CLI installed."
else
  print_ok "Opencode CLI already installed, skipping."
fi

# Docker
# For now I'm skipping Docker because I'm using through Windows WSL, and Rancher Desktop handles the installation and updates for me. If I were to install Docker directly on Linux, I'd want to make sure to set it up with the appropriate user permissions so I can run it without sudo, and also ensure it's configured to start on boot.
# if ! command -v docker &>/dev/null; then
#   print_step "Installing Docker..."
#   curl -fsSL https://get.docker.com | sh
#   sudo usermod -aG docker "$USER"
#   print_ok "Docker installed. Re-login required to use without sudo."
# else
#   print_ok "Docker already installed, skipping."
# fi

# kubectl
# I'm skipping kubectl for now since I primarily use it through WSL and Rancher Desktop, which provides its own kubectl. If I were to install it directly on Linux, I'd want to ensure it's the latest version and properly configured with my kubeconfig file.
# if ! command -v kubectl &>/dev/null; then
#   print_step "Installing kubectl..."
#   KUBECTL_VERSION=$(curl -sL https://dl.k8s.io/release/stable.txt)
#   curl -sLo /tmp/kubectl "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
#   sudo install -o root -g root -m 0755 /tmp/kubectl /usr/local/bin/kubectl
#   rm /tmp/kubectl
#   print_ok "kubectl installed: $(kubectl version --client --short 2>/dev/null)"
# else
#   print_ok "kubectl already installed, skipping."
# fi

# pnpm
if ! command -v pnpm &>/dev/null; then
  print_step "Installing pnpm..."
  curl -fsSL https://get.pnpm.io/install.sh | sh -
  pnpm setup
  print_ok "pnpm installed. Restart shell or source your profile to use it."
else
  print_ok "pnpm already installed, skipping."
fi

# Ensure pnpm and its global bin dir are in PATH for this session.
export PNPM_HOME="${PNPM_HOME:-$HOME/.local/share/pnpm}"
export PATH="$PNPM_HOME:$PNPM_HOME/bin:$PATH"

# commitizen
if command -v pnpm &>/dev/null && ! command -v cz &>/dev/null; then
  print_step "Installing commitizen..."
  pnpm add -g commitizen cz-conventional-changelog
  print_ok "commitizen installed."
fi

# jenv (Java version manager)
if ! command -v jenv &>/dev/null; then
  print_step "Installing jenv..."
  git clone https://github.com/jenv/jenv.git "$HOME/.jenv"
  export PATH="$HOME/.jenv/bin:$PATH"
  print_ok "jenv installed."
else
  print_ok "jenv already installed, skipping."
fi

# nvm (Node version manager)
# The check uses $HOME/.nvm/nvm.sh rather than command -v nvm because nvm is a shell function loaded at runtime, not a binary in PATH. If nvm is installed but not yet loaded in the current shell session, command -v nvm would return nothing, which could lead to a false negative. By checking for the existence of the nvm.sh script, we can more reliably determine if nvm is installed, regardless of whether it's currently active in the shell.
if [ ! -s "$HOME/.nvm/nvm.sh" ]; then
  print_step "Installing nvm..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/HEAD/install.sh | bash
  print_ok "nvm installed."
else
  print_ok "nvm already installed, skipping."
fi

# Load nvm and install Node LTS
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
# nvm ls always lists lts/* aliases in output even when nothing is installed, so we check
# whether the alias resolves to a real version number (vX.Y.Z) rather than "N/A".
if command -v nvm &>/dev/null && ! nvm ls --no-colors lts/* 2>/dev/null | grep -qE "v[0-9]+\.[0-9]+\.[0-9]+"; then
  print_step "Installing Node LTS..."
  nvm install --lts
  nvm alias default lts/*
  print_ok "Node LTS installed: $(node -v)"
else
  print_ok "Node LTS already installed, skipping."
fi

# pyenv (Python version manager)
if ! command -v pyenv &>/dev/null; then
  print_step "Installing pyenv..."
  curl -fsSL https://pyenv.run | bash
  print_ok "pyenv installed."
else
  print_ok "pyenv already installed, skipping."
fi

# systemd-resolved (flushdns) 
# It's what powers the flushdns alias on Linux, so we want to make sure it's installed and active.
if ! systemctl is-active --quiet systemd-resolved; then
  print_step "Enabling systemd-resolved..."
  sudo systemctl enable --now systemd-resolved
  print_ok "systemd-resolved enabled."
else
  print_ok "systemd-resolved already active."
fi

echo ""
echo "Done installing applications. Some changes (Docker group, pnpm PATH) require a shell restart or re-login."
echo "Please restart your terminal or log out and back in to ensure all tools are available in your PATH."
