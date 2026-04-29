#!/usr/bin/env bash
set -euo pipefail

# ==========================================
# Actualización de herramientas de theoffsecgirl
# ==========================================

TOOLS_DIR="${TOOLS_DIR:-$HOME/.local/tools}"

info() { printf '[*] %s\n' "$*"; }
ok()   { printf '[+] %s\n' "$*"; }
warn() { printf '[!] %s\n' "$*"; }

[[ -d "$TOOLS_DIR" ]] || { warn "Directorio de herramientas no encontrado: $TOOLS_DIR"; exit 1; }

updated=0
skipped=0

for tool_dir in "$TOOLS_DIR"/*/; do
  [[ -d "$tool_dir/.git" ]] || continue

  name="$(basename "$tool_dir")"
  info "Actualizando $name..."

  if git -C "$tool_dir" pull --ff-only 2>/dev/null; then
    ok "$name actualizado"
  else
    warn "$name — no se pudo hacer pull (puede haber cambios locales)"
    (( skipped += 1 ))
    continue
  fi

  # Si tiene venv y pyproject.toml o setup.py, reinstalar dependencias
  if [[ -d "$tool_dir/venv" ]]; then
    if [[ -f "$tool_dir/pyproject.toml" || -f "$tool_dir/setup.py" || -f "$tool_dir/setup.cfg" ]]; then
      info "Reinstalando dependencias Python de $name..."
      "$tool_dir/venv/bin/pip" install --quiet --upgrade pip
      "$tool_dir/venv/bin/pip" install --quiet -e "$tool_dir" || warn "No se pudieron reinstalar las dependencias de $name"
    else
      "$tool_dir/venv/bin/pip" install --quiet --upgrade pip || true
    fi
  fi

  (( updated += 1 ))
done

echo
ok "Actualización completada: $updated herramienta(s) actualizada(s), $skipped omitida(s)"
