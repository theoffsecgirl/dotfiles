#!/usr/local/bin/bash
set -euo pipefail

# -------------------------
# Init script dotfiles (theoffsecgirl)
# -------------------------

DOTFILES_ROOT=""
if [[ -d "$HOME/dotfiles/stow" ]]; then
  DOTFILES_ROOT="$HOME/dotfiles/stow"
else
  DOTFILES_ROOT="$HOME/dotfiles"
fi

BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "[theoffsecgirl] usando DOTFILES_ROOT = $DOTFILES_ROOT"
echo "[theoffsecgirl] backups en $BACKUP_DIR"

# macOS: instalar Homebrew si hace falta
if [[ "$(uname)" == "Darwin" ]]; then
  if ! command -v brew >/dev/null 2>&1; then
    echo "[theoffsecgirl] instalando Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # añadir brew al PATH para esta sesión (Apple Silicon & Intel)
    if [[ -d "/opt/homebrew/bin" ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -d "/usr/local/bin" ]]; then
      eval "$(/usr/local/bin/brew shellenv)" || true
    fi
  fi
fi

# instalar stow si hace falta
if ! command -v stow >/dev/null 2>&1; then
  echo "[theoffsecgirl] instalando stow..."
  if [[ "$(uname)" == "Darwin" ]]; then
    brew install stow || true
  elif command -v apt >/dev/null 2>&1; then
    sudo apt update && sudo apt install -y stow
  elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y stow
  else
    echo "[theoffsecgirl] no he podido auto-instalar stow, instálalo manualmente y vuelve a ejecutar este script."
    exit 1
  fi
fi

# función: aplicar stow en module con backup de conflictos
stow_module() {
  module="$1"
  module_path="$DOTFILES_ROOT/$module"
  if [[ ! -d "$module_path" ]]; then
    return 0
  fi
  echo "[theoffsecgirl] procesando módulo: $module"

  conflicts=$(stow -n -v -d "$DOTFILES_ROOT" -t "$HOME" "$module" 2>&1 | sed -n 's/^.*existing target //p' || true)
  if [[ -n "$conflicts" ]]; then
    echo "[theoffsecgirl] se detectaron conflictos. Haciendo backup de los targets:"
    while IFS= read -r line; do
      target="$HOME/$line"
      if [[ -e "$target" || -L "$target" ]]; then
        echo "  - backup $target -> $BACKUP_DIR/"
        mkdir -p "$BACKUP_DIR/$(dirname "$line")"
        # Cambiado a cp -a para backup, y luego rm original
        cp -a "$target" "$BACKUP_DIR/$line"
        rm -rf "$target"
      fi
    done <<< "$conflicts"
  fi

  # aplicar stow realmente
  stow -v -d "$DOTFILES_ROOT" -t "$HOME" "$module"
}

# módulos: puedes auto detectar todos los subdirectorios si quieres
if [[ -z ${MODULES+x} ]]; then
  mapfile -t MODULES < <(find "$DOTFILES_ROOT" -maxdepth 1 -mindepth 1 -type d -printf '%f\n')
fi

for m in "${MODULES[@]}"; do
  stow_module "$m"
done

# instalar Brewfile si existe (macOS)
if [[ "$(uname)" == "Darwin" ]] && [[ -f "$DOTFILES_ROOT/homebrew/Brewfile" ]]; then
  echo "[theoffsecgirl] instalando Brewfile..."
  brew bundle --file="$DOTFILES_ROOT/homebrew/Brewfile" || true
fi

# -------------------------
# VENV para bugbounty / scripting Python
# -------------------------
VENV_DIR="$HOME/venvs/bugbounty"
REQ_PATH="$DOTFILES_ROOT/venvs/requirements.txt"

if [[ ! -d "$VENV_DIR" ]]; then
  echo "[theoffsecgirl] creando venv en $VENV_DIR"
  python3 -m venv "$VENV_DIR"
  "$VENV_DIR/bin/python" -m pip install --upgrade pip wheel setuptools
  if [[ -f "$REQ_PATH" ]]; then
    echo "[theoffsecgirl] instalando requirements desde $REQ_PATH"
    "$VENV_DIR/bin/pip" install -r "$REQ_PATH"
  else
    echo "[theoffsecgirl] no hay requirements.txt en $REQ_PATH, saltando install"
  fi
else
  echo "[theoffsecgirl] venv ya existe en $VENV_DIR (si quieres reinstalar borra la carpeta)"
fi

# Añadir Catppuccin solo si no existe config previa
NVIM_PLUGIN_DIR="$HOME/.config/nvim/lua/plugins"
COLORS_FILE="$NVIM_PLUGIN_DIR/colorscheme_catppuccin.lua"
if [[ ! -f "$COLORS_FILE" ]]; then
  mkdir -p "$NVIM_PLUGIN_DIR"
  cat > "$COLORS_FILE" <<'EOF'
return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "frappe",
        integrations = { treesitter = true, telescope = true, cmp = true, gitsigns = true },
      })
      vim.cmd.colorscheme("catppuccin-frappe")
    end
  }
}
EOF
fi

echo "[theoffsecgirl] init.sh completado. Backups en: $BACKUP_DIR"
echo "[theoffsecgirl] para activar el entorno python: source $VENV_DIR/bin/activate"
