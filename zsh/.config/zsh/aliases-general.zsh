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
# j/ji eliminados: zoxide ya provee z/zi como nombres nativos

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
if rm --version 2>/dev/null | grep -q GNU; then
  alias rm='rm -I'
else
  alias rm='rm -i'
fi
alias grep='grep --color=auto'
alias df='df -h'
alias du='du -h'
alias duu='du -sh * | sort -rh | head -20'
alias myip='curl -s https://api.ipify.org && echo'
alias localip="ipconfig getifaddr en0 2>/dev/null || ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}'"
alias c='clear'
alias q='exit'
alias path='echo $PATH | tr ":" "\n"'
alias reload='exec zsh'
alias dotfiles='cd ~/.dotfiles'
alias hunting='cd "$HUNTING_HOME"'

# -------------------------
# Tips
# -------------------------
tips() {
  emulate -L zsh
  setopt local_options no_aliases

  local content=""
  local selected=""
  local cmd=""

  _tips_section() {
    content+="\n=== $1 ===\nCOMANDO\tTIPO\tDESCRIPCIÓN\n"
  }

  _tips_add() {
    content+="$1\t$2\t$3\n"
  }

  _tips_cmd() {
    (( $+commands[$1] )) && _tips_add "$1" "comando" "$2"
  }

  _tips_copy() {
    if command -v pbcopy >/dev/null 2>&1; then
      printf '%s' "$1" | pbcopy
    else
      printf '%s' "$1"
    fi
  }

  _tips_section "BUG BOUNTY WORKFLOW"
  _tips_cmd program-init "Inicializar programa multi-dominio"
  _tips_cmd scope-program "Recon multi-dominio en un solo workspace"
  _tips_cmd mktarget "Crear estructura de target"
  _tips_cmd scope "Recon dominio único"
  _tips_cmd webmap "Crawl de URLs"
  _tips_cmd paramhunt-v2 "Extracción de parámetros"

  content="${content#\n}"

  selected="$(printf '%b' "$content" | column -ts $'\t' | fzf --reverse)" || return
  cmd="${selected%% *}"
  [[ -n "$cmd" ]] && _tips_copy "$cmd" && echo "[+] Copiado: $cmd"
}
