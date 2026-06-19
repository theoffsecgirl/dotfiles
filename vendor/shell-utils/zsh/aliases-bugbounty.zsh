# =========================
# Bug Bounty helpers (vendor/shell-utils)
# =========================
# Cargado desde load.zsh antes de aliases-general.zsh y bug-bounty.zsh.
# Regla: este archivo NO debe definir aliases que ya existen en
# aliases-general.zsh o bug-bounty.zsh (evita conflictos de orden).


# -------------------------
# Mostrar aliases — introspección rápida
# -------------------------
showaliases() {
  alias | sed 's/^alias //' | column -t -s'=' | less
}

# aliases() definida en functions-bugbounty.zsh (se carga después y gana por orden).


# -------------------------
# Navegación de trabajo
# -------------------------
# proj/bounty/ctf: shortcuts para directorios de proyectos
# Si usas $HUNTING_HOME para bounty, 'bounty' se puede ignorar,
# pero se mantiene como fallback para quien no tenga $HUNTING_HOME definido.
alias proj='cd ~/proyectos'
alias bounty='cd ~/bugbounty'
alias ctf='cd ~/ctf'


# -------------------------
# Edición rápida de configuración
# -------------------------
# ezsh abre el directorio zsh de los dotfiles, no el .zshrc (que está casi vacío)
alias ezsh='nvim "${DOTFILES_DIR:-$HOME/.dotfiles}/zsh/.config/zsh/"'
alias dalias='nvim "${DOTFILES_DIR:-$HOME/.dotfiles}/vendor/shell-utils/zsh/aliases-bugbounty.zsh"'
alias dfunctions='nvim "${DOTFILES_DIR:-$HOME/.dotfiles}/vendor/shell-utils/zsh/functions-bugbounty.zsh"'

reloadzsh() {
  exec zsh
}


# -------------------------
# Hacking básico
# -------------------------
# nuclei: sin -duc (obsoleto desde v3, el check es asíncrono y no bloquea)
alias nmapl='nmap -sC -sV -p-'


# -------------------------
# Docker helpers
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


# -------------------------
# Búsqueda de archivos
# -------------------------
alias findsh='find . -type f -name "*.sh"'
alias findpy='find . -type f -name "*.py"'
alias findbin='find . -type f -perm -u=x'
alias findpcap='find . -type f -name "*.pcap"'


# -------------------------
# Credenciales / secretos en ficheros locales
# -------------------------
findcreds() {
  local target="${1:-.}"
  grep -Ri --color=always -E "pass|secret|token|credential" "$target"
}

creds() {
  local target="${1:-.}"
  grep -Ri --color=always -E "pass|secret|token|key" "$target"
}


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


# -------------------------
# File hunting
# -------------------------
bigfiles() {
  local target="${1:-.}"
  find "$target" -type f -size +100M -exec ls -lh {} \; 2>/dev/null \
    | awk '{print $9 ": " $5}'
}


# -------------------------
# Clipboard helpers
# -------------------------
if [[ "${PLATFORM:-}" == "macos" ]]; then
  alias copyip='curl -s --max-time 5 ifconfig.me | pbcopy'
  alias wheremi='pwd | pbcopy && pwd'
else
  alias copyip='curl -s --max-time 5 ifconfig.me | xclip -selection clipboard'
  alias wheremi='pwd | xclip -selection clipboard && pwd'
fi


# -------------------------
# Wordlists helpers
# -------------------------
gword() {
  local q="${1:-}"
  [[ -z "$q" ]] && { echo "Uso: gword <cadena>"; return 1; }
  [[ -z "${WORDLISTS:-}" ]] && { echo "[!] \$WORDLISTS no definida"; return 1; }
  grep -i -- "$q" "$WORDLISTS"/*
}


# -------------------------
# Proxy Burp Suite
# -------------------------
# setproxy/unsetproxy: activa/desactiva proxy para herramientas CLI
# no_proxy evita que tráfico a localhost pase por Burp (rompería health checks)
setproxy() {
  export http_proxy='http://127.0.0.1:8080'
  export https_proxy='http://127.0.0.1:8080'
  export no_proxy='localhost,127.0.0.1,::1'
  echo "[+] Proxy activo → 127.0.0.1:8080 (no_proxy: localhost,127.0.0.1)"
}

unsetproxy() {
  unset http_proxy https_proxy no_proxy
  echo "[-] Proxy desactivado"
}


# -------------------------
# Misc / helpers
# -------------------------
alias err='grep -i --color error'
alias serve='python3 -m http.server 8000'

# purge_outputs: limpia directorios de output y logs del workspace actual
# Úsalo con cuidado — no opera fuera del directorio actual
purge_outputs() {
  echo "[!] Borrando directorios 'output' y ficheros .log bajo $(pwd)"
  read -r -q "reply?¿Continuar? [s/N] " || { echo; return 1; }
  echo
  find . -type d -name output -exec rm -rf {} + 2>/dev/null || true
  find . -name "*.log" -delete 2>/dev/null || true
  echo "[+] Limpieza completada"
}

alias wshk='wireshark &'
