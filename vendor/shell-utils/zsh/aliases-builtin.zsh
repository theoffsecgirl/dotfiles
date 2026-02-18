# =========================
# Aliases builtin (cross-platform) — UNIFICADO
# Fuente A: /mnt/data/aliases-builtin.zsh (antiguo)
# Fuente B: contenido pegado en el chat (nuevo)
# Objetivo: no perder nada; preferir funciones robustas; conservar legacy.
# =========================

# -------------------------
# Detección de plataforma (macOS / Linux / other)
# -------------------------
case "$(uname)" in
  Darwin) PLATFORM="macos" ;;
  Linux)  PLATFORM="linux" ;;
  *)      PLATFORM="other" ;;
esac


# -------------------------
# Historial
# -------------------------
alias clrhist=": > ~/.zsh_history"
alias rmhist="rm ~/.zsh_history"


# -------------------------
# Wordlists por plataforma
# -------------------------
if [[ "$PLATFORM" == "linux" && -d "/usr/share/wordlists" ]]; then
  export WORDLISTS="/usr/share/wordlists"
  alias wordlists='cd "$WORDLISTS"'
  alias lsw='ls -la "$WORDLISTS"'
  fword() { find "$WORDLISTS" -type f -iname "*$1*"; }
elif [[ "$PLATFORM" == "macos" ]]; then
  if [[ -d "/opt/homebrew/share/wordlists" ]]; then
    export WORDLISTS="/opt/homebrew/share/wordlists"
  elif [[ -d "$HOME/wordlists" ]]; then
    export WORDLISTS="$HOME/wordlists"
  fi
  [[ -n "${WORDLISTS:-}" ]] && alias wordlists='cd "$WORDLISTS"'
fi


# -------------------------
# Listado de archivos (ls mejorado) — del archivo antiguo
# -------------------------
if command -v lsd &> /dev/null; then
  alias ll='lsd -la --group-dirs=first'
  alias l='lsd'
  alias cl='clear && lsd'
elif command -v eza &> /dev/null; then
  alias ll='eza -la --group-directories-first'
  alias l='eza'
  alias cl='clear && eza'
else
  if [[ "$PLATFORM" == "linux" ]]; then
    alias ll='ls -alh --group-directories-first --color=auto'
    alias l='ls --color=auto'
    alias cl='clear && ls --color=auto'
  else
    alias ll='ls -alh'
    alias l='ls -G'
    alias cl='clear && ls -G'
  fi
fi


# -------------------------
# Navegación rápida
# -------------------------
alias c='clear'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias docs='cd ~/Documents'
alias desk='cd ~/Desktop'

# "mkdir -p" (ya venía en ambos; lo dejamos)
alias mkdir='mkdir -p'


# -------------------------
# Safety / operaciones destructivas
# -------------------------
# Nuevo: rm interactivo
alias rm='rm -i'

# Antiguo (se conserva)
alias rmrf='rm -rf'
alias mv='mv -i'
alias chmodx='chmod +x'


# -------------------------
# Disk / memory
# -------------------------
# Nuevo: diskspace por disponibilidad (más portable)
if command -v df >/dev/null 2>&1; then
  alias diskspace='df -h'
fi

# Antiguo: diskspace por plataforma (más “opinión”); lo dejamos como legacy
if [[ "$PLATFORM" == "linux" ]]; then
  alias diskspace_legacy='df -h --total | grep total'
else
  alias diskspace_legacy='df -h | tail -1'
fi

# mem (nuevo: free si existe, si no macOS top)
if command -v free >/dev/null 2>&1; then
  alias mem='free -h --si'
else
  alias mem='top -l 1 -s 0 | grep PhysMem'
fi
# Antiguo “mem” por plataforma (equivalente) como legacy
if [[ "$PLATFORM" == "linux" ]]; then
  alias mem_legacy='free -h --si'
else
  alias mem_legacy='top -l 1 -s 0 | grep PhysMem'
fi


# -------------------------
# Espacio usado por carpetas / CPU load
# -------------------------
# Nuevo: funciones (mejor que alias)
freespace() {
  du -sh -- * 2>/dev/null | sort -h
}

cpuload() {
  uptime | awk '{print "Carga:", $(NF-2), $(NF-1), $NF}'
}

# Antiguo: versiones alias (se conservan como legacy)
alias freespace_legacy='du -sh * | sort -h'
alias cpuload_legacy='uptime | awk '\''{print "Carga:", $(NF-2), $(NF-1), $NF}'\'''


# -------------------------
# Files / search
# -------------------------
alias findtxt='find . -type f -name "*.txt"'
alias grepip="grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}'"
alias greppass="grep -i 'password'"


# -------------------------
# Archives
# -------------------------
alias untar='tar -xvf'
alias unzipdir='unzip -d ./extracted/'
alias wgetr='wget --continue'


# -------------------------
# cat / realcat / rcat (bat + fallback)
# -------------------------
# Nuevo: realcat + rcat como función/alias sólido
realcat() { command cat "$@"; }
alias rcat='realcat'

# Antiguo: rcat apuntando a binario fijo (lo dejamos como legacy)
if [[ "$PLATFORM" == "macos" ]]; then
  alias rcat_bin_legacy='/bin/cat'
else
  alias rcat_bin_legacy='/usr/bin/cat'
fi

# Nuevo: cat “bat” sin paginación y estilo plano (más usable en terminal)
if command -v bat >/dev/null 2>&1; then
  alias cat='bat --paging=never --style=plain'
elif command -v batcat >/dev/null 2>&1; then
  alias cat='batcat --paging=never --style=plain'
else
  alias cat='realcat'
fi

# Antiguo: cat con paginación/decorations (se conserva como legacy)
if command -v batcat &> /dev/null; then
  alias bat_legacy='batcat'
  alias cat_pager_legacy='batcat --paging=always --decorations=always'
elif command -v bat &> /dev/null; then
  alias cat_pager_legacy='bat --paging=always --decorations=always'
fi


# -------------------------
# Logs del sistema (antiguo)
# -------------------------
if [[ "$PLATFORM" == "linux" ]]; then
  alias watchlog='tail -f /var/log/syslog'
  alias logerror='grep -i error /var/log/syslog'
  alias logauth='batcat /var/log/auth.log 2>/dev/null || cat /var/log/auth.log'
  alias logsize='du -sh /var/log/* | sort -h'
  alias viewlog='batcat /var/log/syslog 2>/dev/null || cat /var/log/syslog'
elif [[ "$PLATFORM" == "macos" ]]; then
  alias watchlog='tail -f /var/log/system.log'
  alias logerror='grep -i error /var/log/system.log'
  alias logauth='log show --predicate "eventMessage CONTAINS \"authentication\"" --last 1h'
  alias logsize='du -sh /var/log/* | sort -h'
  alias viewlog='log show --last 1h'
fi


# -------------------------
# Red y utilidades básicas
# -------------------------
if [[ "$PLATFORM" == "linux" ]]; then
  alias sniff='tcpdump -i eth0 -nn -s0 -w capture.pcap'
  alias ifconfig='ip a'
elif [[ "$PLATFORM" == "macos" ]]; then
  alias sniff='sudo tcpdump -i en0 -nn -s0 -w capture.pcap'
fi

alias myip='curl ifconfig.me'
alias pingfast='ping -c 5 -i 0.2 google.com'
alias dnslookup='dig +short'

if [[ "$PLATFORM" == "linux" ]]; then
  alias ports='ss -tulanp'
else
  alias ports='netstat -anv'
fi

alias httproot='python3 -m http.server 8080'


# -------------------------
# macOS exclusivos (antiguo)
# -------------------------
if [[ "$PLATFORM" == "macos" ]]; then
  alias finder='open .'
  alias brewup='brew update && brew upgrade'
  alias showfiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder'
  alias hidefiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder'
  alias flushdns='sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder'
  alias mfconsole='/opt/metasploit-framework/bin/msfconsole'
fi


# ---------------------------------
# Reintegrado desde legacy (.old) — del nuevo (se mantiene)
# ---------------------------------
# (ya estaban arriba clrhist/rmhist/c/docs/desk/mkdir/mv/chmodx/myip/pingfast/dnslookup/httproot)
