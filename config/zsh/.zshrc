# ~/.zshrc  (symlinked from ~/dotfiles/config/zsh/.zshrc)

# ---- Homebrew ----
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi
BREW_PREFIX="$(brew --prefix)"

# ---- User binaries (~/.local/bin) ----
# Tools installed for the current user only (e.g. the Claude Code CLI).
if [[ -d "$HOME/.local/bin" ]]; then
  export PATH="$HOME/.local/bin:$PATH"
fi

# ---- History ----
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY HIST_IGNORE_ALL_DUPS HIST_REDUCE_BLANKS INC_APPEND_HISTORY

# ---- Completions ----
autoload -Uz compinit && compinit -d "$HOME/.zcompdump"
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'   # case-insensitive

# ---- mise (Node/Python/Go/Rust versions) ----
eval "$(mise activate zsh)"

# ---- Tools ----
eval "$(starship init zsh)"
source <(fzf --zsh)

# ---- Plugins ----
source "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# ---- 1Password SSH agent ----
export SSH_AUTH_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"

# ---- Granted (AWS) ----
alias assume="source assume"

# ---- Docker (Colima) ----
# Colima serves Docker on its own socket; point the Docker CLI at it.
if [[ -S "$HOME/.colima/default/docker.sock" ]]; then
  export DOCKER_HOST="unix://$HOME/.colima/default/docker.sock"
fi

# ---- Node ----
export COREPACK_ENABLE_DOWNLOAD_PROMPT=0   # silent pnpm/yarn via corepack

# ---- Rust ----
# Homebrew's rustup is keg-only; its rustc/cargo proxies live here, not ~/.cargo/bin.
if [[ -d /opt/homebrew/opt/rustup/bin ]]; then
  export PATH="/opt/homebrew/opt/rustup/bin:$PATH"
fi

# ---- Aliases: modern CLI swaps ----
alias ls="eza --group-directories-first --icons"
alias ll="eza -lah --group-directories-first --icons --git"
alias lt="eza --tree --level=2 --icons"
alias cat="bat"
alias grep="rg"
alias find="fd"
alias cd="z"           # zoxide
alias lg="lazygit"
alias ld="lazydocker"
alias g="git"
alias k="kubectl"

# ---- Aliases: git shortcuts ----
alias gs="git status -sb"
alias gd="git diff"
alias gco="git checkout"
alias gp="git push"
alias gl="git pull"

# ---- Editor ----
export EDITOR="zed --wait"
export VISUAL="$EDITOR"

# ---- zoxide ----
# Initialize last: zoxide's doctor warns unless its precmd hook is the final one
# (mise/starship/plugins also register hooks, so it must come after them).
eval "$(zoxide init zsh)"

# ---- Local, machine-specific (not committed) ----
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
