#!/usr/bin/env bash
set -euo pipefail

# ==========================================
# Instalación de herramientas de theoffsecgirl
# ==========================================

TOOLS_DIR="${TOOLS_DIR:-$HOME/.local/tools}"
BIN_DIR="$HOME/.local/bin"

info() { printf '[*] %s\n' "$*"; }
ok()   { printf '[+] %s\n' "$*"; }
warn() { printf '[!] %s\n' "$*"; }

# Verificar dependencias
for _cmd in git python3; do
  command -v "$_cmd" >/dev/null 2>&1 || { warn "Dependencia no encontrada: $_cmd"; exit 1; }
done
unset _cmd

# Crear directorios necesarios
mkdir -p "$TOOLS_DIR" "$BIN_DIR"

# ------------------------------------------
# Clonar o actualizar un repositorio
# ------------------------------------------
clone_or_pull() {
  local name="$1"
  local repo="$2"
  local dest="$TOOLS_DIR/$name"

  if [[ -d "$dest/.git" ]]; then
    info "Actualizando $name..."
    git -C "$dest" pull --ff-only || warn "No se pudo actualizar $name (puede haber cambios locales)"
  else
    info "Clonando $name..."
    git clone "$repo" "$dest"
  fi
}

# ------------------------------------------
# Herramientas Python con pyproject.toml
# ------------------------------------------
install_python_tool() {
  local name="$1"
  local repo="$2"
  local dest="$TOOLS_DIR/$name"

  clone_or_pull "$name" "$repo"

  info "Creando venv para $name..."
  python3 -m venv "$dest/venv"

  info "Instalando $name en modo editable..."
  "$dest/venv/bin/pip" install --quiet --upgrade pip
  "$dest/venv/bin/pip" install --quiet -e "$dest"

  local bin_src="$dest/venv/bin/$name"
  if [[ -f "$bin_src" ]]; then
    ln -sf "$bin_src" "$BIN_DIR/$name"
    ok "$name → $BIN_DIR/$name"
  else
    warn "No se encontró el binario $bin_src; revisa el nombre del entry point"
  fi
}

# ------------------------------------------
# takeovflow: script .py suelto
# ------------------------------------------
install_takeovflow() {
  local name="takeovflow"
  local repo="https://github.com/theoffsecgirl/takeovflow.git"
  local dest="$TOOLS_DIR/$name"

  clone_or_pull "$name" "$repo"

  info "Creando venv para $name..."
  python3 -m venv "$dest/venv"
  "$dest/venv/bin/pip" install --quiet --upgrade pip
  "$dest/venv/bin/pip" install --quiet requests

  local wrapper="$BIN_DIR/$name"
  cat > "$wrapper" <<EOF
#!/usr/bin/env bash
source "$dest/venv/bin/activate"
exec python "$dest/takeovflow.py" "\$@"
EOF
  chmod +x "$wrapper"
  ok "$name → $wrapper"
}

# ------------------------------------------
# bluedeath: script Shell
# ------------------------------------------
install_bluedeath() {
  local name="bluedeath"
  local repo="https://github.com/theoffsecgirl/bluedeath.git"
  local dest="$TOOLS_DIR/$name"

  clone_or_pull "$name" "$repo"

  local script="$dest/bluedeath.sh"
  if [[ -f "$script" ]]; then
    chmod +x "$script"
    ln -sf "$script" "$BIN_DIR/$name"
    ok "$name → $BIN_DIR/$name"
  else
    warn "No se encontró $script; revisa la estructura del repo"
  fi
}

# ------------------------------------------
# Instalar herramientas
# ------------------------------------------
install_python_tool "webxray"    "https://github.com/theoffsecgirl/webxray.git"
install_python_tool "pathraider" "https://github.com/theoffsecgirl/pathraider.git"
install_python_tool "bb-copilot" "https://github.com/theoffsecgirl/bb-copilot.git"
install_takeovflow
install_bluedeath

# ------------------------------------------
# Resumen
# ------------------------------------------
echo
ok "Herramientas instaladas en $BIN_DIR:"
for _tool in webxray pathraider bb-copilot takeovflow bluedeath; do
  if [[ -e "$BIN_DIR/$_tool" ]]; then
    printf '  ✅ %s\n' "$_tool"
  else
    printf '  ❌ %s (no instalado)\n' "$_tool"
  fi
done
unset _tool
echo
info "Asegúrate de que $BIN_DIR está en tu PATH"
