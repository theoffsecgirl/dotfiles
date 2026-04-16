# Carga modular de configuración Zsh
# Este fichero se debe sourcear desde ~/.zshrc

# PATH unificado y sin duplicados
typeset -U path PATH
path=(
  "$HOME/.local/bin"
  "$HOME/go/bin"
  $path
)
export PATH

# Homebrew (Apple Silicon / Intel) — se cachea para evitar subshells repetidas
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
  BREW_PREFIX="/opt/homebrew"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
  BREW_PREFIX="/usr/local"
else
  BREW_PREFIX=""
fi

# Completion
autoload -Uz compinit
mkdir -p "$HOME/.cache/zsh"
if [[ -n "$BREW_PREFIX" && -d "$BREW_PREFIX/share/zsh/site-functions" ]]; then
  fpath=("$BREW_PREFIX/share/zsh/site-functions" $fpath)
fi
[[ -d /usr/local/share/zsh/site-functions ]] && fpath=(/usr/local/share/zsh/site-functions $fpath)
[[ -d /usr/share/zsh/site-functions ]] && fpath=(/usr/share/zsh/site-functions $fpath)
zcompdump="$HOME/.cache/zsh/zcompdump"
if [[ ! -s "$zcompdump" || ! "${zcompdump}.zwc" -nt "$zcompdump" ]]; then
  compinit -d "$zcompdump" && zcompile "$zcompdump"
else
  compinit -C -d "$zcompdump"
fi

# Historial sensato
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_DUPS HIST_REDUCE_BLANKS SHARE_HISTORY INC_APPEND_HISTORY

# Opciones de calidad de vida
setopt AUTO_CD CORRECT NO_BEEP

# FZF
if command -v fzf >/dev/null 2>&1; then
  [[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh
  [[ -f /usr/share/fzf/key-bindings.zsh ]] && source /usr/share/fzf/key-bindings.zsh
  [[ -f /usr/share/fzf/completion.zsh ]] && source /usr/share/fzf/completion.zsh
  [[ -n "$BREW_PREFIX" && -f "$BREW_PREFIX/opt/fzf/shell/key-bindings.zsh" ]] && source "$BREW_PREFIX/opt/fzf/shell/key-bindings.zsh"
  [[ -n "$BREW_PREFIX" && -f "$BREW_PREFIX/opt/fzf/shell/completion.zsh" ]] && source "$BREW_PREFIX/opt/fzf/shell/completion.zsh"
  export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --preview "bat --color=always {} 2>/dev/null || echo {}" --preview-window=right:50%'
fi

# Syntax highlighting + autosuggestions
for _plugin in \
  "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" \
  /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
  /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
  "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" \
  /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
  /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
do
  [[ -f "$_plugin" ]] && source "$_plugin"
done
unset _plugin

# Prompt
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# -------------------------
# shell-utils
# -------------------------
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
SHELL_UTILS_DIR="$DOTFILES_DIR/vendor/shell-utils"

for _f in \
  "$SHELL_UTILS_DIR/zsh/aliases-builtin.zsh" \
  "$SHELL_UTILS_DIR/zsh/aliases-bugbounty.zsh" \
  "$SHELL_UTILS_DIR/zsh/aliases-mac-containers.zsh" \
  "$SHELL_UTILS_DIR/zsh/functions-bugbounty.zsh" \
  "$SHELL_UTILS_DIR/zsh/wrapper-exegol.zsh"
do
  [[ -f "$_f" ]] && source "$_f"
done
unset _f

# zoxide — navegación inteligente de directorios
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# atuin — historial avanzado con búsqueda semántica
if command -v atuin >/dev/null 2>&1; then
  eval "$(atuin init zsh)"
fi

# Completions dinámicas para herramientas de seguridad
_load_tool_completion() {
  local tool="$1"
  local cache="$HOME/.cache/zsh/_${tool}"
  if command -v "$tool" >/dev/null 2>&1; then
    if [[ ! -f "$cache" || "$cache" -ot "$(command -v "$tool")" ]]; then
      case "$tool" in
        gh)      gh completion -s zsh > "$cache" 2>/dev/null ;;
        docker)  docker completion zsh > "$cache" 2>/dev/null ;;
        kubectl) kubectl completion zsh > "$cache" 2>/dev/null ;;
      esac
    fi
    [[ -f "$cache" ]] && source "$cache"
  fi
}
for _t in gh docker kubectl; do
  _load_tool_completion "$_t"
done
unset _t

# Aliases generales de productividad
[[ -f "$HOME/.config/zsh/aliases-general.zsh" ]] && source "$HOME/.config/zsh/aliases-general.zsh"

# Bug bounty workspace
[[ -f "$HOME/.config/zsh/bug-bounty.zsh" ]] && source "$HOME/.config/zsh/bug-bounty.zsh"

# Local overrides (no se versiona)
[[ -f "$HOME/.config/zsh/local.zsh" ]] && source "$HOME/.config/zsh/local.zsh"
