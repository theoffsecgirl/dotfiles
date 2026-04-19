# aliases-general.zsh — aliases de productividad generales
# Cargado automáticamente desde load.zsh

# -------------------------
# Git
# -------------------------
alias gs='git status -sb'
alias gl='git log --oneline --graph --decorate -20'
alias gp='git push'
alias gpl='git pull'
alias gc='git commit -m'
alias gca='git commit --amend --no-edit'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gd='git diff'
alias gds='git diff --staged'
alias grh='git reset --hard HEAD'
alias gst='git stash'
alias gstp='git stash pop'
alias gb='git branch -vv'
alias glog='git log --oneline --graph --all --decorate'

# -------------------------
# Navegación con zoxide
# -------------------------
# Solo si zoxide está disponible
if command -v zoxide >/dev/null 2>&1; then
  alias j='z'
  alias ji='zi'  # modo interactivo con fzf
fi

# -------------------------
# Utilidades generales
# -------------------------
alias ll='ls -lAh'
alias la='ls -A'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias mkdir='mkdir -p'
alias cp='cp -v'
alias mv='mv -v'
alias rm='rm -I'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias df='df -h'
alias du='du -h'
alias duu='du -sh * | sort -rh | head -20'
alias ports='ss -tulanp 2>/dev/null || netstat -tulanp'
alias myip='curl -s https://api.ipify.org && echo'
alias localip="ipconfig getifaddr en0 2>/dev/null || ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}'"
alias c='clear'
alias q='exit'
alias path='echo $PATH | tr ":" "\n"'
alias reload='exec zsh'
alias dotfiles='cd ~/.dotfiles'
alias hunting='cd ~/hunting'

# -------------------------
# Python
# -------------------------
alias py='python3'
alias pip='pip3'
alias pyi='pip3 install'
alias pyv='python3 --version'

# -------------------------
# Docker
# -------------------------
if command -v docker >/dev/null 2>&1; then
  alias dk='docker'
  alias dkps='docker ps'
  alias dkpsa='docker ps -a'
  alias dkimg='docker images'
  alias dkrm='docker rm'
  alias dkrmi='docker rmi'
  alias dkstop='docker stop'
  alias dkexec='docker exec -it'
  alias dklog='docker logs -f'
  alias dkprune='docker system prune -f'
fi

# -------------------------
# Tips — cheatsheet interactivo de aliases y atajos
# -------------------------
tips() {
  local content=""
  content+="=== GIT ===\n"
  content+="gs        git status -sb\n"
  content+="gl        git log oneline graph\n"
  content+="gd        git diff\n"
  content+="gds       git diff --staged\n"
  content+="gc 'msg'  git commit -m\n"
  content+="gca       amend último commit\n"
  content+="gst/gstp  stash / stash pop\n"
  content+="\n"
  content+="=== NAVEGACIÓN ===\n"
  content+="z <dir>   saltar a directorio frecuente (zoxide)\n"
  content+="zi        selector interactivo de directorios\n"
  content+="dotfiles  cd ~/.dotfiles\n"
  content+="hunting   cd ~/hunting\n"
  content+="..  ...   subir 1 o 2 niveles\n"
  content+="\n"
  content+="=== RECON ===\n"
  content+="subenum <domain>    enumera subdominios → guarda en targets/\n"
  content+="probe <urls.txt>    httpx con tech-detect\n"
  content+="recon <domain>      subenum + probe + nota automática\n"
  content+="scope <domain>      filtra subdominios in-scope\n"
  content+="nuc                 nuclei -silent\n"
  content+="nucl <urls.txt>     nuclei contra CVEs → guarda resultado\n"
  content+="\n"
  content+="=== HTTP ===\n"
  content+="h    httpx -silent\n"
  content+="hh   httpx + tech-detect + status-code\n"
  content+="hhh  httpx + tech-detect + title + web-server\n"
  content+="f    ffuf -c -mc all -fc 404\n"
  content+="\n"
  content+="=== DOCKER ===\n"
  content+="dkps    docker ps\n"
  content+="dkexec  docker exec -it\n"
  content+="dklog   docker logs -f\n"
  content+="offsec  entrar al contenedor offsec-toolbox\n"
  content+="\n"
  content+="=== UTILIDADES ===\n"
  content+="ll          ls -lAh\n"
  content+="duu         du ordenado por tamaño\n"
  content+="ports       puertos activos\n"
  content+="myip        IP pública\n"
  content+="localip     IP local\n"
  content+="path        PATH línea por línea\n"
  content+="reload      exec zsh\n"
  content+="note 'txt'  añadir nota rápida de hunting\n"
  content+="notes       ver notas de hoy\n"
  if command -v fzf >/dev/null 2>&1; then
    printf '%b' "$content" | fzf --ansi --no-sort --reverse --header='Alias cheatsheet — ESC para salir'
  else
    printf '%b' "$content" | less
  fi
}
