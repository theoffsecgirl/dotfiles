# =========================
# Aliases builtin (cross-platform)
# =========================
# Cargado desde load.zsh como primer archivo de vendor.
# Solo define lo que NO está en aliases-general.zsh ni bug-bounty.zsh.


# -------------------------
# Detección de plataforma
# -------------------------
case "$(uname)" in
  Darwin) export PLATFORM="macos" ;;
  Linux)  export PLATFORM="linux" ;;
  *)      export PLATFORM="other" ;;
esac


# -------------------------
# Historial
# -------------------------
# clrhist vacía sin borrar el fichero (safer que rmhist)
alias clrhist=": > ~/.cache/zsh/history"
# rmhist para borrado completo — con confirmación
rmhist() {
  echo "[!] Esto borrará permanentemente ~/.cache/zsh/history"
  read -r -q "reply?¿Continuar? [s/N] " || { echo; return 1; }
  echo
  rm -f "$HOME/.cache/zsh/history"
  echo "[+] Historial eliminado"
}


# -------------------------
# Wordlists por plataforma
# -------------------------
if [[ "$PLATFORM" == "linux" && -d "/usr/share/wordlists" ]]; then
  export WORDLISTS="/usr/share/wordlists"
elif [[ "$PLATFORM" == "macos" ]]; then
  if [[ -d "/opt/homebrew/share/wordlists" ]]; then
    export WORDLISTS="/opt/homebrew/share/wordlists"
  elif [[ -d "$HOME/wordlists" ]]; then
    export WORDLISTS="$HOME/wordlists"
  fi
fi

if [[ -n "${WORDLISTS:-}" ]]; then
  alias wordlists='cd "$WORDLISTS"'
  alias lsw='ls -la "$WORDLISTS"'
  fword() { find "$WORDLISTS" -type f -iname "*${1:?Uso: fword <patrón>}*"; }
fi


# -------------------------
# Listado (ls mejorado)
# -------------------------
if command -v lsd &>/dev/null; then
  alias l='lsd'
  alias cl='clear && lsd'
elif command -v eza &>/dev/null; then
  alias l='eza'
  alias cl='clear && eza'
else
  if [[ "$PLATFORM" == "linux" ]]; then
    alias l='ls --color=auto'
    alias cl='clear && ls --color=auto'
  else
    alias l='ls -G'
    alias cl='clear && ls -G'
  fi
fi
# ll y la los gestiona aliases-general.zsh (detecta eza/lsd también)


# -------------------------
# Operaciones de archivo (safe)
# -------------------------
# rm y mv los gestiona aliases-general.zsh — NO redefinir aquí.
alias chmodx='chmod +x'

# rmrf: eliminado como alias directo — demasiado peligroso sin confirmación.
# Si necesitas rm -rf, escríbelo explícitamente.


# -------------------------
# Disk / memory
# -------------------------
alias diskspace='df -h'

if command -v free >/dev/null 2>&1; then
  alias mem='free -h --si'
else
  alias mem='top -l 1 -s 0 | grep PhysMem'
fi

freespace() { du -sh -- * 2>/dev/null | sort -h; }
cpuload()   { uptime | awk '{print "Carga:", $(NF-2), $(NF-1), $NF}'; }


# -------------------------
# Búsqueda
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
# cat / bat con fallback
# -------------------------
# realcat/rcat: acceso al cat real sin alias (útil en scripts)
realcat() { command cat "$@"; }
alias rcat='realcat'
# alias cat='bat...' lo gestiona aliases-general.zsh


# -------------------------
# Logs del sistema
# -------------------------
if [[ "$PLATFORM" == "linux" ]]; then
  alias watchlog='tail -f /var/log/syslog'
  alias logerror='grep -i error /var/log/syslog'
  alias logauth='cat /var/log/auth.log'
  alias logsize='du -sh /var/log/* | sort -h'
  alias viewlog='cat /var/log/syslog'
elif [[ "$PLATFORM" == "macos" ]]; then
  alias watchlog='tail -f /var/log/system.log'
  alias logerror='grep -i error /var/log/system.log'
  alias logauth='log show --predicate "eventMessage CONTAINS \"authentication\"" --last 1h'
  alias logsize='du -sh /var/log/* | sort -h'
  alias viewlog='log show --last 1h'
fi


# -------------------------
# Red
# -------------------------
if [[ "$PLATFORM" == "linux" ]]; then
  alias sniff='tcpdump -i eth0 -nn -s0 -w capture.pcap'
  alias ifconfig='ip a'
elif [[ "$PLATFORM" == "macos" ]]; then
  alias sniff='sudo tcpdump -i en0 -nn -s0 -w capture.pcap'
fi

# myip: eliminado — aliases-general.zsh define myip() con fallback a 3 servicios.
# Aquí solo se define lo que aliases-general.zsh NO cubre.
alias pingfast='ping -c 5 -i 0.2 google.com'
alias dnslookup='dig +short'

if [[ "$PLATFORM" == "linux" ]]; then
  alias ports='ss -tulanp'
else
  alias ports='netstat -anv'
fi

alias httproot='python3 -m http.server 8080'


# -------------------------
# macOS exclusivos
# -------------------------
if [[ "$PLATFORM" == "macos" ]]; then
  alias finder='open .'
  alias brewup='brew update && brew upgrade && brew cleanup'
  alias showfiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder'
  alias hidefiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder'
  alias flushdns='sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder'
  alias mfconsole='/opt/metasploit-framework/bin/msfconsole'
fi
