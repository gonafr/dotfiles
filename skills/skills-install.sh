#!/bin/bash
# ========================================
# Install AI agent skills globally for GitHub Copilot and Claude Code, using the skills CLI
# (https://github.com/vercel-labs/skills).
#
# The CLI keeps each skill in ~/.agents/skills/<name>, which Copilot reads directly,
# and symlinks ~/.claude/skills/<name> to it for Claude Code.
#
# Safe to run repeatedly: running it again reinstalls each skill at its latest upstream version.
# ========================================

source "$(dirname "$0")/../utils.sh"

# Skills to install, one per line: "<owner/repo>|<skill name>"
SKILLS=(
  "blader/humanizer|humanizer"
  "JuliusBrussee/caveman|caveman"
  "vercel-labs/skills|find-skills"
  "vercel-labs/agent-skills|vercel-react-best-practices"
)

AGENTS=(claude-code github-copilot)
BACKUP_DIR="$HOME/.agents/skills-backup"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"

# nvm is a shell function, so scripts started outside an interactive shell may not have node on the PATH.
if ! command -v npx &>/dev/null && [ -s "$HOME/.nvm/nvm.sh" ]; then
  export NVM_DIR="$HOME/.nvm"
  set +e
  source "$NVM_DIR/nvm.sh"
  set -e
fi

if ! command -v npx &>/dev/null; then
  print_error "npx is required to install skills. Install Node.js 22.20 or later."
  exit 1
fi

# The skills CLI requires Node.js 22.20 or later.
if ! node -e 'const [major, minor] = process.versions.node.split(".").map(Number); process.exit(major > 22 || (major === 22 && minor >= 20) ? 0 : 1)'; then
  print_error "The skills CLI requires Node.js 22.20 or later, but found $(node --version)."
  exit 1
fi

for skill in "${SKILLS[@]}"; do
  IFS='|' read -r repo name <<< "$skill"
  claude_copy="$HOME/.claude/skills/$name"

  # The CLI replaces a real folder here with its symlink without keeping a copy.
  if [ -d "$claude_copy" ] && [ ! -L "$claude_copy" ]; then
    mkdir -p "$BACKUP_DIR"
    cp -R "$claude_copy" "$BACKUP_DIR/$name-claude-$TIMESTAMP"
    print_info "Backed up $claude_copy to $BACKUP_DIR/$name-claude-$TIMESTAMP"
  fi

  print_step "Installing skill $name from $repo..."
  npx -y skills@latest add "$repo" --skill "$name" --global --agent "${AGENTS[@]}" --yes
  print_ok "$name installed."
done

print_ok "Skills installed for GitHub Copilot and Claude Code. Restart any open sessions to load changes."
