# =========================
# Bug Bounty helpers (UNIFICADO)
# Fuente A: archivo subido /mnt/data/aliases-bugbounty.zsh
# Fuente B: contenido pegado en el chat
# Objetivo: no perder nada, preferir funciones robustas y conservar aliases legacy
# =========================

# -------------------------
# Mostrar aliases de forma legible
# -------------------------
showaliases() {
  alias | sed 's/^alias //' | column -t -s'=' | less
}
# legacy (por si alguien lo llama como alias explícito)
alias showaliases_legacy='alias | sed "s/alias //" | column -t -s"=" | less'


# -------------------------
# Navegación de trabajo
# -------------------------
alias proj='cd ~/proyectos'
alias bounty='cd ~/bugbounty'
alias ctf='cd ~/ctf'
alias shellutils='cd ~/shell-utils'


# -------------------------
# Edición rápida de configuración
# -------------------------
alias ezsh='nvim ~/.zshrc'

reloadzsh() {
  source ~/.zshrc && echo '[zsh recargado]'
}
# legacy (equivalente)
alias reloadzsh_legacy="source ~/.zshrc && echo '[zsh recargado]'"

alias dalias='nvim ~/shell-utils/zsh/aliases-bugbounty.zsh'
alias dfunctions='nvim ~/shell-utils/zsh/functions-bugbounty.zsh'


# -------------------------
# Git
# -------------------------
alias gst='git status'
alias gco='git checkout'
alias gaa='git add .'
alias gcm='git commit -m'
alias gpush='git push'
alias gpull='git pull'
alias ghist='git log --oneline --graph --decorate'


# -------------------------
# Hacking básico
# -------------------------
alias ffuf='ffuf'
alias nmapl='nmap -sC -sV -p-'
alias nuclei='nuclei -duc'
alias gobuster='gobuster'


# -------------------------
# Docker helpers (robustos)
# -------------------------
alias dps='docker ps'
alias di='docker images'
alias dclean='docker system prune -af --volumes'

drm() {
  local ids
  ids="$(docker ps -aq)"
  [[ -z "$ids" ]] && { echo "No hay contenedores."; return 0; }
  docker rm $ids
}

dstopall() {
  local ids
  ids="$(docker ps -aq)"
  [[ -z "$ids" ]] && { echo "No hay contenedores."; return 0; }
  docker stop $ids
}

# legacy (las versiones one-liner del archivo antiguo subido)
alias drm_legacy='docker rm $(docker ps -aq)'
alias dstopall_legacy='docker stop $(docker ps -aq)'


# -------------------------
# Búsqueda de archivos
# -------------------------
alias findsh='find . -type f -name "*.sh"'
alias findpy='find . -type f -name "*.py"'
alias findbin='find . -type f -perm -u=x'
alias findpcap='find . -type f -name "*.pcap"'


# -------------------------
# Credenciales / secretos
# -------------------------
findcreds() {
  local target="${1:-.}"
  grep -Ri --color=always -E "pass|secret|token|credential" "$target"
}

creds() {
  local target="${1:-.}"
  grep -Ri --color=always -E "pass|secret|token|key" "$target"
}

# legacy (del archivo subido; por compatibilidad)
alias findcreds_legacy='grep -Ri --color "pass|secret|token|credential" .'
# Este legacy era un grep sin ruta (tiende a quedarse esperando stdin). Lo preservo como “stdin”.
alias creds_stdin_legacy='grep -Ei --color "pass|secret|token|key"'


# -------------------------
# Reporting
# -------------------------
mdreport() {
  local ts fname
  ts="$(date +'%F %T')"
  fname="README_$(date +%F_%H%M).md"
  printf "# Informe (%s)\n" "$ts" > "$fname"
  echo "Creado: $fname"
}
# legacy (equivalente directo del archivo subido)
alias mdreport_legacy="echo \"# Informe (\$(date +'%F %T'))\" > README_\$(date +%F_%H%M).md"


# -------------------------
# File hunting
# -------------------------
bigfiles() {
  local target="${1:-.}"
  find "$target" -type f -size +100M -exec ls -lh {} \; 2>/dev/null \
    | awk '{print $9 ": " $5}'
}
# legacy (del archivo subido; sin 2>/dev/null)
alias bigfiles_legacy='find . -type f -size +100M -exec ls -lh {} \; | awk "{ print $9 \": \" $5 }"'


# -------------------------
# Clipboard helpers (del archivo subido)
# Requiere PLATFORM definido (lo tienes en aliases-builtin.zsh)
# -------------------------
if [[ "$PLATFORM" == "macos" ]]; then
  alias copyip='curl -s ifconfig.me | pbcopy'
  alias wheremi='pwd | pbcopy && pwd'
else
  alias copyip='curl -s ifconfig.me | xclip -selection clipboard'
  alias wheremi='pwd | xclip -selection clipboard && pwd'
fi


# -------------------------
# Wordlists helpers
# -------------------------
# El alias del archivo subido usaba $1 dentro de alias (no funciona como esperas en zsh).
# Lo preservo como función (mismo objetivo, ahora sí usable).
gword() {
  local q="${1:-}"
  [[ -z "$q" ]] && { echo "Uso: gword <cadena>"; return 1; }
  grep -i -- "$q" "$WORDLISTS"/*
}
# legacy literal (por si lo tenías memorizado así)
alias gword_legacy='grep -i $1 $WORDLISTS/*'


# -------------------------
# Misc / helpers
# -------------------------
alias err='grep -i --color error'
alias serve='python3 -m http.server 8000'
alias purge_outputs='find . -type d -name output -exec rm -rf {} +; find . -name "*.log" -delete'

setproxy() {
  export http_proxy='http://127.0.0.1:8080'
  export https_proxy='http://127.0.0.1:8080'
}
unsetproxy() {
  unset http_proxy
  unset https_proxy
}
# legacy (del archivo subido)
alias setproxy_legacy="export http_proxy='http://127.0.0.1:8080'; export https_proxy='http://127.0.0.1:8080'"
alias unsetproxy_legacy='unset http_proxy; unset https_proxy'

alias wshk='wireshark &'


# -------------------------
# Containers (wrappers) - Apple container / containerd
# -------------------------
container-shell-persist() {
  container run --interactive --tty --entrypoint=/bin/bash \
    --volume "$(pwd):/mnt" \
    --name "OxETERNAL" \
    --workdir /mnt
}

container-shell-ephemeral() {
  container run --remove --interactive --tty --entrypoint=/bin/bash \
    --volume "$(pwd):/mnt" \
    --name "0xEPHEMERAL" \
    --workdir /mnt
}

alias container-ls='container list'
alias kali-eternal='container-shell-persist kalilinux/kali-rolling:latest'
alias kali-ephemeral='container-shell-ephemeral kalilinux/kali-rolling:latest'

# legacy comentado (del archivo subido; preservado tal cual por historial)
#alias container-ls='container list'
#alias container-shell-persist='container run --interactive --tty --entrypoint=/bin/bash --volume $(pwd):/mnt --name "OxETERNAL" --workdir /mnt'
#alias container-shell-ephemeral='container run --remove --interactive --tty --entrypoint=/bin/bash --volume $(pwd):/mnt --name "0xEPHEMERAL" --workdir /mnt'
#alias kali-eternal='container-shell-persist kalilinux/kali-rolling:latest'
#alias kali-ephemeral='container-shell-ephemeral kalilinux/kali-rolling:latest'
