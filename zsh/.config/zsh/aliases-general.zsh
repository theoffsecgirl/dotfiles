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
alias ll='ls -lAh'
alias la='ls -A'
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
alias grep='grep --color=auto'
if command -v bat >/dev/null 2>&1; then
  alias cat='bat --paging=never'
elif command -v batcat >/dev/null 2>&1; then
  alias cat='batcat --paging=never'
fi
alias df='df -h'
alias du='du -h'
alias duu='du -sh * | sort -rh | head -20'
alias ports='ss -tulanp 2>/dev/null || netstat -tulanp'
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
  _tips_cmd program-init "Inicializar programa multi-dominio en un único workspace"
  _tips_cmd program-import-brief "Importar brief.txt y generar scope-web/out-of-scope/roots"
  _tips_cmd scope-program "Recon multi-dominio usando in/roots.txt sin crear carpetas por dominio"
  _tips_cmd mktarget "Crear estructura de target single-domain"
  _tips_cmd scope "Enumerar subdominios y descubrir HTTP vivos para un dominio"
  _tips_cmd webmap "Crawlear URLs, JS y candidatos API"
  _tips_cmd paramhunt-v2 "Extraer URLs con parámetros y claves únicas"
  _tips_cmd subscan "Enumeración rápida de subdominios"
  _tips_func subenum "Helper legacy para enumerar subdominios"
  _tips_func probe "Helper legacy para probar HTTP con httpx"
  _tips_func recon "Pipeline legacy rápido de recon"
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
  _tips_func note "Añadir nota rápida global"
  _tips_func notes "Abrir o listar notas del día"
  _tips_func tnote "Crear nota rápida del target actual"
  _tips_func tnotes "Listar notas del target actual"

  _tips_section "PYTHON"
  _tips_alias py "Ejecutar python3"
  _tips_alias pip "Ejecutar pip3 fuera de venv"
  _tips_alias venv-create "Crear entorno virtual"
  _tips_alias venv-activate "Activar entorno virtual local"
  _tips_alias venv-deactivate "Desactivar entorno virtual"
  _tips_func venv-auto "Detectar y activar venv automáticamente"

  _tips_section "DOCKER / OFFSEC"
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
  _tips_alias offsec "Entrar al contenedor offsec"
  _tips_alias offsec-up "Levantar contenedor offsec"
  _tips_alias offsec-shell "Abrir shell dentro del contenedor offsec"
  _tips_alias offsec-restart "Reiniciar contenedor offsec"
  _tips_alias offsec-rebuild "Reconstruir contenedor offsec"

  _tips_section "SISTEMA Y UTILIDADES"
  _tips_alias ll "Listar ficheros con detalles y ocultos"
  _tips_alias la "Listar ficheros ocultos"
  _tips_alias mkdir "Crear directorios intermedios automáticamente"
  _tips_alias cp "Copiar mostrando ficheros"
  _tips_alias mv "Mover mostrando ficheros"
  _tips_alias rm "Borrar con confirmación interactiva"
  _tips_alias grep "Buscar texto con color"
  _tips_alias df "Ver espacio de disco en formato humano"
  _tips_alias du "Ver tamaño en formato humano"
  _tips_alias duu "Ver directorios/ficheros que más ocupan"
  _tips_alias ports "Listar puertos abiertos"
  _tips_func myip "Mostrar IP pública"
  _tips_func localip "Mostrar IP local"
  _tips_alias path "Mostrar PATH línea por línea"
  _tips_alias reload "Recargar shell zsh"

  content="${content#\n}"

  if command -v fzf >/dev/null 2>&1; then
    selected="$(printf '%b' "$content" | column -ts $'\t' | fzf --ansi --no-sort --reverse --header='tips — ENTER copia el comando · busca por nombre/categoría/descripción · ESC para salir')" || return 0
    cmd="${selected%% *}"
    [[ -n "$cmd" && "$cmd" != "===" && "$cmd" != "COMANDO" ]] || return 0
    _tips_copy "$cmd" && print -r -- "[+] Copiado al portapapeles: $cmd"
  elif command -v column >/dev/null 2>&1; then
    printf '%b' "$content" | column -ts $'\t' | less
  else
    printf '%b' "$content" | less
  fi
}
