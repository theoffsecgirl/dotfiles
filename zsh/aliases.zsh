# ─── HISTORIAL Y LIMPIEZA ──────────────────────────────────────────────────────
alias clrhist="echo '' > ~/.zsh_history"
alias rmhist="rm ~/.zsh_history"

# ─── WORDLISTS ──────────────────────────────────────────────────────────────────
alias wordlists='cd $WORDLISTS'
alias lsw='lsd -la $WORDLISTS'
alias fword='find $WORDLISTS -type f -iname "*$1*"'

# ─── CAT Y LS VISUALES ──────────────────────────────────────────────────────────
alias cat='batcat --paging=always --decorations=always'
alias rcat='/usr/bin/cat'
alias ll='lsd -la --group-dirs=first'
alias l='lsd'
alias cl='clear && lsd'
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
alias update='sudo apt update && sudo apt upgrade -y && sudo apt autoremove && sudo apt autoclean'
alias diskspace='df -h --total | grep total'
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
