#!/bin/bash
# ============================================================================
# Dotfiles Bootstrap Script
#
# Usage:  git clone https://github.com/ianstarz/dotfiles ~/Projects/dotfiles
#         cd ~/Projects/dotfiles && ./install.sh
#
# What it does:
#   1. Installs Homebrew + GNU stow (if missing)
#   2. Backs up any existing dotfiles that would conflict
#   3. Stows all packages (creates symlinks into ~)
#
# Safe to re-run — idempotent and non-destructive.
# ============================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

ok()   { echo -e "  ${GREEN}✓${NC} $1"; }
skip() { echo -e "  ${YELLOW}⊘${NC} $1"; }
warn() { echo -e "  ${YELLOW}⚠${NC} $1"; }
fail() { echo -e "  ${RED}✗${NC} $1"; }
info() { echo -e "  $1"; }

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"

echo -e "${BOLD}"
echo "╔══════════════════════════════════════════════════╗"
echo "║   Dotfiles Installer                              ║"
echo "╚══════════════════════════════════════════════════╝"
echo -e "${NC}"

# Ensure we're in the dotfiles directory
if [[ ! -f "$DOTFILES_DIR/install.sh" ]]; then
    fail "Please run this script from the dotfiles directory."
    exit 1
fi

cd "$DOTFILES_DIR"

# ============================================================================
# Step 1: Dependencies
# ============================================================================
echo -e "\n${BLUE}${BOLD}▸ Checking dependencies${NC}"

# Homebrew
if command -v brew &>/dev/null; then
    skip "Homebrew (already installed)"
else
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    ok "Homebrew"
fi

# GNU stow
if command -v stow &>/dev/null; then
    skip "GNU stow (already installed)"
else
    info "Installing GNU stow..."
    brew install stow
    ok "GNU stow"
fi

# ============================================================================
# Step 2: Backup existing dotfiles
# ============================================================================
echo -e "\n${BLUE}${BOLD}▸ Checking for existing dotfiles${NC}"

# All stow packages (top-level directories that aren't hidden or special)
PACKAGES=(zsh git claude ssh stow)

NEEDS_BACKUP=false

# Build list of files that stow would create
declare -a CONFLICTS=()

for pkg in "${PACKAGES[@]}"; do
    if [[ ! -d "$DOTFILES_DIR/$pkg" ]]; then
        continue
    fi

    # Find all files in the package (relative to package dir)
    while IFS= read -r -d '' file; do
        rel="${file#$DOTFILES_DIR/$pkg/}"
        target="$HOME/$rel"

        # If target exists and is NOT already a symlink to our dotfiles, back it up
        if [[ -e "$target" && ! -L "$target" ]]; then
            CONFLICTS+=("$target")
            NEEDS_BACKUP=true
        fi
    done < <(find "$DOTFILES_DIR/$pkg" -type f -print0)
done

if $NEEDS_BACKUP; then
    mkdir -p "$BACKUP_DIR"
    info "Backing up existing files to $BACKUP_DIR"

    for file in "${CONFLICTS[@]}"; do
        rel="${file#$HOME/}"
        backup_path="$BACKUP_DIR/$rel"
        mkdir -p "$(dirname "$backup_path")"
        mv "$file" "$backup_path"
        warn "Backed up: ~/$rel"
    done

    ok "All conflicts backed up to $BACKUP_DIR"
else
    skip "No conflicts found — nothing to back up"
fi

# ============================================================================
# Step 3: Stow all packages
# ============================================================================
echo -e "\n${BLUE}${BOLD}▸ Stowing packages${NC}"

for pkg in "${PACKAGES[@]}"; do
    if [[ ! -d "$DOTFILES_DIR/$pkg" ]]; then
        warn "Package '$pkg' directory not found — skipping"
        continue
    fi

    # --restow handles the case where symlinks already exist
    if stow --restow --target="$HOME" "$pkg" 2>&1; then
        ok "$pkg"
    else
        fail "$pkg — stow failed"
        info "Try: cd ~/Projects/dotfiles && stow --verbose --restow $pkg"
    fi
done

# ============================================================================
# Step 4: Fix permissions on sensitive files
# ============================================================================
echo -e "\n${BLUE}${BOLD}▸ Setting permissions${NC}"

if [[ -f "$HOME/.ssh/config" ]]; then
    chmod 700 "$HOME/.ssh"
    chmod 600 "$HOME/.ssh/config"
    ok "~/.ssh/ permissions (700/600)"
fi

if [[ -d "$HOME/.claude" ]]; then
    chmod 700 "$HOME/.claude"
    chmod 600 "$HOME/.claude/settings.json"
    ok "~/.claude/ permissions (700/600)"
fi

# ============================================================================
# Step 5: Create GitHub repo (if gh is available and repo doesn't exist)
# ============================================================================
echo -e "\n${BLUE}${BOLD}▸ GitHub repository${NC}"

if command -v gh &>/dev/null && gh auth status &>/dev/null 2>&1; then
    if gh repo view ianstarz/dotfiles &>/dev/null 2>&1; then
        skip "GitHub repo ianstarz/dotfiles already exists"
    else
        info "Creating public repo ianstarz/dotfiles..."
        if gh repo create dotfiles --public --source="$DOTFILES_DIR" --push; then
            ok "Created and pushed to github.com/ianstarz/dotfiles"
        else
            warn "Could not create repo — you can do it manually:"
            info "  gh repo create dotfiles --public --source=~/Projects/dotfiles --push"
        fi
    fi
else
    warn "GitHub CLI not authenticated — skipping repo creation"
    info "Run: ${BOLD}gh auth login${NC}"
    info "Then: ${BOLD}gh repo create dotfiles --public --source=~/Projects/dotfiles --push${NC}"
fi

# ============================================================================
# Done
# ============================================================================
echo ""
echo -e "${BOLD}"
echo "╔══════════════════════════════════════════════════╗"
echo "║   Dotfiles installed!                             ║"
echo "╚══════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""
echo -e "  Packages stowed: ${GREEN}${PACKAGES[*]}${NC}"
if $NEEDS_BACKUP; then
    echo -e "  Backups saved to: ${YELLOW}$BACKUP_DIR${NC}"
fi
echo ""
echo -e "  ${BOLD}To add a new dotfile:${NC}"
echo "    1. Create the file in ~/Projects/dotfiles/<package>/ mirroring its path from ~"
echo "    2. Run: cd ~/Projects/dotfiles && stow --restow <package>"
echo "    3. Commit and push"
echo ""
echo -e "  ${BOLD}To unstow (remove symlinks):${NC}"
echo "    cd ~/Projects/dotfiles && stow --delete <package>"
echo ""
echo -e "  ${BOLD}On a new machine:${NC}"
echo "    git clone https://github.com/ianstarz/dotfiles ~/Projects/dotfiles"
echo "    cd ~/Projects/dotfiles && ./install.sh"
echo ""
