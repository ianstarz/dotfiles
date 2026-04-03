# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

A macOS development environment managed with **GNU Stow**. Each top-level directory is a Stow "package" that mirrors the home directory structure — `stow <package>` creates symlinks from `~/<package-files>` to the corresponding files here.

```
~/Projects/dotfiles/zsh/.zshrc  ──[stow]──→  ~/.zshrc (symlink)
```

## Applying Dotfiles

```bash
# Full fresh-machine setup (Homebrew, languages, tools, dotfiles)
curl -fsSL <url>/setup-mac | bash

# Apply/re-apply dotfiles to current machine (backs up conflicts automatically)
cd ~/Projects/dotfiles && ./install.sh

# Stow a single package manually
stow -d ~/Projects/dotfiles -t ~ <package>
```

## Key Scripts

- **`init/.local/bin/setup-mac`** — Full system bootstrap: Xcode CLI, Homebrew packages/casks, Node (fnm), Python (uv), Claude CLI, SSH key, Oh My Zsh, VS Code extensions. Logs to `~/setup-mac.log`.
- **`bin/.local/bin/dev-session`** — Creates/attaches to a tmux session named `main` with 3 panes: Claude CLI (left), `watch git log` (right-top), `watch git status` (right-bottom). Auto-runs when opening a terminal outside tmux.
- **`bin/.local/bin/project-open`** — Interactive project picker (`Ctrl+a N` in tmux). Lists local `~/Projects` + GitHub repos via `gh` API, clones or inits as needed, opens a new tmux window with the dev layout.

## Architecture

### Stow Packages

| Package | Destination | Contents |
|---------|-------------|----------|
| `zsh` | `~` | `.zshrc`, `.zprofile` |
| `git` | `~` | `.gitconfig`, `.gitignore_global` |
| `tmux` | `~` | `.tmux.conf` |
| `claude` | `~` | `.claude/settings.json` |
| `ssh` | `~` | `.ssh/config` |
| `gh` | `~` | `.config/gh/config.yml` |
| `bin` | `~` | `.local/bin/*` scripts |
| `init` | `~` | `.local/bin/setup-mac` |
| `stow` | `~` | `.stow-global-ignore` |

### Session Boot Sequence

Opening a terminal outside tmux triggers `.zshrc` → `dev-session` → attaches to (or creates) the `main` tmux session with Claude running in the primary pane.

### Project Workflow

`Ctrl+a N` → `project-open` popup → fzf list of local + GitHub projects → select or type name → clones/inits if missing → new tmux window with dev layout (Claude + git watchers).

## Tmux Key Bindings

Prefix is `Ctrl+a`.

- `|` / `-` — split vertical/horizontal
- `h/j/k/l` — navigate panes (vim-style)
- `H/J/K/L` — resize panes
- `N` — open project picker
- `r` — reload tmux config
- `c` — new window (preserves path)

## ZSH Aliases of Note

- `tm` — attach main tmux session
- `cc` — Claude Code CLI
- `projects` — `cd ~/Projects`
- `dots` — `cd ~/Projects/dotfiles`
- `g`, `gs`, `gp`, `gpl`, `gl`, `gco`, `gcb` — git shortcuts
- `dev`, `build`, `test`, `lint` — pnpm equivalents

## Adding a New Package

1. Create the directory mirroring `~`'s structure: e.g., `nvim/.config/nvim/init.lua`
2. Add `stow nvim` to `install.sh`
3. Run `./install.sh` or `stow -d ~/Projects/dotfiles -t ~ nvim`

## Claude Code Settings (`claude/.claude/settings.json`)

- Model: `opusplan`
- Allowed tools include all standard dev tools (pnpm, git, gh, docker, vercel, wrangler, uv, cargo, etc.)
- Denied file patterns: `.env*`, `*.key`, `*.pem`, `.git/*`
- macOS notifications hooked on Claude events
