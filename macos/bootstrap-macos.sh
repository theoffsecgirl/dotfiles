#!/usr/bin/env bash
# bootstrap-macos.sh — instala dependencias y aplica dotfiles en macOS
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

echo "[*] Dotfiles dir: $DOTFILES_DIR"

# 1) Homebrew
if ! command -v brew >/dev/null 2>&1; then
  echo "[*] Instalando Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# shellenv (Apple Silicon / Intel)
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# 2) stow (necesario para "make install")
if ! command -v stow >/dev/null 2>&1; then
  echo "[*] Instalando stow..."
  brew install stow
fi

# 3) Delega en el Makefile: brew bundle (install/Brewfile) + stow runcom/config/bin
echo "[*] Ejecutando make install..."
cd "$DOTFILES_DIR"
make install

# 4) Git identity local (si no existe)
if [[ ! -f "$HOME/.gitconfig.local" ]]; then
  echo "[!] ~/.gitconfig.local no existe."
  echo "    Créalo con:"
  echo "      git config -f ~/.gitconfig.local user.name  'Tu Nombre'"
  echo "      git config -f ~/.gitconfig.local user.email 'tu@email.com'"
fi

echo ""
echo "[✓] Listo. Abre una nueva terminal o ejecuta: source ~/.zshrc"
