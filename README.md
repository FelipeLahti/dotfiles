# dotfiles

New-Mac setup for a polyglot staff engineer (TS/Node · Python · Go · Rust · AWS).

## Quick start

```bash
git clone <your-repo-url> ~/dotfiles   # or just keep this local folder
cd ~/dotfiles
./bootstrap.sh                         # idempotent; safe to re-run
exec zsh
```

`bootstrap.sh` installs Xcode CLT, Homebrew + everything in `Brewfile`, symlinks
configs, installs language runtimes via mise, and applies sane macOS defaults.
Existing files are backed up to `~/.dotfiles-backup/<timestamp>/` before linking.

## What's inside

| Path | Symlinks to | Purpose |
|------|-------------|---------|
| `Brewfile` | — | All CLIs + GUI apps (`brew bundle`) |
| `config/zsh/.zshrc` | `~/.zshrc` | Shell: mise, starship, fzf, zoxide, aliases |
| `config/starship.toml` | `~/.config/starship.toml` | Prompt |
| `config/mise/config.toml` | `~/.config/mise/config.toml` | Default Node/Python/Go versions |
| `config/ghostty/config` | `~/.config/ghostty/config` | Terminal |
| `config/git/.gitconfig` | `~/.gitconfig` | Git + 1Password SSH signing |
| `config/zed/settings.json` | `~/.config/zed/settings.json` | Editor |

## Stack decisions

- **Terminal**: Ghostty · **Shell**: zsh + Starship
- **Versions**: mise (Node/Python/Go) + rustup (Rust) + uv (Python pkgs) + pnpm
- **Secrets**: 1Password SSH agent; SSH-based commit signing (no keys on disk)
- **Editor**: Zed · **Containers**: Colima (free, commercial-OK) + docker CLI
- **Cloud**: awscli v2 + granted (`assume <profile>`)
- **Productivity**: Raycast, Obsidian

## Manual steps after bootstrap

1. **1Password** ▸ Settings ▸ Developer ▸ enable the SSH agent.
2. Paste your SSH **public key** into `config/git/.gitconfig` (`signingkey`), and
   add it to GitHub as both an **Authentication** and a **Signing** key.
3. **AWS**: `aws configure sso`, then `assume <profile>`.
4. Enable **FileVault** (System Settings ▸ Privacy & Security) if not already on.

## Per-machine overrides

Anything machine-specific (work env vars, secret-ish bits) goes in
`~/.zshrc.local` — sourced automatically, never committed.

## Work git identity

Put work repos under `~/work/`, create `config/git/.gitconfig-work` with your
work name/email/signingkey, and uncomment the `includeIf` block in `.gitconfig`.
