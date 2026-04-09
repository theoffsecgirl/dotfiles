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

# 2) Brew bundle
if [[ -f "$DOTFILES_DIR/brew/Brewfile" ]]; then
  echo "[*] Instalando dependencias (brew bundle)..."
  brew bundle --file "$DOTFILES_DIR/brew/Brewfile"
fi

# 3) stow
if ! command -v stow >/dev/null 2>&1; then
  echo "[*] Instalando stow..."
  brew install stow
fi

echo "[*] Aplicando stow..."
cd "$DOTFILES_DIR"
stow -v -t "$HOME" zsh git tmux brew scripts nvim ghostty containers

# 4) Permisos de ejecución en scripts
echo "[*] Aplicando chmod +x en ~/.local/bin..."
chmod +x "$HOME/.local/bin/"* 2>/dev/null || true

# 5) Estructura de workspace hunting
echo "[*] Creando workspace ~/hunting..."
mkdir -p "$HOME/hunting"/{targets,notes,scripts}

# 6) Git identity local (si no existe)
if [[ ! -f "$HOME/.gitconfig.local" ]]; then
  echo "[!] ~/.gitconfig.local no existe."
  echo "    Créalo con:"
  echo "      git config -f ~/.gitconfig.local user.name  'Tu Nombre'"
  echo "      git config -f ~/.gitconfig.local user.email 'tu@email.com'"
fi

echo ""
echo "[✓] Listo. Abre una nueva terminal o ejecuta: source ~/.zshrc"
