#!/usr/bin/env bash
# ~/dotfiles/bootstrap.sh — idempotent new-Mac setup. Safe to re-run.
set -euo pipefail

DOTFILES="$HOME/dotfiles"
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
log()  { printf "\033[1;34m==>\033[0m %s\n" "$1"; }
warn() { printf "\033[1;33m[!]\033[0m %s\n" "$1"; }

# 1. Xcode Command Line Tools -------------------------------------------------
if ! xcode-select -p >/dev/null 2>&1; then
  log "Installing Xcode Command Line Tools (a GUI dialog will pop up)…"
  xcode-select --install
  read -r -p "Press Enter once the CLT install finishes… "
fi

# 2. Touch ID for sudo (do this first so every later sudo uses your fingerprint)
if ! grep -q pam_tid /etc/pam.d/sudo_local 2>/dev/null; then
  log "Enabling Touch ID for sudo…"
  echo "auth       sufficient     pam_tid.so" | sudo tee /etc/pam.d/sudo_local >/dev/null
fi

# 3. Homebrew -----------------------------------------------------------------
if [[ ! -x /opt/homebrew/bin/brew ]] && ! command -v brew >/dev/null 2>&1; then
  log "Installing Homebrew…"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

# 4. Brew bundle --------------------------------------------------------------
# Homebrew 6+ blocks formulae from untrusted third-party taps. Tap + trust the
# ones we rely on before bundling, so the install never stops to ask.
log "Trusting third-party taps…"
brew tap common-fate/granted >/dev/null 2>&1 || true
brew trust common-fate/granted >/dev/null 2>&1 || true

log "Installing packages from Brewfile…"
brew bundle --file="$DOTFILES/Brewfile"

# 5. Symlink dotfiles ---------------------------------------------------------
link() {  # link <source-in-repo> <target-in-home>
  local src="$DOTFILES/$1" dest="$HOME/$2"
  mkdir -p "$(dirname "$dest")"
  if [[ -e "$dest" || -L "$dest" ]] && [[ "$(readlink "$dest")" != "$src" ]]; then
    mkdir -p "$BACKUP/$(dirname "$2")"
    mv "$dest" "$BACKUP/$2"
    warn "backed up existing $2 -> $BACKUP/$2"
  fi
  ln -sfn "$src" "$dest"
}
log "Symlinking dotfiles…"
link "config/zsh/.zshrc"        ".zshrc"
link "config/starship.toml"     ".config/starship.toml"
link "config/mise/config.toml"  ".config/mise/config.toml"
link "config/ghostty/config"    ".config/ghostty/config"
link "config/git/.gitconfig"    ".gitconfig"
link "config/zed/settings.json" ".config/zed/settings.json"

# 6. Language toolchains ------------------------------------------------------
log "Installing language runtimes via mise…"
mise install || warn "mise install had issues — run 'mise doctor' later"
log "Enabling corepack (pnpm/yarn)…"
corepack enable 2>/dev/null || true
# Homebrew's rustup is keg-only and no longer ships `rustup-init`; `rustup
# default stable` installs + selects the toolchain. Proxies live in
# $(brew --prefix rustup)/bin, which .zshrc adds to PATH.
if ! rustup default >/dev/null 2>&1; then
  log "Initializing Rust toolchain…"
  rustup default stable
fi
export PATH="$(brew --prefix rustup)/bin:$PATH"

# 7. Sensible macOS defaults --------------------------------------------------
log "Applying macOS defaults…"
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock show-recents -bool false
killall Finder Dock 2>/dev/null || true

# 8. Default browser ----------------------------------------------------------
# macOS may pop a confirmation dialog the first time the default browser changes.
if command -v defaultbrowser >/dev/null 2>&1; then
  log "Setting Chrome as the default browser (confirm the macOS prompt if it appears)…"
  defaultbrowser chrome || warn "Couldn't set Chrome as default — set it in System Settings ▸ Desktop & Dock"
fi

# 9. Colima (start container VM) ---------------------------------------------
if ! colima status >/dev/null 2>&1; then
  log "Starting Colima (Docker runtime)…"
  colima start --cpu 4 --memory 8 --disk 60 || warn "Colima will start on first 'colima start'"
fi

# 10. FileVault check ---------------------------------------------------------
if ! fdesetup status | grep -q "FileVault is On"; then
  warn "FileVault is OFF — enable disk encryption: System Settings ▸ Privacy & Security ▸ FileVault"
fi

cat <<'EOF'

✅ Bootstrap complete. Manual steps remaining:
  1. Open 1Password ▸ Settings ▸ Developer ▸ "Use the SSH agent" (ON).
  2. Add your SSH public key into ~/dotfiles/config/git/.gitconfig (signingkey),
     and upload it to GitHub as BOTH an Authentication AND a Signing key.
  3. AWS: `aws configure sso` to set up your SSO profiles, then `assume <profile>`.
  4. Restart your terminal (or `exec zsh`) to load everything.
  5. Sign in to Raycast, Obsidian, Zed; grant macOS permissions as prompted.
EOF
