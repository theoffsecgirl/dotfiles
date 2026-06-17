#!/usr/bin/env bash
# apply-audit-fixes.sh — aplica los fixes del audit de dotfiles
# Ejecutar desde cualquier sitio: bash apply-audit-fixes.sh
set -euo pipefail

DOTFILES="${DOTFILES_DIR:-$HOME/.dotfiles}"
BIN="$DOTFILES/scripts/.local/bin"
ZSH_BB="$DOTFILES/zsh/.config/zsh/bug-bounty.zsh"

ok()   { printf '\033[1;32m[+]\033[0m %s\n' "$*"; }
info() { printf '\033[1;34m[*]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[!]\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31m[x]\033[0m %s\n' "$*" >&2; exit 1; }

[[ -d "$DOTFILES" ]] || die "No encuentro $DOTFILES — ajusta DOTFILES_DIR"

# ─────────────────────────────────────────────────────────────
# 1. race-burst: for i → for _
# ─────────────────────────────────────────────────────────────
info "race-burst: renombrar variable de bucle i → _"
TARGET_FILE="$BIN/race-burst"
[[ -f "$TARGET_FILE" ]] || die "No encuentro $TARGET_FILE"

if grep -q 'for i in \$(seq' "$TARGET_FILE"; then
  sed -i.bak 's/for i in \$(seq/for _ in $(seq/' "$TARGET_FILE"
  rm -f "${TARGET_FILE}.bak"
  ok "race-burst parcheado"
else
  warn "race-burst: el patrón ya no existe, saltando"
fi

# ─────────────────────────────────────────────────────────────
# 2. race-burst: advertencia sobre nc + TLS
# ─────────────────────────────────────────────────────────────
info "race-burst: añadir aviso sobre nc/TLS"
if ! grep -q 'AVISO: nc no habla TLS' "$TARGET_FILE"; then
  sed -i.bak 's|echo "\[\*\] Lanzando \$NUM requests contra \$HOST"|warn() { printf '"'"'[!] %s\\n'"'"' "$*"; }\nwarn "AVISO: nc no habla TLS. Este script solo funciona en HTTP plano (puerto 80)."\nwarn "Para race conditions sobre HTTPS usa race-run (curl) o Turbo Intruder."\necho "[*] Lanzando $NUM requests contra $HOST"|' "$TARGET_FILE"
  rm -f "${TARGET_FILE}.bak"
  ok "race-burst: aviso añadido"
else
  warn "race-burst: aviso ya existe, saltando"
fi

# ─────────────────────────────────────────────────────────────
# 3. paramhunt-v2: borrar líneas MODE=
# ─────────────────────────────────────────────────────────────
info "paramhunt-v2: eliminar variable MODE (dead code)"
TARGET_FILE="$BIN/paramhunt-v2"
[[ -f "$TARGET_FILE" ]] || die "No encuentro $TARGET_FILE"

if grep -q '^\s*MODE=' "$TARGET_FILE"; then
  sed -i.bak '/^\s*MODE=/d' "$TARGET_FILE"
  rm -f "${TARGET_FILE}.bak"
  ok "paramhunt-v2: MODE eliminado"
else
  warn "paramhunt-v2: MODE ya no existe, saltando"
fi

# ─────────────────────────────────────────────────────────────
# 4. offsec-up: corregir shebang
# ─────────────────────────────────────────────────────────────
info "offsec-up: corregir shebang #!/bin/bash → #!/usr/bin/env bash"
TARGET_FILE="$BIN/offsec-up"
[[ -f "$TARGET_FILE" ]] || die "No encuentro $TARGET_FILE"

if head -1 "$TARGET_FILE" | grep -q '^#!/bin/bash$'; then
  sed -i.bak '1s|#!/bin/bash|#!/usr/bin/env bash|' "$TARGET_FILE"
  rm -f "${TARGET_FILE}.bak"
  ok "offsec-up: shebang corregido"
else
  warn "offsec-up: shebang ya es correcto o diferente, saltando"
fi

# ─────────────────────────────────────────────────────────────
# 5. Scripts v1: convertir en wrappers de deprecación
#    (no los borra — los convierte para no romper workflows viejos)
# ─────────────────────────────────────────────────────────────
info "Scripts v1: convertir en wrappers de deprecación"

deprecate() {
  local script="$1"
  local successor="$2"
  local file="$BIN/$script"

  [[ -f "$file" ]] || { warn "$script no encontrado, saltando"; return; }

  # Si ya está deprecado, no tocar
  if grep -q 'DEPRECADO\|Deprecado\|deprecado' "$file" 2>/dev/null; then
    warn "$script: ya tiene aviso de deprecación, saltando"
    return
  fi

  cat > "$file" <<WRAPPER
#!/usr/bin/env bash
# DEPRECADO — este script ya no se mantiene.
# Usa: $successor
set -euo pipefail

printf '\033[1;33m[!]\033[0m %s\n' "DEPRECADO: $script → usa $successor" >&2
exec "\$(dirname "\${BASH_SOURCE[0]}")/$successor" "\$@"
WRAPPER

  chmod +x "$file"
  ok "$script → wrapper que redirige a $successor"
}

deprecate "paramhunt"        "paramhunt-v2"
deprecate "claude-hypotheses" "claude-hypotheses-v2"
deprecate "claude-recon"      "claude-recon-v2"
# chatgpt-* no tienen v2 equivalente — solo se avisa
for s in chatgpt-hypotheses chatgpt-recon; do
  file="$BIN/$s"
  [[ -f "$file" ]] || continue
  if ! grep -q 'DEPRECADO' "$file" 2>/dev/null; then
    sed -i.bak "1a\\
# DEPRECADO — sin sucesor activo. Ver claude-hypotheses-v2 / claude-recon-v2." "$file"
    rm -f "${file}.bak"
    ok "$s: comentario de deprecación añadido"
  else
    warn "$s: ya tiene aviso, saltando"
  fi
done

# ─────────────────────────────────────────────────────────────
# 6. bug-bounty.zsh: eliminar mktarget_legacy
# ─────────────────────────────────────────────────────────────
info "bug-bounty.zsh: eliminar función mktarget_legacy"
[[ -f "$ZSH_BB" ]] || die "No encuentro $ZSH_BB"

if grep -q 'mktarget_legacy()' "$ZSH_BB"; then
  # Borrar desde el comentario previo hasta el cierre de función (línea con sola "}")
  # Usamos python3 para un parse más seguro que sed multilínea
  python3 - "$ZSH_BB" <<'PYEOF'
import sys

path = sys.argv[1]
with open(path) as f:
    lines = f.readlines()

out = []
skip = False
depth = 0
i = 0
while i < len(lines):
    line = lines[i]
    # Detectar inicio del bloque (comentario + función)
    if not skip and '# Deprecated: kept only as a fallback' in line:
        skip = True
        depth = 0
        i += 1
        continue
    if skip:
        depth += line.count('{') - line.count('}')
        if depth <= 0 and '}' in line:
            skip = False
            i += 1
            # eliminar línea en blanco extra que queda después
            if i < len(lines) and lines[i].strip() == '':
                i += 1
            continue
        i += 1
        continue
    out.append(line)
    i += 1

with open(path, 'w') as f:
    f.writelines(out)
PYEOF
  ok "bug-bounty.zsh: mktarget_legacy eliminada"
else
  warn "bug-bounty.zsh: mktarget_legacy ya no existe, saltando"
fi

# ─────────────────────────────────────────────────────────────
# Resumen
# ─────────────────────────────────────────────────────────────
echo ""
ok "Todos los fixes aplicados."
echo ""
echo "Siguiente paso:"
echo "  cd $DOTFILES && git diff"
echo "  git add -p && git commit -m 'chore: apply audit fixes'"
