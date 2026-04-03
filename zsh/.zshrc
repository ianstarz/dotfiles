# ============================================================================
# .zshrc — Ian's shell configuration
# Managed by GNU stow from ~/dotfiles
# ============================================================================

# --- Auto-attach to tmux dev session ----------------------------------------
if [[ -z "$TMUX" ]] && [[ "$TERM_PROGRAM" != "vscode" ]]; then
  exec "$HOME/.local/bin/dev-session"
fi

# --- Oh My Zsh --------------------------------------------------------------
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(git)

source $ZSH/oh-my-zsh.sh

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
export PATH="$HOME/.local/bin:$PATH"
