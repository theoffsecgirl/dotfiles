# --------------------------------------
# ALIAS PRINCIPALES Y UTILIDADES AVANZADAS
# --------------------------------------

# --------------------------------------
# Detección de plataforma (macOS, Linux, otro)
# --------------------------------------
case "$(uname)" in
    Darwin) PLATFORM="macos" ;;
    Linux)  PLATFORM="linux" ;;
    *)      PLATFORM="other" ;;
esac

# --------------------------------------
# Historial de comandos
# --------------------------------------
alias clrhist="echo '' > ~/.zsh_history"
alias rmhist="rm ~/.zsh_history"

# --------------------------------------
# Wordlists por plataforma
# --------------------------------------
if [[ "$PLATFORM" == "linux" && -d "/usr/share/wordlists" ]]; then
    export WORDLISTS="/usr/share/wordlists"
    alias wordlists='cd $WORDLISTS'
    alias lsw='ls -la $WORDLISTS'
    alias fword='find $WORDLISTS -type f -iname "*$1*"'
elif [[ "$PLATFORM" == "macos" ]]; then
    if [[ -d "/opt/homebrew/share/wordlists" ]]; then
        export WORDLISTS="/opt/homebrew/share/wordlists"
    elif [[ -d "$HOME/wordlists" ]]; then
        export WORDLISTS="$HOME/wordlists"
    fi
    [[ -n "$WORDLISTS" ]] && alias wordlists='cd $WORDLISTS'
fi

# --------------------------------------
# Cat mejorado y original
# --------------------------------------
if command -v batcat &> /dev/null; then
    alias cat='batcat --paging=always --decorations=always'
elif command -v bat &> /dev/null; then
    alias cat='bat --paging=always --decorations=always'
fi
if [[ "$PLATFORM" == "macos" ]]; then
    alias rcat='/bin/cat'
else
    alias rcat='/usr/bin/cat'
fi

# --------------------------------------
# Listado de archivos (ls mejorado)
# --------------------------------------
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

# --------------------------------------
# Navegación rápida
# --------------------------------------
alias c='clear'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias docs='cd ~/Documents'
alias desk='cd ~/Desktop'
alias mkdir='mkdir -p'
alias rmrf='rm -rf'
alias mv='mv -i'
alias chmodx='chmod +x'

# --------------------------------------
# Logs del sistema
# --------------------------------------
if [[ "$PLATFORM" == "linux" ]]; then
    alias watchlog='tail -f /var/log/syslog'
    alias logerror='grep -i error /var/log/syslog'
    alias logauth='batcat /var/log/auth.log 2>/dev/null || cat /var/log/auth.log'
    alias logsize='du -sh /var/log/* | sort -h'
    alias viewlog='batcat /var/log/syslog 2>/dev/null || cat /var/log/syslog'
elif [[ "$PLATFORM" == "macos" ]]; then
    alias watchlog='tail -f /var/log/system.log'
    alias logerror='grep -i error /var/log/system.log'
    alias logauth='log show --predicate "eventMessage contains \"authentication\"" --last 1h'
    alias logsize='du -sh /var/log/* | sort -h'
    alias viewlog='log show --last 1h'
fi

# --------------------------------------
# Red y utilidades básicas
# --------------------------------------
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

# --------------------------------------
# Alias para hacking, DevOps y administración
# --------------------------------------
alias ezsh="nvim ~/.zshrc"
alias reloadzsh="source ~/.zshrc && echo '[zsh recargado]'"
alias dalias="nvim ~/dotfiles/stow/zsh/.config/aliases.zsh"
alias dfunctions="nvim ~/dotfiles/stow/zsh/.config/functions.zsh"

alias dotfiles='cd ~/dotfiles'
alias proj='cd ~/proyectos'
alias bounty='cd ~/bugbounty'
alias ctf='cd ~/ctf'

alias gst='git status'
alias gco='git checkout'
alias gaa='git add .'
alias gcm='git commit -m'
alias gpush='git push'
alias gpull='git pull'
alias ghist='git log --oneline --graph --decorate'

alias ffuf='ffuf'
alias nmapl='nmap -sC -sV -p-'
alias nuclei='nuclei -duc'
alias gobuster='gobuster'

alias dps="docker ps"
alias di="docker images"
alias drm="docker rm $(docker ps -aq)"
alias dclean='docker system prune -af --volumes'
alias dstopall='docker stop $(docker ps -aq)'

alias findsh='find . -type f -name "*.sh"'
alias findpy='find . -type f -name "*.py"'
alias findbin='find . -type f -perm -u=x'
alias findcreds='grep -Ri --color "pass|secret|token|credential" .'

if [[ "$PLATFORM" == "macos" ]]; then
    alias copyip='curl -s ifconfig.me | pbcopy'
    alias wheremi='pwd | pbcopy && pwd'
else
    alias copyip='curl -s ifconfig.me | xclip -selection clipboard'
    alias wheremi='pwd | xclip -selection clipboard && pwd'
fi

alias gword='grep -i $1 $WORDLISTS/*'

# --------------------------------------
# Sistema, rendimiento y limpieza
# --------------------------------------
if [[ "$PLATFORM" == "linux" ]]; then
    alias diskspace='df -h --total | grep total'
    alias mem='free -h --si'
else
    alias diskspace='df -h | tail -1'
    alias mem='top -l 1 -s 0 | grep PhysMem'
fi

alias freespace='du -sh * | sort -h'
alias cpuload="uptime | awk '{print \"Carga:\", \$9, \$10, \$11}'"
alias findtxt='find . -type f -name "*.txt"'
alias grepip="grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}'"
alias greppass="grep -i 'password'"
alias untar='tar -xvf'
alias unzipdir='unzip -d ./extracted/'
alias wgetr="wget --continue"

# --------------------------------------
# Exclusivos para macOS
# --------------------------------------
if [[ "$PLATFORM" == "macos" ]]; then
    alias finder='open .'
    alias brewup='brew update && brew upgrade'
    alias showfiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder'
    alias hidefiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder'
    alias flushdns='sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder'
    alias mfconsole='/opt/metasploit-framework/bin/msfconsole'
fi

# --------------------------------------
# Alias de hacking, bug bounty y CTF
# --------------------------------------
alias err='grep -i --color error'
alias creds="grep -Ei --color 'pass|secret|token|key'"
alias mdreport="echo \"# Informe ($(date +'%F %T'))\" > README_$(date +%F_%H%M).md"
alias serve="python3 -m http.server 8000"
alias bigfiles='find . -type f -size +100M -exec ls -lh {} \; | awk "{ print \$9 \": \" \$5 }"'
alias purge_outputs='find . -type d -name output -exec rm -rf {} +; find . -name "*.log" -delete'
alias setproxy="export http_proxy='http://127.0.0.1:8080'; export https_proxy='http://127.0.0.1:8080'"
alias unsetproxy="unset http_proxy; unset https_proxy"
alias findpcap='find . -type f -name "*.pcap"'
alias wshk="wireshark &"
