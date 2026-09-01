# dotfiles-ref — cheatsheet interactivo de mi setup de dotfiles
# Shell, git, navegación, utilidades generales.
# El pipeline de bug bounty (recon, hunt-ai, etc.) vive ahora en el repo
# separado bugbounty-toolkit — este cheatsheet ya no referencia esos comandos.
# ENTER copia el snippet al portapapeles.
# Busca por técnica, categoría, herramienta o keyword.
# -------------------------
dotfiles-ref() {
  emulate -L zsh
  setopt local_options no_aliases

  local content=""
  local selected=""
  local snippet=""

  _bb_section() {
    local title="$1"
    content+="\n=== ${title} ===\n"
    content+="NOMBRE\tCATEGORÍA\tSNIPPET\n"
  }

  _bb_add() {
    local name="$1"
    local cat="$2"
    local snippet="$3"
    content+="${name}\t${cat}\t${snippet}\n"
  }

  _bb_copy() {
    local value="$1"
    if command -v pbcopy >/dev/null 2>&1; then
      printf '%s' "$value" | pbcopy
    elif command -v wl-copy >/dev/null 2>&1; then
      printf '%s' "$value" | wl-copy
    elif command -v xclip >/dev/null 2>&1; then
      printf '%s' "$value" | xclip -selection clipboard
    else
      print -r -- "[!] No hay pbcopy/wl-copy/xclip. Snippet: $value" >&2
      return 1
    fi
  }

  # ─────────────────────────────────────────────────────────────
  _bb_section "EDICIÓN / RELOAD"
  _bb_add "ezsh"        "config"  'ezsh'
  _bb_add "dalias"      "config"  'dalias'
  _bb_add "dfunctions"  "config"  'dfunctions'
  _bb_add "reloadzsh"   "config"  'reloadzsh'
  _bb_add "showaliases" "config"  'showaliases'
  _bb_add "dotfiles"    "config"  'dotfiles'
  _bb_add "edit"        "config"  'make edit'

  # ─────────────────────────────────────────────────────────────
  _bb_section "PROYECTOS"
  _bb_add "mkproject"   "proyectos" 'mkproject nombre carpeta1,carpeta2,carpeta3'
  _bb_add "gotodir"     "proyectos" 'gotodir <fragmento-nombre>'
  _bb_add "quickvenv"   "proyectos" 'quickvenv'

  # ─────────────────────────────────────────────────────────────
  _bb_section "SISTEMA"
  _bb_add "updateall"    "sistema" 'updateall'
  _bb_add "update_system" "sistema" 'update_system'
  _bb_add "make-update"  "sistema" 'make update'
  _bb_add "extra"        "sistema" 'extra archivo.tar.gz'
  _bb_add "bigfiles"     "sistema" 'bigfiles [directorio]'
  _bb_add "copyip"       "sistema" 'copyip'
  _bb_add "wheremi"      "sistema" 'wheremi'
  _bb_add "err"          "sistema" 'comando 2>&1 | err'
  _bb_add "serve"        "sistema" 'serve'

  # ─────────────────────────────────────────────────────────────
  _bb_section "DOCKER"
  _bb_add "dps"       "docker" 'dps'
  _bb_add "di"         "docker" 'di'
  _bb_add "dclean"     "docker" 'dclean'
  _bb_add "drm"        "docker" 'drm'
  _bb_add "dstopall"   "docker" 'dstopall'

  # ─────────────────────────────────────────────────────────────
  _bb_section "TMUX / SESIONES"
  _bb_add "tmux-sessionizer"   "tmux"    'tmux-sessionizer'
  _bb_add "tmux-popup"         "tmux"    'tmux-popup'

  # ─────────────────────────────────────────────────────────────
  content="${content#\\n}"

  if command -v fzf >/dev/null 2>&1; then
    selected="$(printf '%b' "$content" | column -ts $'\t' | fzf \
      --ansi \
      --no-sort \
      --reverse \
      --header='dotfiles-ref — ENTER copia el snippet · busca por técnica/categoría/tool · ESC para salir')" || return 0

    # Extraer el snippet: es la tercera columna — todo lo que hay tras el segundo bloque de espacios
    snippet="$(printf '%s' "$selected" | sed 's/^[^ ]*[[:space:]][[:space:]]*[^ ]*[[:space:]][[:space:]]*//')"

    [[ -n "$snippet" && "$snippet" != "SNIPPET" && "$snippet" != "===" ]] || return 0
    _bb_copy "$snippet" && print -r -- "[+] Copiado al portapapeles: $snippet"
  elif command -v column >/dev/null 2>&1; then
    printf '%b' "$content" | column -ts $'\t' | less
  else
    printf '%b' "$content" | less
  fi
}

# -------------------------
# Compatibilidad temporal: bbref se renombró a dotfiles-ref (2026-08-21).
# Retira este wrapper cuando confirmes que ya no lo necesitas.
# -------------------------
bbref() {
  print -u2 -- "[!] bbref se renombró a dotfiles-ref — usa 'dotfiles-ref' a partir de ahora."
  dotfiles-ref "$@"
}
