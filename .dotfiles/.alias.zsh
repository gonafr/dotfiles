# ========================================
# Zsh Script for Aliases
# ========================================

# Global alias, use anywhere in the command line
if [ "$(uname)" = "Darwin" ]; then # macOS specific alias
  alias -g ICLOUD="~/Library/Mobile\ Documents/com~apple~CloudDocs/"
fi
# Redirect stderr to /dev/null
alias -g NE='2>/dev/null'
# Redirect stdout to /dev/null
alias -g NO='>/dev/null'
# Redirect both stdout and stderr to /dev/null (>/dev/null 2>&1 can be replaced for &> /dev/null)
# Redirects stdout to null, then redirects stderr (2) to wherever stdout (1) is going
alias -g NUL='>/dev/null 2>&1'

# Regular aliases
# Navigation & Directory Operations
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
alias -- -='cd -'  # Go back to previous directory
alias tree='tree -C'
# alias l='ls -lah'
# alias ls='ls --color=auto'  # or 'ls -G' on macOS
# alias ll='ls -l'
# alias la='ls -la'
# Using eza for enhanced ls functionality
command -v eza NUL && alias l='eza -lah --color=always --group-directories-first --icons=auto'
command -v eza NUL && alias ls='eza --color=always --group-directories-first'
command -v eza NUL && alias ll='eza -l --color=always --group-directories-first --icons=auto'
command -v eza NUL && alias la='eza -la --color=always --group-directories-first --icons=auto'
command -v eza NUL && alias lat='eza -la --color=always --group-directories-first --icons=auto --sort newest --reverse'

# File Operations
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -iv'
alias mkdir='mkdir -pv'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias h='history'
alias j='jobs -l'
alias path='echo -e ${PATH//:/\\n}'

# System & Process Management
alias df='df -h'
alias du='du -h'
alias ps='ps aux'
alias psu='ps aux --sort=-%mem | head -n 15'
alias pscpu='ps aux --sort=-%cpu | head -n 15'
command -v htop NUL && alias top='htop'

# Git Shortcuts
alias g='git' # Git command shortcut
alias gs='git status' # Show working tree status
alias ga='git add' # Add specific files to staging
alias gaa='git add .' # Add all changes in current directory (recursive) to staging
alias gc='git commit' # Commit (opens editor)
alias gcm='git commit -m' # Commit with message
#Commit with commitizen prefer global `cz`, otherwise fall back to `pnpm exec cz`
if command -v cz NUL; then
    alias gcz='cz'
elif command -v pnpm NUL; then
    alias gcz='pnpm exec cz'
fi
alias gca='git commit --amend' # Amend last commit
alias gp='git push' # Push to default remote and branch
alias gpl='git pull' # Pull from default remote and branch (merges changes)
alias gf='git fetch' # Fetch from default remote
alias gfa='git fetch --all' # Fetch all remotes (download objects and refs from all remotes, does not merge anything into local branches, safe to use)
alias gd='git diff' # Show changes between working directory and index
alias gds='git diff --staged' # Show changes between index and last commit
alias gl='git log --oneline' # Simple one-line log
alias gld='git log --oneline --date=short --format="%C(auto)%h %ad %s"' # Log with date
alias gla='git log --oneline --date=short --format="%C(auto)%h %ad %C(green)%an%Creset %s"' # Log with author name
alias gb='git branch' # List branches (it can also create branches with 'git branch branch-name')
alias gco='git checkout' # Checkout branch or commit
alias gcb='git checkout -b' # Create and checkout a new branch (old way)
alias gsw='git switch' # Switch branches (new way)
alias gswc='git switch -c' # Create and switch to a new branch (new way)
alias gm='git merge' # Merge branches
alias gms='git merge --squash' # Merge with squash (collapses all the branch's commits into a single new one)
alias gst='git stash' # Stash changes
alias gsta='git stash apply' # Apply stashed changes
alias gstl='git stash list' # List stashes
alias gstp='git stash pop' # Apply stashed changes and remove from stash list
alias gstd='git stash drop' # Remove a stash from the list
alias gsts='git stash show -p' # Show changes in the most recent stash

# Git configurations (depends on previous setting git aliases)
alias guw="git use-work"
alias gup="git use-personal"

# Allow sudo to expand other aliases
alias sudo='sudo '

# fzf to search for folders
command -v fzf NUL && alias fzfd='cd "$(find . -type d | fzf)"'

# IP addresses
if [ "$(uname)" = "Darwin" ]; then # macOS specific alias
  alias localip='ipconfig getifaddr "$(route -n get default 2>/dev/null | awk '\''/interface:/{print $2}'\'')"'
  alias flushdns='sudo dscacheutil -flushcache'
else
  alias localip='hostname -I | cut -d" " -f1'
  alias flushdns='sudo resolvectl flush-caches'
fi
command -v ifconfig NUL && alias ips="ifconfig -a | grep -o 'inet6\? \(addr:\)\?\s\?\(\(\([0-9]\+\.\)\{3\}[0-9]\+\)\|[a-fA-F0-9:]\+\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"
command -v lsof NUL && alias ports='lsof -iTCP -sTCP:LISTEN -n -P'  # Show listening TCP ports with process info
command -v lsof NUL && alias portsall='lsof -nP -iTCP -sTCP:LISTEN,ESTABLISHED'  # Show all TCP connections


# macOS Specific Aliases - Brew
if [ "$(uname)" = "Darwin" ]; then
  command -v brew NUL && alias brewup='brew update && brew upgrade && brew upgrade --cask --greedy && brew cleanup'
fi

# Show/hide hidden files in Finder
if [ "$(uname)" = "Darwin" ]; then
  # Recursively delete .DS_Store and files created when mounting volumes 
  alias sweep="find . -name .DS_Store -type f -delete ; find . -type d | xargs dot_clean -m"
  # Show/hide hidden files in Finder
  alias show="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
  alias hide="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"
  # Hide/show all desktop icons (useful when presenting)
  alias hidedesktop="defaults write com.apple.finder CreateDesktop -bool false && killall Finder"
  alias showdesktop="defaults write com.apple.finder CreateDesktop -bool true && killall Finder"
  # Switch between Apple Silicon (ARM64) and AMD64 architectures
  # Run 'uname -m' to check if the hardware is arm64 or x86_64
  alias x86="env /usr/bin/arch -x86_64 /bin/zsh --login"
  alias arm="env /usr/bin/arch -arm64 /bin/zsh --login"
  # Sleep the computer immediately (macOS)
  alias sleep="pmset sleepnow"
fi

# Reload Zsh configuration
alias zrc="source ~/.zshrc"

# Replace vim with nvim (only if nvim is installed)
command -v nvim NUL && alias vim='nvim'

# Replace python with python3 and pip with pip3 (only if python3 is installed)
command -v python3 NUL && alias python='python3'
command -v pip3 NUL && alias pip='pip3'

# Docker (only if present)
if command -v docker NUL; then
  alias dps='docker ps'
  alias dpa='docker ps -a'
  alias di='docker images'
  alias dlogs='docker logs -f'
  alias drm='docker rm'
  alias drmi='docker rmi'
fi

# Kubernetes (only if present)
if command -v kubectl NUL; then
  alias k='kubectl'
  alias kgp='kubectl get pods'
  alias kgs='kubectl get svc'
  alias kgn='kubectl get nodes'
  alias kctx='kubectl config current-context'
fi