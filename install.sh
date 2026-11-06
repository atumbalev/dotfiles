#!/usr/bin/env bash
# Bootstrap a Mac from this repo. Safe to re-run.
#   git clone git@github.com:atumbalev/dotfiles.git ~/dotfiles && ~/dotfiles/install.sh
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }

# 1. Xcode command line tools (git, compilers for treesitter parsers)
if ! xcode-select -p >/dev/null 2>&1; then
  info "Installing Xcode command line tools (finish the dialog, then re-run this script)"
  xcode-select --install
  exit 1
fi

# 2. Homebrew
if ! command -v brew >/dev/null 2>&1; then
  info "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"

# 3. Packages, zsh plugins, apps
info "Installing Brewfile packages"
brew bundle --file "$DOTFILES/Brewfile"

# 4. Oh My Zsh (only the framework + git plugin; theme and plugins come from Homebrew)
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  info "Installing Oh My Zsh"
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# 5. Symlinks (existing files are moved to $BACKUP, never deleted)
link() {
  local src="$DOTFILES/$1" dst="$HOME/$1"
  if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
    return
  fi
  if [[ -e "$dst" || -L "$dst" ]]; then
    mkdir -p "$BACKUP/$(dirname "$1")"
    mv "$dst" "$BACKUP/$1"
    info "Backed up ~/$1 to $BACKUP/$1"
  fi
  mkdir -p "$(dirname "$dst")"
  ln -s "$src" "$dst"
  info "Linked ~/$1"
}

link .zshrc
link .p10k.zsh
link .config/nvim

# 6. Neovim plugins (LazyVim installs LSPs/parsers on first open of each filetype)
info "Syncing Neovim plugins"
nvim --headless "+Lazy! sync" +qa

info "Done. Open a new terminal (or run: exec zsh)."
