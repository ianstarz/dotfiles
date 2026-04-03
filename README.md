# dotfiles

My macOS development environment, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Fresh Mac Setup

One command to go from a fresh macOS install to a fully configured dev machine:

```bash
curl -fsSL https://raw.githubusercontent.com/ianstarz/dotfiles/main/init/.local/bin/setup-mac | bash
```

This installs everything: Xcode CLI tools, Homebrew, languages (Node, Python, Go, Rust), tools (tmux, fzf, gh), apps (VS Code, Docker, Warp), clones this repo, stows all packages, and sets up Oh My Zsh.

The script is idempotent — safe to run again anytime.

## Already Set Up?

If you've already run the setup and just need to re-stow after pulling changes:

```bash
cd ~/Projects/dotfiles && ./install.sh
```

## Packages

| Package | Files | Purpose |
|---------|-------|---------|
| `zsh` | `.zshrc`, `.zprofile` | Oh My Zsh, aliases, fzf, auto-attach tmux |
| `git` | `.gitconfig`, `.gitignore_global` | Git identity, aliases, global ignores |
| `tmux` | `.tmux.conf` | Powerline status bar, vim-style panes, Ctrl+a prefix |
| `claude` | `.claude/settings.json` | Claude Code model, permissions, hooks |
| `gh` | `.config/gh/config.yml` | GitHub CLI preferences |
| `bin` | `.local/bin/dev-session` | Dev session launcher (tmux layout with claude + git watches) |
| `init` | `.local/bin/setup-mac` | Full Mac bootstrap script |
| `ssh` | `.ssh/config` | SSH host configs (keys NOT tracked) |
| `stow` | `.stow-global-ignore` | Tells stow which files to skip |

## Dev Session

Opening a new terminal automatically attaches to a tmux `main` session with:

- Left pane: `claude`
- Top-right pane: `watch git log`
- Bottom-right pane: `watch git status`

You can also launch it manually with `tm` or `dev-session`.

## How It Works

Each top-level directory is a stow "package." Running `stow zsh` from `~/Projects/dotfiles` creates symlinks in `~` that mirror the package's directory structure:

```
~/Projects/dotfiles/zsh/.zshrc  ->  ~/.zshrc (symlink)
```

## Managing Dotfiles

**Add a new file:**
```bash
mkdir -p ~/Projects/dotfiles/newpkg/.config/tool
mv ~/.config/tool/config.toml ~/Projects/dotfiles/newpkg/.config/tool/config.toml
cd ~/Projects/dotfiles && stow newpkg
git add -A && git commit -m "Add newpkg config"
```

**Stow a single package:**
```bash
cd ~/Projects/dotfiles && stow --restow zsh
```

**Remove symlinks for a package:**
```bash
cd ~/Projects/dotfiles && stow --delete zsh
```

**See what stow would do (dry run):**
```bash
cd ~/Projects/dotfiles && stow --simulate --verbose zsh
```
