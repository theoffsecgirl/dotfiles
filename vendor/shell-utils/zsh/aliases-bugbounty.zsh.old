# Alias de hacking, bug bounty, DevOps y búsqueda avanzada

alias showaliases='alias | sed "s/alias //" | column -t -s"=" | less'

# Navegación de trabajo
alias proj='cd ~/proyectos'
alias bounty='cd ~/bugbounty'
alias ctf='cd ~/ctf'
alias shellutils='cd ~/shell-utils'

# Edición rápida de configuración
alias ezsh="nvim ~/.zshrc"
alias reloadzsh="source ~/.zshrc && echo '[zsh recargado]'"
alias dalias="nvim ~/shell-utils/zsh/aliases-bugbounty.zsh"
alias dfunctions="nvim ~/shell-utils/zsh/functions-bugbounty.zsh"

# Git
alias gst='git status'
alias gco='git checkout'
alias gaa='git add .'
alias gcm='git commit -m'
alias gpush='git push'
alias gpull='git pull'
alias ghist='git log --oneline --graph --decorate'

# Hacking básico
alias ffuf='ffuf'
alias nmapl='nmap -sC -sV -p-'
alias nuclei='nuclei -duc'
alias gobuster='gobuster'

# Docker
alias dps='docker ps'
alias di='docker images'
alias drm='docker rm $(docker ps -aq)'
alias dclean='docker system prune -af --volumes'
alias dstopall='docker stop $(docker ps -aq)'

# Búsqueda de archivos y credenciales
alias findsh='find . -type f -name "*.sh"'
alias findpy='find . -type f -name "*.py"'
alias findbin='find . -type f -perm -u=x'
alias findcreds='grep -Ri --color "pass|secret|token|credential" .'

# Clipboard helpers
if [[ "$PLATFORM" == "macos" ]]; then
    alias copyip='curl -s ifconfig.me | pbcopy'
    alias wheremi='pwd | pbcopy && pwd'
else
    alias copyip='curl -s ifconfig.me | xclip -selection clipboard'
    alias wheremi='pwd | xclip -selection clipboard && pwd'
fi

alias gword='grep -i $1 $WORDLISTS/*'

# Hacking, bug bounty y CTF
alias err='grep -i --color error'
alias creds='grep -Ei --color "pass|secret|token|key"'
alias mdreport="echo \"# Informe ($(date +'%F %T'))\" > README_$(date +%F_%H%M).md"
alias serve='python3 -m http.server 8000'
alias bigfiles='find . -type f -size +100M -exec ls -lh {} \; | awk "{ print $9 \": \" $5 }"'
alias purge_outputs='find . -type d -name output -exec rm -rf {} +; find . -name "*.log" -delete'
alias setproxy="export http_proxy='http://127.0.0.1:8080'; export https_proxy='http://127.0.0.1:8080'"
alias unsetproxy='unset http_proxy; unset https_proxy'
alias findpcap='find . -type f -name "*.pcap"'
alias wshk='wireshark &'


# Container MacOS
alias container-ls='container list'
alias container-shell-persist='container run --interactive --tty --entrypoint=/bin/bash --volume $(pwd):/mnt --name "OxETERNAL" --workdir /mnt'
alias container-shell-ephemeral='container run --remove --interactive --tty --entrypoint=/bin/bash --volume $(pwd):/mnt --name "0xEPHEMERAL" --workdir /mnt'
alias kali-eternal='container-shell-persist kalilinux/kali-roling:latest'
alias kali-ephemeral='container-shell-ephemeral kalilinux/kali-rolling:latest'
