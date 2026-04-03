# ============================================================================
# .zshrc — Ian's shell configuration
# Managed by GNU stow from ~/dotfiles
# ============================================================================

# --- Homebrew ---------------------------------------------------------------
if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# --- fnm (Fast Node Manager) -----------------------------------------------
eval "$(fnm env --use-on-cd --shell zsh)"

# --- Aliases ----------------------------------------------------------------
# Git
alias g="git"
alias gs="git status"
alias gp="git push"
alias gpl="git pull"
alias gl="git log --oneline -20"
alias gco="git checkout"
alias gcb="git checkout -b"

# Dev
alias dev="pnpm dev"
alias build="pnpm build"
alias test="pnpm test"
alias lint="pnpm lint"

# Navigation
alias projects="cd ~/Projects"
alias dots="cd ~/dotfiles"

# Claude
alias cc="claude"

# tmux
alias tm="tmux new-session -A -s main"

# --- Environment ------------------------------------------------------------
export EDITOR="code --wait"
export CLAUDE_CONFIG_DIR="$HOME/.claude"

# --- Path additions ---------------------------------------------------------
# Add local bin for user-installed scripts
export PATH="$HOME/.local/bin:$PATH"
