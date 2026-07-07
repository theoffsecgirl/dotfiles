# aliases-general.zsh — aliases de productividad generales
# Cargado automáticamente desde load.zsh

# -------------------------
# Git
# -------------------------
alias gs='git status -sb'
alias gl='git log --oneline --graph --decorate -20'
alias gp='git push'
alias gpl='git pull'
alias gc='git commit -m'
alias gca='git commit --amend --no-edit'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gd='git diff'
alias gds='git diff --staged'
grh() {
  print -r -- "[!] git reset --hard HEAD — se perderán todos los cambios sin stage/commit en:"
  git diff --stat HEAD
  read -r -q "reply?¿Continuar? [s/N] " || { echo; return 1 }
  echo
  git reset --hard HEAD
}
alias gst='git stash'
alias gstp='git stash pop'
alias gb='git branch -vv'
alias glog='git log --oneline --graph --all --decorate'

# -------------------------
# Navegación con zoxide
# -------------------------
# j/ji eliminados: zoxide ya provee z/zi como nombres nativos

# -------------------------
# Utilidades generales
# -------------------------
if command -v eza >/dev/null 2>&1; then
  alias ll='eza -la --group-directories-first'
  alias la='eza -a'
elif command -v lsd >/dev/null 2>&1; then
  alias ll='lsd -la --group-dirs=first'
  alias la='lsd -a'
else
  alias ll='ls -lAh'
  alias la='ls -A'
fi
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias mkdir='mkdir -p'
alias cp='cp -v'
alias mv='mv -v'
if rm --version 2>/dev/null | grep -q GNU; then
  alias rm='rm -I'
else
  alias rm='rm -i'
fi
rmrf() {
  [[ $# -eq 0 ]] && { echo "Uso: rmrf <path> [path2 ...]"; return 1; }
  print -r -- "[!] rm -rf — se eliminarán permanentemente:"
  local _p
  for _p in "$@"; do
    ls -lad -- "$_p" 2>/dev/null || print -r -- "  (no existe: $_p)"
  done
  read -r -q "reply?¿Continuar? [s/N] " || { echo; return 1; }
  echo
  command rm -rf -- "$@"
}
alias grep='grep --color=auto'
if command -v bat >/dev/null 2>&1; then
  alias cat='bat --paging=never --style=plain'
elif command -v batcat >/dev/null 2>&1; then
  alias cat='batcat --paging=never'
fi
alias df='df -h'
alias du='du -h'
alias duu='du -sh * | sort -rh | head -20'
alias ports='ss -tulanp 2>/dev/null || netstat -tulanp'
unalias myip localip grh rmrf 2>/dev/null || true
myip() {
  local ip
  for _url in https://api.ipify.org https://ifconfig.me https://icanhazip.com; do
    ip="$(curl -s --max-time 3 "$_url")" && { echo "$ip"; return 0; }
  done
  echo "[!] No se pudo obtener la IP pública" >&2; return 1
}
localip() {
  ipconfig getifaddr en0 2>/dev/null && return
  ip -4 addr show scope global | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -1
}
alias c='clear'
alias q='exit'
alias path='echo $PATH | tr ":" "\n"'
alias reload='exec zsh'
alias dotfiles='cd ~/.dotfiles'
alias hunting='cd "$HUNTING_HOME"'

# -------------------------
# Python
# -------------------------
alias py='python3'
if [[ -z "${VIRTUAL_ENV:-}" ]]; then
  alias pip='pip3'
fi

# -------------------------
# Docker
# -------------------------
if command -v docker >/dev/null 2>&1; then
  alias dk='docker'
  alias dkps='docker ps'
  alias dkpsa='docker ps -a'
  alias dkimg='docker images'
  alias dkrm='docker rm'
  alias dkrmi='docker rmi'
  alias dkstop='docker stop'
  alias dkexec='docker exec -it'
  alias dklog='docker logs -f'
  alias dkprune='docker system prune -f'
fi

# -------------------------
# Tips — cheatsheet interactivo curado
# ENTER copia el comando al portapapeles.
# -------------------------
tips() {
  emulate -L zsh
  setopt local_options no_aliases

  local content=""
  local selected=""
  local cmd=""

  _tips_section() {
    local title="$1"
    content+="\n=== ${title} ===\n"
    content+="COMANDO\tTIPO\tDESCRIPCIÓN\n"
  }

  _tips_add() {
    local name="$1"
    local kind="$2"
    local desc="$3"
    content+="${name}\t${kind}\t${desc}\n"
  }

  _tips_alias() {
    local name="$1"
    local desc="$2"
    [[ -n "${aliases[$name]:-}" ]] || return 0
    _tips_add "$name" "alias" "$desc"
  }

  _tips_func() {
    local name="$1"
    local desc="$2"
    (( $+functions[$name] )) || return 0
    _tips_add "$name" "función" "$desc"
  }

  _tips_cmd() {
    local name="$1"
    local desc="$2"
    if (( $+commands[$name] )) || (( $+functions[$name] )) || [[ -n "${aliases[$name]:-}" ]]; then
      _tips_add "$name" "comando" "$desc"
    fi
  }

  _tips_copy() {
    local value="$1"
    if command -v pbcopy >/dev/null 2>&1; then
      printf '%s' "$value" | pbcopy
    elif command -v wl-copy >/dev/null 2>&1; then
      printf '%s' "$value" | wl-copy
    elif command -v xclip >/dev/null 2>&1; then
      printf '%s' "$value" | xclip -selection clipboard
    elif command -v xsel >/dev/null 2>&1; then
      printf '%s' "$value" | xsel --clipboard --input
    else
      print -r -- "[!] No encuentro pbcopy, wl-copy, xclip ni xsel. Comando seleccionado: $value" >&2
      return 1
    fi
  }

  _tips_section "GIT"
  _tips_alias gs "Ver estado corto del repositorio"
  _tips_alias gl "Ver últimos commits en formato gráfico"
  _tips_alias gp "Subir commits al remoto"
  _tips_alias gpl "Traer cambios del remoto"
  _tips_alias gd "Ver diff de cambios sin staged"
  _tips_alias gds "Ver diff de cambios staged"
  _tips_alias gc "Crear commit con mensaje"
  _tips_alias gca "Rehacer el último commit sin cambiar mensaje"
  _tips_alias gco "Cambiar de rama o checkout"
  _tips_alias gcb "Crear y cambiar a una rama nueva"
  _tips_func grh "Reset hard al HEAD actual; pide confirmación"
  _tips_alias gst "Guardar cambios en stash"
  _tips_alias gstp "Recuperar último stash"
  _tips_alias gb "Listar ramas con tracking"
  _tips_alias glog "Ver grafo completo de ramas y commits"

  _tips_section "NAVEGACIÓN"
  _tips_cmd z "Saltar a directorios frecuentes con zoxide"
  _tips_cmd zi "Abrir selector interactivo de zoxide"
  _tips_alias dotfiles "Entrar en ~/.dotfiles"
  _tips_alias hunting "Entrar en $HUNTING_HOME"
  _tips_func cdh "Entrar en el workspace de hunting"
  _tips_func cdt "Entrar en targets"
  _tips_func cdn "Entrar en notas globales"
  _tips_func cds "Entrar en scripts de hunting"
  _tips_alias .. "Subir un nivel"
  _tips_alias ... "Subir dos niveles"
  _tips_alias .... "Subir tres niveles"
  _tips_alias c "Limpiar pantalla"
  _tips_alias q "Salir de la shell actual"

  _tips_section "BUG BOUNTY WORKFLOW"
  _tips_cmd offsec "CLI principal del workflow de bug bounty"
  _tips_cmd offsec-init "Subcomando interno: offsec init <programa>"
  _tips_cmd offsec-import "Subcomando interno: offsec import <programa>"
  _tips_cmd offsec-scope "Subcomando interno: offsec scope <programa>"
  _tips_cmd offsec-webmap "Subcomando interno: offsec webmap <programa>"
  _tips_cmd offsec-params "Subcomando interno: offsec params <programa>"
  _tips_cmd offsec-recon "Subcomando interno: offsec recon <programa>"
  _tips_cmd offsec-doctor "Subcomando interno: offsec doctor"
  _tips_cmd scope "Wrapper estable: recon inicial single-domain"
  _tips_cmd webmap "Wrapper estable: crawling URLs, JS y candidatos API"
  _tips_cmd paramhunt-v2 "Descubrimiento de parámetros"
  _tips_cmd scope-program "Implementación interna: recon multi-dominio"
  _tips_cmd program-init "Implementación interna: inicializar workspace"
  _tips_cmd program-import-brief "Implementación interna: importar brief"
  _tips_func inscope "Filtrar resultados por scope"

  _tips_section "HTTP Y FUZZING"
  _tips_alias h "Ejecutar httpx básico"
  _tips_alias hh "Ejecutar httpx con tecnología y status code"
  _tips_alias hhh "Ejecutar httpx con title y webserver"
  _tips_alias ch "Consultar cabeceras HTTP"
  _tips_alias hget "Lanzar petición GET"
  _tips_alias hpost "Lanzar petición POST"
  _tips_alias f "Ejecutar ffuf base"
  _tips_alias nuc "Ejecutar nuclei en modo silencioso"
  _tips_func nucl "Ejecutar nuclei orientado a CVEs"

  _tips_section "NOTAS"
  _tips_func note "Añadir nota rápida global (append a archivo diario)"
  _tips_func tnote "Crear nota rápida del target actual"
  _tips_func tnotes "Listar notas del target actual"

  _tips_section "PYTHON"
  _tips_alias py "Ejecutar python3"
  _tips_alias pip "Ejecutar pip3 fuera de venv"
  _tips_alias venv-create "Crear entorno virtual"
  _tips_alias venv-activate "Activar entorno virtual local"
  _tips_alias venv-deactivate "Desactivar entorno virtual"
  _tips_func venv-auto "Detectar y activar venv automáticamente"

  _tips_section "DOCKER / CONTENEDOR OFFSEC"
  _tips_alias dk "Alias corto de docker"
  _tips_alias dkps "Listar contenedores activos"
  _tips_alias dkpsa "Listar todos los contenedores"
  _tips_alias dkimg "Listar imágenes"
  _tips_alias dkrm "Borrar contenedor"
  _tips_alias dkrmi "Borrar imagen"
  _tips_alias dkstop "Parar contenedor"
  _tips_alias dkexec "Entrar en contenedor con shell interactiva"
  _tips_alias dklog "Ver logs en streaming"
  _tips_alias dkprune "Limpiar recursos Docker no usados"
  _tips_func offsec-container "Entrar al contenedor offsec legacy"
  _tips_func offsec-container-init "Inicializar contenedor offsec legacy"
  _tips_func offsec-container-rebuild "Parar → eliminar → reconstruir → arrancar contenedor legacy"
  _tips_cmd offsec-up "Levantar contenedor offsec"
  _tips_cmd offsec-shell "Abrir shell dentro del contenedor offsec"

  _tips_section "SISTEMA Y UTILIDADES"
  _tips_alias ll "Listar ficheros con detalles y ocultos"
  _tips_alias la "Listar ficheros ocultos"
  _tips_alias mkdir "Crear directorios intermedios automáticamente"
  _tips_alias cp "Copiar mostrando ficheros"
  _tips_alias mv "Mover mostrando ficheros"
  _tips_alias rm "Borrar con confirmación interactiva"
  _tips_func rmrf "rm -rf con preview de lo que se borra y confirmación"
  _tips_alias grep "Buscar texto con color"
  _tips_alias df "Ver espacio de disco en formato humano"
  _tips_alias du "Ver tamaño en formato humano"
  _tips_alias duu "Ver directorios/ficheros que más ocupan"
  _tips_alias ports "Listar puertos abiertos"
  _tips_func myip "Mostrar IP pública"
  _tips_func localip "Mostrar IP local"
  _tips_alias path "Mostrar PATH línea por línea"
  _tips_alias reload "Recargar shell zsh"


  _tips_section "TMUX"
  _tips_add 'Ctrl+a' "keybind" 'Prefix de tmux (en lugar de Ctrl+b)'
  _tips_add 'prefix r' "keybind" 'Recargar config de tmux'
  _tips_add 'prefix |' "keybind" 'Split vertical (panel derecho)'
  _tips_add 'prefix -' "keybind" 'Split horizontal (panel abajo)'
  _tips_add 'prefix h/j/k/l' "keybind" 'Navegar entre paneles (vim-like)'
  _tips_add 'prefix H/J/K/L' "keybind" 'Redimensionar panel'
  _tips_add 'prefix c' "keybind" 'Nueva ventana'
  _tips_add 'prefix 1-9' "keybind" 'Ir a ventana por numero'
  _tips_add 'prefix </>' "keybind" 'Mover ventana izquierda/derecha'
  _tips_add 'prefix x' "keybind" 'Cerrar panel'
  _tips_add 'prefix X' "keybind" 'Cerrar ventana'
  _tips_add 'prefix g' "keybind" 'Popup flotante en directorio actual'
  _tips_add 'prefix Ctrl+n' "keybind" 'Abrir nota rapida en nvim'
  _tips_add 'prefix f' "keybind" 'tmux-sessionizer'
  _tips_add 'prefix b' "keybind" 'Toggle status bar'
  _tips_add 'prefix Space' "keybind" 'tmux-thumbs: copiar URL/IP/hash de pantalla'

  _tips_section "NVIM"
  _tips_add 'Space' "keybind" 'Leader key'
  _tips_add '<leader>ff' "keybind" 'Telescope: buscar ficheros'
  _tips_add '<leader>fg' "keybind" 'Telescope: grep en proyecto'
  _tips_add '<leader>fr' "keybind" 'Telescope: ficheros recientes'
  _tips_add '<leader>fn' "keybind" 'Telescope: notas de hunting'
  _tips_add '<leader>e' "keybind" 'Toggle arbol de ficheros (nvim-tree)'
  _tips_add '<leader>ha' "keybind" 'Harpoon: anadir fichero'
  _tips_add '<leader>hh' "keybind" 'Harpoon: abrir menu'
  _tips_add 'Ctrl+h/t/n/s' "keybind" 'Harpoon: saltar a fichero 1-4'
  _tips_add 's' "keybind" 'Flash: saltar a cualquier posicion'
  _tips_add '<leader>gg' "keybind" 'Neogit: panel de git'
  _tips_add '<leader>gd' "keybind" 'Diffview: ver diff'
  _tips_add '<leader>xx' "keybind" 'Trouble: diagnosticos del proyecto'
  _tips_add '<leader>ca' "keybind" 'LSP: code action'
  _tips_add '<leader>rn' "keybind" 'LSP: renombrar simbolo'
  _tips_add 'gd' "keybind" 'LSP: ir a definicion'
  _tips_add 'K' "keybind" 'LSP: documentacion hover'
  _tips_add 'Shift+h/l' "keybind" 'Navegar entre buffers'
  _tips_add '<leader>w/q' "keybind" 'Guardar / Cerrar'
  _tips_add '<leader>tt' "keybind" 'Abrir terminal integrada'
  _tips_add 'Ctrl+h/j/k/l' "keybind" 'Navegar entre splits'
  _tips_add ':Lazy' "keybind" 'Abrir gestor de plugins'
  _tips_add 'f/r/g/n' "keybind" 'Dashboard: find/recent/grep/notes'


  content="${content#\\n}"

  if command -v fzf >/dev/null 2>&1; then
    selected="$(printf '%b' "$content" | fzf --ansi --no-sort --reverse --delimiter=$'\t' --with-nth=1,2,3 --header='tips — ENTER copia el comando · busca por nombre/categoría/descripción · ESC para salir')" || return 0
    cmd="${selected%%$'\t'*}"
    [[ -n "$cmd" && "$cmd" != "===" && "$cmd" != "COMANDO" ]] || return 0
    _tips_copy "$cmd" && print -r -- "[+] Copiado al portapapeles: $cmd"
  elif command -v column >/dev/null 2>&1; then
    printf '%b' "$content" | column -ts $'\t' | less
  else
    printf '%b' "$content" | less
  fi
}

# bbref — cheatsheet interactivo de bug bounty
[[ -f "$HOME/.config/zsh/bbref.zsh" ]] && source "$HOME/.config/zsh/bbref.zsh"
