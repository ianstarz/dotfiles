# ============================================================================
# .zprofile — Login shell setup
# Managed by GNU stow from ~/dotfiles
# ============================================================================

# Homebrew (Apple Silicon)
if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi
