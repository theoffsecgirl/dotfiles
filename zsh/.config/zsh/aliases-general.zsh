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
alias grh='git reset --hard HEAD'
alias gst='git stash'
alias gstp='git stash pop'
alias gb='git branch -vv'
alias glog='git log --oneline --graph --all --decorate'

# -------------------------
# Navegación con zoxide
# -------------------------
# j/ji eliminados: zoxide ya provee z/zi como nombres nativos
# Usa directamente: z <dir>  |  zi (interactivo)

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
# rm -I (GNU/Linux) ó rm -i (macOS/BSD) — pide confirmación antes de borrar varios ficheros
if rm --version 2>/dev/null | grep -q GNU; then
  alias rm='rm -I'
else
  alias rm='rm -i'
fi
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias df='df -h'
alias du='du -h'
alias duu='du -sh * | sort -rh | head -20'
alias ports='ss -tulanp 2>/dev/null || netstat -tulanp'
alias myip='curl -s https://api.ipify.org && echo'
alias localip="ipconfig getifaddr en0 2>/dev/null || ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}'"
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
# pip: solo si no estamos dentro de un venv (que ya tiene pip en PATH)
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
# Tips — cheatsheet interactivo de aliases y atajos
# -------------------------
tips() {
  emulate -L zsh
  setopt local_options extended_glob no_aliases

  local content=""
  local all_aliases=""
  local -a custom_functions
  local fn

  _tips_section() {
    local title="$1"
    content+="=== ${title} ===\n"
  }

  _tips_alias() {
    local name="$1"
    local note="$2"
    [[ -n "${aliases[$name]:-}" ]] || return 0
    if [[ -n "$note" ]]; then
      content+="${name}\t${aliases[$name]}\t# ${note}\n"
    else
      content+="${name}\t${aliases[$name]}\n"
    fi
  }

  _tips_func() {
    local name="$1"
    local note="$2"
    (( $+functions[$name] )) || return 0
    if [[ -n "$note" ]]; then
      content+="${name}\tfunción\t# ${note}\n"
    else
      content+="${name}\tfunción\n"
    fi
  }

  _tips_section "GIT"
  _tips_alias gs "estado corto"
  _tips_alias gl "log gráfico"
  _tips_alias gd "diff actual"
  _tips_alias gds "diff staged"
  _tips_alias gc "commit rápido"
  _tips_alias gca "amend último commit"
  _tips_alias gst "stash"
  _tips_alias gstp "stash pop"
  _tips_alias gb "ramas verbosas"
  _tips_alias glog "log global"
  content+="\n"

  _tips_section "NAVEGACIÓN"
  if (( $+commands[z] )) || (( $+functions[z] )); then
    content+="z\tcomando\t# saltar a directorio frecuente (zoxide)\n"
  fi
  if (( $+commands[zi] )) || (( $+functions[zi] )); then
    content+="zi\tcomando\t# selector interactivo de directorios\n"
  fi
  _tips_alias dotfiles "cd ~/.dotfiles"
  _tips_alias hunting "cd $HUNTING_HOME"
  _tips_alias .. "subir 1 nivel"
  _tips_alias ... "subir 2 niveles"
  _tips_alias .... "subir 3 niveles"
  content+="\n"

  _tips_section "RECON"
  _tips_func subenum "enumera subdominios"
  _tips_func probe "httpx con tech detect"
  _tips_func recon "pipeline rápido"
  _tips_func inscope "filtra scope"
  _tips_alias nuc "nuclei -silent"
  _tips_func nucl "nuclei CVEs"
  content+="\n"

  _tips_section "HTTP"
  _tips_alias h "httpx básico"
  _tips_alias hh "httpx + tech + status"
  _tips_alias hhh "httpx + title + webserver"
  _tips_alias ch "curl headers"
  _tips_alias hget "HTTP GET"
  _tips_alias hpost "HTTP POST"
  _tips_alias f "ffuf base"
  content+="\n"

  _tips_section "DOCKER"
  _tips_alias dk "docker base"
  _tips_alias dkps "docker ps"
  _tips_alias dkpsa "docker ps -a"
  _tips_alias dkimg "docker images"
  _tips_alias dkexec "docker exec -it"
  _tips_alias dklog "docker logs -f"
  _tips_alias dkprune "docker system prune"
  _tips_alias offsec "entrar al contenedor offsec-toolbox"
  _tips_alias offsec-restart "reiniciar toolbox"
  _tips_alias offsec-rebuild "rebuild toolbox"
  content+="\n"

  _tips_section "UTILIDADES"
  _tips_alias ll "ls largo"
  _tips_alias la "ls ocultos"
  _tips_alias duu "uso de disco ordenado"
  _tips_alias ports "puertos activos"
  _tips_alias myip "IP pública"
  _tips_alias localip "IP local"
  _tips_alias path "PATH línea por línea"
  _tips_alias reload "recargar shell"
  _tips_alias py "python3"
  _tips_alias pip "pip3 fuera de venv"
  _tips_func note "añadir nota rápida"
  _tips_func notes "ver notas de hoy"
  _tips_alias venv-create "crear venv"
  _tips_alias venv-activate "activar venv"
  _tips_alias venv-deactivate "desactivar venv"
  _tips_func venv-auto "activar venv automático"
  _tips_alias scope-filter "compat alias antiguo"
  content+="\n"

  _tips_section "TODOS LOS ALIASES CARGADOS"
  all_aliases="$(alias | LC_ALL=C sort)"
  if [[ -n "$all_aliases" ]]; then
    content+="${all_aliases}\n"
  else
    content+="(sin aliases cargados)\n"
  fi
  content+="\n"

  _tips_section "FUNCIONES CUSTOM"
  custom_functions=(
    cdh cdt cdn cds
    subenum probe inscope recon
    nucl note notes
    venv-auto tips
  )
  for fn in "${custom_functions[@]}"; do
    (( $+functions[$fn] )) && content+="${fn}\n"
  done

  if command -v fzf >/dev/null 2>&1; then
    printf '%b' "$content" | fzf --ansi --no-sort --reverse --header='tips — aliases y funciones cargadas · ESC para salir'
  else
    printf '%b' "$content" | less
  fi
}
