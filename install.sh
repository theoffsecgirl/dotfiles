#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

NONINTERACTIVE=0
CHANGE_SHELL="ask"
DRY_RUN=0

usage() {
  cat <<'EOF'
Uso: ./install.sh [opciones]

Opciones:
  --yes, --non-interactive   No pedir confirmaciones
  --change-shell             Cambiar shell a zsh si procede
  --no-shell-change          No cambiar shell
  --dry-run                  Mostrar qué haría stow sin aplicar cambios
  -h, --help                 Mostrar ayuda
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --yes|--non-interactive)
      NONINTERACTIVE=1
      shift
      ;;
    --change-shell)
      CHANGE_SHELL="yes"
      shift
      ;;
    --no-shell-change)
      CHANGE_SHELL="no"
      shift
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "[!] Opción no reconocida: $1" >&2
      usage
      exit 1
      ;;
  esac
done

info() { printf '[*] %s\n' "$*"; }
ok()   { printf '[+] %s\n' "$*"; }
warn() { printf '[!] %s\n' "$*"; }

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "[!] Falta dependencia requerida: $1" >&2
    exit 1
  }
}

detect_os() {
  case "$(uname -s)" in
    Darwin) echo "macos" ;;
    Linux)  echo "linux" ;;
    *)      echo "other" ;;
  esac
}

install_linux_base() {
  if ! command -v apt-get >/dev/null 2>&1; then
    warn "No hay apt-get; omito instalación automática de paquetes"
    return 0
  fi

  info "Instalando dependencias base en Linux"
  sudo apt-get update -qq
  sudo apt-get install -y \
    zsh tmux neovim stow git curl wget jq fzf ripgrep fd-find \
    bat xclip python3 python3-venv shellcheck
}

install_macos_base() {
  if ! command -v brew >/dev/null 2>&1; then
    warn "Homebrew no está instalado; omito instalación automática"
    warn "Instala Homebrew: https://brew.sh"
    return 0
  fi

  # stow primero — lo necesitamos para apply_stow
  command -v stow >/dev/null 2>&1 || brew install stow

  if [[ -f "$ROOT/brew/Brewfile" ]]; then
    info "Instalando desde brew/Brewfile (fuente de verdad)"
    brew bundle --file="$ROOT/brew/Brewfile" || warn "Algunas fórmulas fallaron — revisa la salida anterior"
  else
    warn "brew/Brewfile no encontrado; instalando conjunto mínimo"
    brew install stow zsh tmux neovim jq fzf ripgrep fd bat zoxide atuin shellcheck
  fi
}

apply_stow() {
  need_cmd stow

  local packages=()
  for d in zsh tmux git nvim ghostty scripts; do
    [[ -d "$d" ]] && packages+=("$d")
  done

  if [[ ${#packages[@]} -eq 0 ]]; then
    warn "No se encontraron paquetes stow — ¿estás ejecutando desde el directorio correcto?"
    return 1
  fi

  info "Paquetes a enlazar: ${packages[*]}"
  info "Preflight de stow (simulación)"
  stow -nv -t "$HOME" "${packages[@]}"

  if [[ "$DRY_RUN" -eq 1 ]]; then
    warn "Modo --dry-run: no se han aplicado cambios"
    return 0
  fi

  info "Aplicando stow"
  stow --restow -t "$HOME" "${packages[@]}"
  ok "Symlinks aplicados"
}

fix_exec_bits() {
  info "Ajustando permisos de scripts del repo"
  while IFS= read -r -d '' f; do
    chmod +x "$f"
  done < <(find "$ROOT" \( -path '*/.git/*' -o -path '*/vendor/*' \) -prune \
    -o -type f \( -name '*.sh' -o -path '*/.local/bin/*' \) -print0)
  ok "Permisos ajustados"
}

ensure_local_dirs() {
  mkdir -p "$HOME/.config/zsh" "$HOME/.local/bin" "$HOME/.cache/zsh"
}

maybe_change_shell() {
  local zsh_path
  zsh_path="$(command -v zsh || true)"
  [[ -n "$zsh_path" ]] || return 0

  case "$CHANGE_SHELL" in
    yes)
      ;;
    no)
      return 0
      ;;
    ask)
      if [[ "$NONINTERACTIVE" -eq 1 ]]; then
        return 0
      fi
      read -r -p "¿Cambiar shell a zsh? [s/N] " reply
      [[ "${reply:-}" =~ ^[sS]$ ]] || return 0
      ;;
  esac

  if [[ "${SHELL:-}" != "$zsh_path" ]]; then
    info "Cambiando shell por defecto a $zsh_path"
    chsh -s "$zsh_path" || warn "No se pudo cambiar la shell automáticamente — hazlo manualmente: chsh -s $zsh_path"
  fi
}

suggest_local_zsh() {
  local local_cfg="$HOME/.config/zsh/local.zsh"
  if [[ ! -f "$local_cfg" ]]; then
    info "Creando ~/.config/zsh/local.zsh con plantilla de HUNTING_HOME"
    cat > "$local_cfg" <<'LOCAL'
# ~/.config/zsh/local.zsh — overrides locales (no versionado)
# Ajusta HUNTING_HOME a tu workspace real:
#
# export HUNTING_HOME="$HOME/Library/Mobile Documents/com~apple~CloudDocs/02_PROFESIONAL/bugbounty"
#
# Otras variables de entorno específicas de esta máquina van aquí.
LOCAL
    ok "Plantilla creada → $local_cfg (edítala para ajustar HUNTING_HOME)"
  fi
}

main() {
  ensure_local_dirs
  fix_exec_bits

  if [[ "$DRY_RUN" -eq 0 ]]; then
    case "$(detect_os)" in
      macos) install_macos_base ;;
      linux) install_linux_base ;;
      *)     warn "SO no soportado para bootstrap automático" ;;
    esac
  fi

  apply_stow
  [[ "$DRY_RUN" -eq 1 ]] && return 0

  maybe_change_shell
  suggest_local_zsh

  if [[ -f "$ROOT/tools/install-tools.sh" ]]; then
    info "Instalando herramientas de seguridad (Go tools)"
    bash "$ROOT/tools/install-tools.sh" || warn "Algunas herramientas no se instalaron — revisa la salida anterior"
  fi

  ok "Instalación completada"
  echo
  echo "Siguiente paso:"
  echo "  1. Edita ~/.config/zsh/local.zsh y ajusta HUNTING_HOME"
  echo "  2. exec zsh"
}

main "$@"
