---
description: 'Dotfiles management and macOS configuration for developers'
applyTo: '**/.zshrc, **/.bashrc, **/.*rc, **/*.sh, **/bootstrap-*.sh, **/config/**, **/.dotfiles/**'
---

# Dotfiles and macOS Configuration Instructions

## Project Context
- Target OS: macOS (Intel and Apple Silicon)
- Shell: zsh with Powerlevel10k theme
- Development environment setup and configuration management
- Automated bootstrap system for developer tools

## Project Structure

### Core Components
- `.dotfiles/`: Zsh configuration (aliases, functions, environment)
- `bootstrap-*.sh`: Modular installation scripts
- `git/`: Git configuration and global gitignore
- `homebrew/`: Package management setup
- Editor configs: `vim/`, `neovim/`, `vscode/`
- System configs: `macos/`, `iterm/`, `finder/`

## Standards

### Bootstrap Scripts
- Must be idempotent (safe to run multiple times)
- Use `set -e` for error handling
- Prefix with `bootstrap-<component>.sh`
- Include clear status messages
- Backup existing configs before overwriting
- Call from main `bootstrap.sh` orchestrator

### Shell Configuration
- Use `.zsh` extension for zsh-specific files
- Group configurations by purpose (aliases, functions, env)
- Source modular files from main `.zshrc`
- Document each configuration section
- Keep sensitive data in separate, gitignored files

### File Organization
- Dotfiles: Hidden files in `.dotfiles/` directory
- Scripts: Executable `.sh` files in root or component directories
- Configs: Tool-specific subdirectories
- Use symlinks to home directory, don't copy

### Performance Optimization
- Lazy-load heavy tools and plugins
- Minimize startup time overhead
- Use shell built-ins when possible
- Profile `.zshrc` execution time

### Compatibility
- Test on both Intel and Apple Silicon Macs
- Handle Rosetta 2 requirements explicitly
- Check for macOS version-specific features
- Provide fallbacks for missing dependencies

### Code Quality
- POSIX-compliant when possible
- Functions over aliases for complex logic
- Clear comments for non-obvious operations
- Consistent indentation (2 spaces)
- Validate all inputs and paths

### Error Handling
- Exit on critical errors
- Provide clear, actionable error messages
- Confirm before destructive operations
- Log failures for debugging

## Development Workflow

### Adding New Features
1. Create component-specific bootstrap script
2. Test in clean environment first
3. Update main `bootstrap.sh` to include new script
4. Document in README and comments
5. Verify cross-architecture compatibility

### Modifying Configurations
- Shell aliases → `.dotfiles/.alias.zsh`
- Functions → `.dotfiles/.functions.zsh`
- Environment → `.dotfiles/.env.zsh`
- Git settings → `git/.gitconfig`

### Testing
- Run in macOS VM or separate machine
- Verify idempotency
- Check error handling
- Test rollback scenarios
- Validate symlinks are created correctly