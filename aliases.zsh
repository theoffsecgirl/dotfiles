# ─── HISTORIAL Y LIMPIEZA ──────────────────────────────────────────────────────
alias clrhist="echo '' > ~/.zsh_history"
alias rmhist="rm ~/.zsh_history"

# ─── WORDLISTS ──────────────────────────────────────────────────────────────────
alias wordlists='cd $WORDLISTS'
alias lsw='lsd -la $WORDLISTS'
alias fword='find $WORDLISTS -type f -iname "*$1*"'

# ─── CAT Y LS VISUALES ───
if command -v batcat &> /dev/null; then
    alias cat='batcat --paging=always --decorations=always'
elif command -v bat &> /dev/null; then
    alias cat='bat --paging=always --decorations=always'
fi
alias rcat='/usr/bin/cat'

if command -v lsd &> /dev/null; then
    alias ll='lsd -la --group-dirs=first'
    alias l='lsd'
    alias cl='clear && lsd'
else
    alias ll='ls -alh --group-directories-first'
    alias l='ls'
    alias cl='clear && ls'
fi
alias c='clear'

# ─── NAVEGACIÓN RÁPIDA ──────────────────────────────────────────────────────────
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias docs='cd ~/Documents'
alias desk='cd ~/Desktop'

# ─── MANEJO DE ARCHIVOS ─────────────────────────────────────────────────────────
alias mkdir='mkdir -p'
alias rmrf='rm -rf'
alias mv='mv -i'
alias chmodx='chmod +x'

# ─── LOGS Y MONITOREO ───────────────────────────────────────────────────────────
alias watchlog='tail -f /var/log/syslog'
alias logerror='grep -i error /var/log/syslog'
alias logauth='batcat /var/log/auth.log'
alias logsize='du -sh /var/log/* | sort -h'
alias viewlog='batcat /var/log/syslog'

# ─── REDES Y CONECTIVIDAD ───────────────────────────────────────────────────────
alias sniff='tcpdump -i eth0 -nn -s0 -w capture.pcap'
alias ifconfig='ip a'
alias myip='curl ifconfig.me'
alias pingfast='ping -c 5 -i 0.2 google.com'
alias dnslookup='dig +short'
alias ports='ss -tulanp'
alias httproot='python3 -m http.server 8080'

# ─── SISTEMA Y RECURSOS ─────────────────────────────────────────────────────────
update_system() {
    if command -v apt &> /dev/null; then
        sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo apt autoclean -y
    elif command -v dnf &> /dev/null; then
        sudo dnf upgrade -y && sudo dnf autoremove -y
    elif command -v pacman &> /dev/null; then
        sudo pacman -Syu --noconfirm
    else
        echo "\033[1;91m[✘] Gestor de paquetes no soportado para el alias 'update'.\033[0m"
        return 1
    fi
}
alias update='update_system'alias diskspace='df -h --total | grep total'
alias freespace='du -sh * | sort -h'
alias mem='free -h --si'
alias cpuload="uptime | awk '{print \"Carga:\", \$9, \$10, \$11}'"

# ─── BUSQUEDAS ÚTILES ───────────────────────────────────────────────────────────
alias findtxt='find . -type f -name "*.txt"'
alias grepip="grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}'"
alias greppass="grep -i 'password'"

# ─── DESCARGAS Y COMPRESIÓN ─────────────────────────────────────────────────────
alias untar='tar -xvf'
alias unzipdir='unzip -d ./extracted/'
alias wgetr="wget --continue"

# ─── DOCKER ─────────────────────────────────────────────────────────────────────
alias dps="docker ps"
alias di="docker images"
alias drm="docker rm \$(docker ps -aq)"
