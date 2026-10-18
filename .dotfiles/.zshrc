# ========================================
# Zsh Configuration File
# ========================================

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
# This snippet checks if a cached instant prompt script exists, and if so, it sources (loads) that script.
# The instant prompt is a feature of Powerlevel10k that helps reduce the time it takes to display the Zsh prompt when opening a new terminal.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# I set the IS_WSL variable to distinguish between the operating systems.
# The q flag is for quiet (we don't want the grep output to print every time a shell starts), and i makes the check case-insensitive, so it does not depend on how Microsoft is capitalized.
# On macOS, /proc/version doesn't exist, but the error is redirected to /dev/null, so the condition simply fails.
if grep -qi microsoft /proc/version 2>/dev/null; then
    IS_WSL=1
fi

# Initialize Homebrew and its environment variables and paths.
if [[ -f "/opt/homebrew/bin/brew" ]]; then
  # If you're using macOS, you'll want this enabled
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Initialize NVM (Node Version Manager) and set up Node.js and npm commands to use the correct version of Node.js based on the .nvmrc file in the current directory.
# The following code sets the NVM_DIR environment variable to the location where NVM is installed, and defines a function for nvm that ensures the correct version of Node.js is used when running node, npm, or npx commands.
export NVM_DIR="$HOME/.nvm"

# Prepend the NVM default node bin so it is available before lazy-loading kicks in.
# This is necessary for Husky Git hooks and other child processes, which can't see shell functions and rely on the inherited PATH.
# The following code checks if the default Node.js version is set in NVM, resolves any aliases, and prepends the corresponding bin directory to the PATH environment variable.
if [[ -s "$NVM_DIR/alias/default" ]]; then
  _nvm_default="$(cat "$NVM_DIR/alias/default")"
  # Resolve the full alias chain (e.g. default -> lts/* -> lts/krypton -> v24.18.0).
  for _i in 1 2 3 4 5; do
    [[ -s "$NVM_DIR/alias/$_nvm_default" ]] || break
    _nvm_default="$(cat "$NVM_DIR/alias/$_nvm_default")"
  done
  # The "node"/"stable" aliases mean the latest installed version: match any version dir.
  [[ "$_nvm_default" == node || "$_nvm_default" == stable ]] && _nvm_default=""
  # NVM version dirs are always v-prefixed; alias files may omit the v.
  # The trailing glob lets partial versions (e.g. "24") resolve to the latest installed match.
  _nvm_node_bin="$(echo "$NVM_DIR/versions/node/v${_nvm_default#v}"*/bin(NOn[1]))"
  [[ -d "$_nvm_node_bin" ]] && export PATH="$_nvm_node_bin:$PATH"
  unset _nvm_default _nvm_node_bin _i
fi

# Lazy-load nvm when node, npm, or npx is called.
# Calling nvm use 18 directly still works (forwards args).
# npm, node, npx calling bare nvm just lazy-loads it without dumping help text.
nvm() {
  unset -f nvm node npm npx
  if [ -s "$NVM_DIR/nvm.sh" ]; then
    . "$NVM_DIR/nvm.sh"
  elif command -v brew >/dev/null 2>&1 && [ -s "$(brew --prefix nvm 2>/dev/null)/nvm.sh" ]; then
    . "$(brew --prefix nvm 2>/dev/null)/nvm.sh"
  fi
  
  # Makes sure a default Node.js version exists, installing the latest LTS the first time if none does.
  if [[ "$(nvm version default 2>/dev/null)" == "N/A" ]]; then
    nvm install --lts >/dev/null 2>&1
    nvm alias default 'lts/*' >/dev/null 2>&1
  fi

  [[ $# -gt 0 ]] && nvm "$@"
}
node() { nvm; command node "$@"; }
npm() { nvm; command npm "$@"; }
npx() { nvm; command npx "$@"; }

# Set the directory we want to store zinit and plugins.
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet.
if [ ! -d "$ZINIT_HOME" ]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit.
source "${ZINIT_HOME}/zinit.zsh"

# Add in Powerlevel10k.
zinit depth=1 light-mode for romkatv/powerlevel10k

# Add in zsh plugins (turbo/async mode — loads after prompt appears, faster startup).
# OMZL stands for Oh My Zsh Leftovers, which is a collection of Zsh configurations and snippets that don't necessarily rely on Oh My Zsh itself.
# OMZL:: prefix is auto-detected as a snippet by zinit's for-syntax.
zinit wait lucid light-mode for \
  zsh-users/zsh-syntax-highlighting \
  zsh-users/zsh-completions \
  zsh-users/zsh-autosuggestions \
  zsh-users/zsh-history-substring-search \
  Aloxaf/fzf-tab

# Load completions.
# This is necessary to ensure that the completions provided by the plugins are available in the current shell session.
# -C skips the security check and reuses the cache. Rebuilds only if the dump is older than 24h.
autoload -Uz compinit
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# This ensures all plugins and snippets are reloaded without needing to manually re-run the commands in your .zshrc.
zinit cdreplay -q

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Keybindings.
# Explicitly set Emacs keybindings.
# For example:
# Ctrl-A: Move the cursor to the beginning of the line.
# Ctrl-E: Move the cursor to the end of the line.
# Ctrl-K: Delete everything from the cursor to the end of the line.
# Ctrl-Y: Paste (yank) the last cut or copied text.
bindkey -e
# Ctrl-P: Searches backward through your command history for commands that match the current input on the command line.
bindkey '^p' history-search-backward
# Ctrl-N: Searches forward through your command history for commands that match the current input on the command line.
bindkey '^n' history-search-forward

# History.
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling.
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'

# Aliases.
[[ ! -f ~/.alias.zsh ]] || source ~/.alias.zsh
# Functions.
[[ ! -f ~/.functions.zsh ]] || source ~/.functions.zsh


# Shell integrations.
# Set up fzf key bindings and fuzzy completion.
eval "$(fzf --zsh)"

# Initialize zoxide with 'cd' as the command (replaces cd with smart cd)
eval "$(zoxide init zsh --cmd cd)"
# This gives you 'cd' and 'cdi' commands.

# Set fzf default options with a color scheme that matches the terminal theme.
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
    --color=fg:#e5e9f0,bg:#3b4252,hl:#81a1c1
    --color=fg+:#e5e9f0,bg+:#3b4252,hl+:#81a1c1
    --color=info:#eacb8a,prompt:#bf6069,pointer:#b48dac
    --color=marker:#a3be8b,spinner:#b48dac,header:#a3be8b'

# Set BAT (a cat clone with syntax highlighting) theme to Nord.
export BAT_THEME="Nord"

# Add colors to Terminal.
# Source the .env.zsh file.
[[ ! -f ~/.env.zsh ]] || source ~/.env.zsh

# Add in jenv (Java version manager) to manage multiple Java versions.
# jEnv allows you to switch between different Java versions on the fly.
export PATH="$HOME/.jenv/bin:$HOME/.jenv/shims:$PATH"
if command -v jenv >/dev/null 2>&1; then
  jenv() {
    unset -f jenv
    eval "$(command jenv init - zsh)"
    jenv "$@"
  }
fi

# Latex support (MiKTeX).
# First run /Applications/MiKTeX Console.app.
export PATH="$HOME/bin:$PATH"

# Expands history expressions like !! or !$ when you press space
bindkey ' ' magic-space

# Load the Node.js version specified in the .nvmrc file when changing directories.
load_nvmrc() {
  if [[ -f .nvmrc ]]; then
    nvm use --silent >/dev/null 2>&1
  fi
}
autoload -U add-zsh-hook
add-zsh-hook chpwd load_nvmrc

# Set language, on applications, to English UTF-8
export LANG=en_US.UTF-8

# Pyenv initialization (previously installed via Homebrew)
# Pyenv is a Python version manager that allows you to easily switch between multiple versions of Python on your system. It works on both macOS and Linux.
# Lazy-load pyenv to improve shell startup time.
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv &>/dev/null; then
  pyenv() {
    unset -f pyenv
    eval "$(command pyenv init -)"
    pyenv "$@"
  }
fi
