# =========================
# Bug Bounty helpers
# =========================

# -------------------------
# Mostrar aliases
# -------------------------
showaliases() {
  alias | sed 's/^alias //' | column -t -s'=' | less
}


# -------------------------
# Navegación de trabajo
# -------------------------
alias proj='cd ~/proyectos'
alias bounty='cd ~/bugbounty'
alias ctf='cd ~/ctf'


# -------------------------
# Edición rápida de configuración
# -------------------------
alias ezsh='nvim ~/.zshrc'

reloadzsh() {
  source ~/.zshrc && echo '[zsh recargado]'
}

alias dalias='nvim ${DOTFILES_DIR:-~/.dotfiles}/vendor/shell-utils/zsh/aliases-bugbounty.zsh'
alias dfunctions='nvim ${DOTFILES_DIR:-~/.dotfiles}/vendor/shell-utils/zsh/functions-bugbounty.zsh'


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
alias nmapl='nmap -sC -sV -p-'
alias nuclei='nuclei -duc'


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
gword() {
  local q="${1:-}"
  [[ -z "$q" ]] && { echo "Uso: gword <cadena>"; return 1; }
  [[ -z "${WORDLISTS:-}" ]] && { echo "[!] \$WORDLISTS no definida"; return 1; }
  grep -i -- "$q" "$WORDLISTS"/*
}


# -------------------------
# Fuzzing — requiere $WORDLISTS
# -------------------------
ffufdirs() {
  [[ -z "${WORDLISTS:-}" ]] && { echo "[!] \$WORDLISTS no definida"; return 1; }
  local wordlist="$WORDLISTS/fuzz4bounty/fuzz4bounty/dirsearch.txt"
  [[ ! -f "$wordlist" ]] && { echo "[!] Wordlist no encontrada: $wordlist"; return 1; }
  ffuf -u "https://${1:?Uso: ffufdirs <dominio>}/FUZZ" \
       -w "$wordlist" \
       -of md -o "ffuf_DIRS_$(date +%F_%H%M).md"
}

ffufparams() {
  [[ -z "${WORDLISTS:-}" ]] && { echo "[!] \$WORDLISTS no definida"; return 1; }
  local wordlist="$WORDLISTS/fuzz4bounty/discovery/parameter.txt"
  [[ ! -f "$wordlist" ]] && { echo "[!] Wordlist no encontrada: $wordlist"; return 1; }
  ffuf -u "https://${1:?Uso: ffufparams <dominio>}/page.php?FUZZ=1" \
       -w "$wordlist" \
       -of md -o "ffuf_PARAMS_$(date +%F_%H%M).md"
}


# -------------------------
# Misc / helpers
# -------------------------
alias err='grep -i --color error'
alias serve='python3 -m http.server 8000'
alias purge_outputs='find . -type d -name output -exec rm -rf {} +; find . -name "*.log" -delete'

setproxy() {
  export http_proxy='http://127.0.0.1:8080'
  export https_proxy='http://127.0.0.1:8080'
  echo "[+] Proxy activo → 127.0.0.1:8080"
}
unsetproxy() {
  unset http_proxy https_proxy
  echo "[-] Proxy desactivado"
}

alias wshk='wireshark &'
