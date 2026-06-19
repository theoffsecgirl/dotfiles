#!/usr/bin/env bats
# tests/test_bbref.bats — verifica que cada script nuevo en scripts/.local/bin/
# tenga al menos una entrada en bbref.zsh, para evitar desincronización silenciosa.
# Ejecutar con: bats tests/test_bbref.bats

setup() {
  REPO_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  BIN="$REPO_ROOT/scripts/.local/bin"
  BBREF="$REPO_ROOT/zsh/.config/zsh/bbref.zsh"

  # Scripts que intencionalmente no tienen entrada en bbref:
  #   - deprecated/wrappers de aviso (se llaman por error, no por diseño)
  #   - utilidades de setup/infraestructura no relacionadas con hunting diario
  #   - wrappers estables que delegan en el v2 (ya cubiertos por el v2 en bbref)
  SKIP_LIST=(
    README.txt
    chatgpt-hypotheses
    chatgpt-recon
    claude-hypotheses
    claude-recon
    exegol-start
    install-go-tools
    kali-start
    offsec-bootstrap
    offsec-shell
    offsec-up
    paramhunt        # deprecated; paramhunt-v2 ya está en bbref
    scope            # wrapper de scope-v2; 'scope' ya está en bbref como alias
    scope-v2         # implementación; accedida via wrapper 'scope'
    webmap           # wrapper de webmap-v2; 'webmap' ya está en bbref como alias
    webmap-v2        # implementación; accedida via wrapper 'webmap'
    tmux-popup
    tmux-sessionizer
  )
}

# Devuelve 0 si el nombre está en SKIP_LIST
_is_skipped() {
  local name="$1"
  local s
  for s in "${SKIP_LIST[@]}"; do
    [[ "$s" == "$name" ]] && return 0
  done
  return 1
}

@test "Todos los scripts de bin/ tienen entrada en bbref.zsh o están en la lista de exclusión" {
  local missing=()

  while IFS= read -r -d '' script; do
    local name
    name="$(basename "$script")"

    # Ignorar README y ficheros no ejecutables
    [[ "$name" == "README.txt" ]] && continue
    [[ -x "$script" ]] || continue

    _is_skipped "$name" && continue

    # Buscar el nombre como primer argumento de _bb_add en bbref.zsh
    if ! grep -qE "_bb_add[[:space:]]+\"${name}\"" "$BBREF"; then
      missing+=("$name")
    fi
  done < <(find "$BIN" -maxdepth 1 -type f -print0)

  if [[ ${#missing[@]} -gt 0 ]]; then
    echo "Scripts sin entrada en bbref.zsh:"
    printf '  - %s\n' "${missing[@]}"
    echo ""
    echo "Opciones:"
    echo "  1. Añade _bb_add \"<nombre>\" ... en bbref.zsh"
    echo "  2. Añade el nombre a SKIP_LIST en tests/test_bbref.bats si es intencional"
    return 1
  fi
}

@test "bbref.zsh tiene sintaxis zsh válida" {
  run zsh -n "$BBREF"
  [ "$status" -eq 0 ]
}

@test "program-import-brief tiene entrada en bbref.zsh" {
  grep -q '"program-import-brief"' "$BBREF"
}

@test "tmux-recon tiene entrada en bbref.zsh" {
  grep -q '"tmux-recon"' "$BBREF"
}
