#!/usr/bin/env bash
# install.sh — bootstrap universal para theoffsecgirl/dotfiles
# Detecta macOS o Linux y configura el entorno completo.
#
# Uso:
#   git clone https://github.com/theoffsecgirl/dotfiles.git ~/.dotfiles
#   cd ~/.dotfiles && ./install.sh
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
OS="$(uname)"

log()  { printf '\033[1;34m[*]\033[0m %s\n' "$*"; }
ok()   { printf '\033[1;32m[+]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[!]\033[0m %s\n' "$*"; }
err()  { printf '\033[1;31m[x]\033[0m %s\n' "$*" >&2; exit 1; }

log "Dotfiles dir: $DOTFILES_DIR"
log "Sistema: $OS"

# ------------------------------------------------
# 1) Dependencias del sistema
# ------------------------------------------------
install_deps_macos() {
  if ! command -v brew >/dev/null 2>&1; then
    log "Instalando Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi

  if [[ -f "$DOTFILES_DIR/brew/Brewfile" ]]; then
    log "Instalando paquetes (brew bundle)..."
    brew bundle --file "$DOTFILES_DIR/brew/Brewfile"
  fi

  command -v stow >/dev/null 2>&1 || brew install stow
}

install_deps_linux() {
  if command -v apt >/dev/null 2>&1; then
    log "Actualizando apt e instalando dependencias base..."
    sudo apt update -qq
    sudo apt install -y --no-install-recommends \
      stow git curl zsh tmux neovim fzf bat ripgrep fd-find unzip jq
    # fd-find instala el binario como fdfind en Ubuntu
    if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
      mkdir -p "$HOME/.local/bin"
      ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
    fi
  elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y stow git curl zsh tmux neovim fzf bat ripgrep fd-find unzip jq
  elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -Syu --noconfirm stow git curl zsh tmux neovim fzf bat ripgrep fd unzip jq
  else
    warn "Gestor de paquetes no reconocido. Instala manualmente: stow git curl zsh tmux neovim fzf"
  fi
}

case "$OS" in
  Darwin) install_deps_macos ;;
  Linux)  install_deps_linux  ;;
  *)      err "Sistema no soportado: $OS" ;;
esac

# ------------------------------------------------
# 2) Aplicar dotfiles con stow
# ------------------------------------------------
log "Aplicando stow..."
cd "$DOTFILES_DIR"

STOW_PKGS=(zsh git tmux scripts nvim)
[[ "$OS" == "Darwin" ]] && STOW_PKGS+=(brew ghostty containers macos)

for pkg in "${STOW_PKGS[@]}"; do
  if [[ -d "$DOTFILES_DIR/$pkg" ]]; then
    stow -v --restow -t "$HOME" "$pkg" && ok "stow: $pkg"
  else
    warn "Directorio no encontrado, saltando stow: $pkg"
  fi
done

# ------------------------------------------------
# 3) Permisos de ejecución
# ------------------------------------------------
log "Aplicando chmod +x en ~/.local/bin..."
find "$HOME/.local/bin" -type f -exec chmod +x {} + 2>/dev/null || true

# ------------------------------------------------
# 4) Workspace hunting
# ------------------------------------------------
log "Creando workspace ~/hunting..."
mkdir -p "$HOME/hunting"/{targets,notes,scripts}

# ------------------------------------------------
# 5) Git identity local
# ------------------------------------------------
if [[ ! -f "$HOME/.gitconfig.local" ]]; then
  warn "~/.gitconfig.local no existe (necesario para commits)."
  printf '    Créalo con:\n'
  printf '      git config -f ~/.gitconfig.local user.name  "Tu Nombre"\n'
  printf '      git config -f ~/.gitconfig.local user.email "tu@email.com"\n'
fi

# ------------------------------------------------
# 6) Shell por defecto (opcional)
# ------------------------------------------------
if [[ "$SHELL" != *zsh ]]; then
  ZSH_PATH="$(command -v zsh 2>/dev/null || true)"
  if [[ -n "$ZSH_PATH" ]]; then
    warn "Tu shell actual no es zsh ($SHELL)."
    read -r -p "    ¿Cambiar shell a zsh? [s/N] " ch
    [[ "${ch,,}" == "s" ]] && chsh -s "$ZSH_PATH"
  fi
fi

echo ""
ok "Instalación completa. Abre una nueva terminal o ejecuta: source ~/.zshrc"
