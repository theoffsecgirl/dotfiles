# =========================
# Aliases builtin (cross-platform)
# =========================

# Detección de plataforma
case "$(uname)" in
  Darwin) export PLATFORM="macos" ;;
  Linux)  export PLATFORM="linux" ;;
  *)      export PLATFORM="other" ;;
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
  alias ll='lsd -la --group-dirs=first'
  alias l='lsd'
  alias cl='clear && lsd'
elif command -v eza &>/dev/null; then
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
alias mkdir='mkdir -p'


# -------------------------
# Operaciones destructivas (safe)
# -------------------------
alias rm='rm -i'
alias rmrf='rm -rf'
alias mv='mv -i'
alias chmodx='chmod +x'


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
realcat() { command cat "$@"; }
alias rcat='realcat'

if command -v bat >/dev/null 2>&1; then
  alias cat='bat --paging=never --style=plain'
elif command -v batcat >/dev/null 2>&1; then
  alias cat='batcat --paging=never --style=plain'
else
  alias cat='realcat'
fi


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

alias myip='curl -s ifconfig.me'
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
  alias brewup='brew update && brew upgrade'
  alias showfiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder'
  alias hidefiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder'
  alias flushdns='sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder'
  alias mfconsole='/opt/metasploit-framework/bin/msfconsole'
fi
