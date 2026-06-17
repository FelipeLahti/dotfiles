# ~/dotfiles/Brewfile  —  `brew bundle --file ~/dotfiles/Brewfile`
# Polyglot staff-engineer setup: TS/Node, Python, Go, Rust + AWS.

# ---- Core CLI ----
brew "git"
brew "gh"                 # GitHub CLI
brew "mise"               # unified version manager (node/python/go/rust)
brew "uv"                 # fast Python package/env manager (Astral)
brew "starship"           # prompt
brew "fzf"                # fuzzy finder
brew "zoxide"             # smarter cd
brew "zsh-autosuggestions"
brew "zsh-syntax-highlighting"

# ---- Modern CLI swaps ----
brew "eza"                # ls
brew "bat"                # cat
brew "ripgrep"            # grep
brew "fd"                 # find
brew "git-delta"          # git diff pager
brew "jq"                 # JSON
brew "yq"                 # YAML
brew "lazygit"            # git TUI
brew "btop"               # system monitor
brew "dust"               # disk usage
brew "tlrc"               # tldr client
brew "wget"
brew "tree"

# ---- Languages / build ----
brew "rustup"             # Rust toolchain installer (keg-only; bootstrap runs `rustup default stable`)
brew "golangci-lint"      # Go linter
brew "cargo-binstall"     # prebuilt cargo binaries

# ---- Containers (free, commercial-OK) ----
brew "colima"             # container runtime VM
brew "docker"             # docker CLI
brew "docker-compose"
brew "docker-buildx"
brew "lazydocker"         # docker TUI

# ---- AWS ----
brew "awscli"             # v2
brew "common-fate/granted/granted"  # fast AWS profile/console switching

# ---- macOS utilities ----
brew "defaultbrowser"     # set the default browser from the CLI (bootstrap sets Chrome)

# ---- GUI apps (casks) ----
cask "ghostty"            # terminal
cask "zed"               # editor
cask "google-chrome"      # browser (set as default in bootstrap)
cask "spotify"            # music
cask "1password"          # password manager
cask "1password-cli"      # `op` CLI + SSH agent integration
cask "raycast"            # launcher / clipboard / window mgmt
cask "obsidian"           # notes
cask "rectangle"          # (optional) window snapping if not using Raycast's
cask "font-jetbrains-mono-nerd-font"  # terminal/editor font w/ icons
