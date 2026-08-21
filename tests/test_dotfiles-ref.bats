#!/usr/bin/env bats
# tests/test_dotfiles-ref.bats — verifica que cada script nuevo en scripts/.local/bin/
# tenga al menos una entrada en dotfiles-ref.zsh, para evitar desincronización silenciosa.
# Ejecutar con: bats tests/test_dotfiles-ref.bats

setup() {
  REPO_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  BIN="$REPO_ROOT/scripts/.local/bin"
  DOTFILES_REF="$REPO_ROOT/zsh/.config/zsh/dotfiles-ref.zsh"

  # Scripts que intencionalmente no tienen entrada en dotfiles-ref:
  #   - deprecated/wrappers de aviso (se llaman por error, no por diseño)
  #   - utilidades de setup/infraestructura no relacionadas con hunting diario
  #   - wrappers estables que delegan en el v2 (ya cubiertos por el v2 en dotfiles-ref)
  #   - dispatchers offsec-* retirados (cero uso real, ver auditoría 2026-08-21)
  SKIP_LIST=(
    README.txt
    chatgpt-hypotheses
    chatgpt-recon
    claude-hypotheses
    claude-recon
    exegol-start
    install-go-tools
    kali-start
    offsec             # retirado — dispatcher sin uso real, ver auditoría 2026-08-21
    offsec-bootstrap
    offsec-doctor       # retirado — dispatcher sin uso real, ver auditoría 2026-08-21
    offsec-import       # retirado — dispatcher sin uso real, ver auditoría 2026-08-21
    offsec-init         # huérfano tras retirar offsec-container-*; script intacto pero sin dispatcher que lo invoque
    offsec-params       # retirado — dispatcher sin uso real, ver auditoría 2026-08-21
    offsec-recon        # retirado — dispatcher sin uso real, ver auditoría 2026-08-21
    offsec-scope        # retirado — dispatcher sin uso real, ver auditoría 2026-08-21
    offsec-shell
    offsec-up
    offsec-webmap       # retirado — dispatcher sin uso real, ver auditoría 2026-08-21
    paramhunt        # deprecated; paramhunt-v2 ya está en dotfiles-ref
    scope            # wrapper de scope-v2; 'scope' ya está en dotfiles-ref como alias
    scope-v2         # implementación; accedida via wrapper 'scope'
    webmap           # wrapper de webmap-v2; 'webmap' ya está en dotfiles-ref como alias
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

@test "Todos los scripts de bin/ tienen entrada en dotfiles-ref.zsh o están en la lista de exclusión" {
  local missing=()

  while IFS= read -r -d '' script; do
    local name
    name="$(basename "$script")"

    # Ignorar README y ficheros no ejecutables
    [[ "$name" == "README.txt" ]] && continue
    [[ -x "$script" ]] || continue

    _is_skipped "$name" && continue

    # Buscar el nombre como primer argumento de _bb_add en dotfiles-ref.zsh
    if ! grep -qE "_bb_add[[:space:]]+\"${name}\"" "$DOTFILES_REF"; then
      missing+=("$name")
    fi
  done < <(find "$BIN" -maxdepth 1 -type f -print0)

  if [[ ${#missing[@]} -gt 0 ]]; then
    echo "Scripts sin entrada en dotfiles-ref.zsh:"
    printf '  - %s\n' "${missing[@]}"
    echo ""
    echo "Opciones:"
    echo "  1. Añade _bb_add \"<nombre>\" ... en dotfiles-ref.zsh"
    echo "  2. Añade el nombre a SKIP_LIST en tests/test_dotfiles-ref.bats si es intencional"
    return 1
  fi
}

@test "dotfiles-ref.zsh tiene sintaxis zsh válida" {
  run zsh -n "$DOTFILES_REF"
  [ "$status" -eq 0 ]
}

@test "program-import-brief tiene entrada en dotfiles-ref.zsh" {
  grep -q '"program-import-brief"' "$DOTFILES_REF"
}

@test "tmux-recon tiene entrada en dotfiles-ref.zsh" {
  grep -q '"tmux-recon"' "$DOTFILES_REF"
}
