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
setopt SHARE_HISTORY HIST_IGNORE_ALL_DUPS HIST_REDUCE_BLANKS HIST_VERIFY EXTENDED_HISTORY
# SHARE_HISTORY already appends incrementally; HIST_VERIFY lets you edit a !-expansion
# before running it; EXTENDED_HISTORY records timestamps.

# ---- Shell options ----
setopt EXTENDED_GLOB                                # **/ globs, ^negation, (qualifiers)
setopt AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT    # `cd -<TAB>` browses a dir stack
setopt INTERACTIVE_COMMENTS                         # allow `# comments` at the prompt
setopt NO_BEEP
# (GLOB_DOTS intentionally left off: it would make `rm *` match .env/.git etc.)

# ---- Completions ----
autoload -Uz compinit && compinit -d "$HOME/.zcompdump"
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'   # case-insensitive

# ---- mise (Node/Python/Go/Rust versions) ----
eval "$(mise activate zsh)"

# ---- Tools ----
eval "$(starship init zsh)"
source <(fzf --zsh)

# ---- fzf UX (fd as the source, bat/eza previews, Catppuccin Mocha colors) ----
export FZF_DEFAULT_COMMAND='fd --hidden --strip-cwd-prefix --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type=d --hidden --strip-cwd-prefix --exclude .git'
export FZF_DEFAULT_OPTS="--height 40% --layout reverse --border --cycle
  --preview-window 'right:60%:border-left'
  --bind 'ctrl-/:toggle-preview'
  --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8
  --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc
  --color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers {} 2>/dev/null || eza --tree --color=always {} | head -200'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always --level=2 {} | head -200'"

# ---- fzf-tab (fuzzy completion menu; after compinit, before the widget-wrapping plugins) ----
source "$BREW_PREFIX/share/fzf-tab/fzf-tab.zsh"
zstyle ':completion:*' menu no                                   # hand the menu to fzf-tab
zstyle ':completion:*:descriptions' format '[%d]'                # group headers fzf-tab shows
zstyle ':fzf-tab:*' switch-group '<' '>'                         # `<`/`>` cycle completion groups
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --tree --color=always --level=2 $realpath | head -200'
zstyle ':fzf-tab:complete:z:*'  fzf-preview 'eza --tree --color=always --level=2 $realpath | head -200'

# ---- Plugins ----
source "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)   # suggest from completions too, not just history
bindkey '^ ' autosuggest-accept                  # Ctrl-Space accepts the inline suggestion
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

# ---- bat / man (syntax-highlighted pager, Catppuccin Mocha to match the theme) ----
export BAT_THEME="Catppuccin Mocha"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export MANROFFOPT="-c"   # avoid escape-sequence artifacts when bat renders man pages

# ---- zoxide ----
# Initialize last so its chpwd hook is the final one (mise/starship/plugins also
# register hooks). The hook is verified last in $chpwd_functions; the doctor's
# extra precmd check still false-positives against starship, so silence the noise.
export _ZO_DOCTOR=0
eval "$(zoxide init zsh)"

# ---- Local, machine-specific (not committed) ----
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
