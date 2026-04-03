# dotfiles

My macOS development environment, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Quick Start

```bash
git clone https://github.com/ianstarz/dotfiles ~/dotfiles
cd ~/dotfiles && ./install.sh
```

The install script will:
- Install Homebrew and GNU Stow if needed
- Back up any existing dotfiles to `~/.dotfiles_backup/`
- Symlink everything into place

## Packages

| Package | Files | Purpose |
|---------|-------|---------|
| `zsh` | `.zshrc`, `.zprofile` | Shell config, aliases, environment |
| `git` | `.gitconfig`, `.gitignore_global` | Git identity, aliases, global ignores |
| `claude` | `.claude/settings.json` | Claude Code model, permissions, hooks |
| `ssh` | `.ssh/config` | SSH host configs (keys NOT tracked) |
| `stow` | `.stow-global-ignore` | Tells stow which files to skip |

## How It Works

Each top-level directory is a stow "package." Running `stow zsh` from `~/dotfiles` creates symlinks in `~` that mirror the package's directory structure:

```
~/dotfiles/zsh/.zshrc  →  ~/.zshrc (symlink)
```

## Managing Dotfiles

**Add a new file:**
```bash
# Example: track a new config file
mkdir -p ~/dotfiles/newpkg/.config/tool
mv ~/.config/tool/config.toml ~/dotfiles/newpkg/.config/tool/config.toml
cd ~/dotfiles && stow newpkg
git add -A && git commit -m "Add newpkg config"
```

**Stow a single package:**
```bash
cd ~/dotfiles && stow --restow zsh
```

**Remove symlinks for a package:**
```bash
cd ~/dotfiles && stow --delete zsh
```

**See what stow would do (dry run):**
```bash
cd ~/dotfiles && stow --simulate --verbose zsh
```
