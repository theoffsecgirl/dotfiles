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

# 🔒 Protección contra shadowing de binarios críticos
for cmd in scope webmap; do
  if whence -w "$cmd" 2>/dev/null | grep -q "function"; then
    unfunction "$cmd" 2>/dev/null || true
  fi
done

# Homebrew (Apple Silicon / Intel) — sin subshells por arranque
BREW_PREFIX=""
if [[ -d /opt/homebrew ]]; then
  BREW_PREFIX=/opt/homebrew
elif [[ -x /usr/local/bin/brew ]]; then
  BREW_PREFIX=/usr/local
fi
if [[ -n "$BREW_PREFIX" ]]; then
  export HOMEBREW_PREFIX="$BREW_PREFIX"
  export PATH="$BREW_PREFIX/bin:$BREW_PREFIX/sbin:$PATH"
  export MANPATH="$BREW_PREFIX/share/man:${MANPATH:-}"
  export INFOPATH="$BREW_PREFIX/share/info:${INFOPATH:-}"
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
# HISTFILE en .cache para mantener home limpio junto al zcompdump
HISTFILE="$HOME/.cache/zsh/history"
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_DUPS HIST_IGNORE_SPACE HIST_REDUCE_BLANKS APPEND_HISTORY \
       HIST_VERIFY SHARE_HISTORY HIST_EXPIRE_DUPS_FIRST

# Opciones de calidad de vida
setopt AUTO_CD NO_BEEP
unsetopt CORRECT

# FZF
if command -v fzf >/dev/null 2>&1; then
  [[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh
  [[ -f /usr/share/fzf/key-bindings.zsh ]] && source /usr/share/fzf/key-bindings.zsh
  [[ -f /usr/share/fzf/completion.zsh ]] && source /usr/share/fzf/completion.zsh
  [[ -n "$BREW_PREFIX" && -f "$BREW_PREFIX/opt/fzf/shell/key-bindings.zsh" ]] && source "$BREW_PREFIX/opt/fzf/shell/key-bindings.zsh"
  [[ -n "$BREW_PREFIX" && -f "$BREW_PREFIX/opt/fzf/shell/completion.zsh" ]] && source "$BREW_PREFIX/opt/fzf/shell/completion.zsh"
  export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
fi

# Autosuggestions primero
for _plugin in \
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

# Completions dinámicas — añadir entradas en el array para extender
# Formato: "herramienta:comando que genera la completion zsh"
_TOOL_COMPLETIONS=(
  "gh:gh completion -s zsh"
  "docker:docker completion zsh"
  "kubectl:kubectl completion zsh"
  "helm:helm completion zsh"
  "terraform:terraform -install-autocomplete 2>/dev/null; terraform completion zsh"
)
_load_tool_completion() {
  local tool="$1" gencmd="$2"
  local cache="$HOME/.cache/zsh/_${tool}"
  command -v "$tool" >/dev/null 2>&1 || return 0
  if [[ ! -f "$cache" || "$cache" -ot "$(command -v "$tool")" ]]; then
    eval "$gencmd" > "$cache" 2>/dev/null || rm -f "$cache"
  fi
  [[ -f "$cache" ]] && source "$cache"
}
for _entry in "${_TOOL_COMPLETIONS[@]}"; do
  _load_tool_completion "${_entry%%:*}" "${_entry#*:}"
done
unset _entry _TOOL_COMPLETIONS

# Aliases generales de productividad
[[ -f "$HOME/.config/zsh/aliases-general.zsh" ]] && source "$HOME/.config/zsh/aliases-general.zsh"

# Bug bounty workspace
[[ -f "$HOME/.config/zsh/bug-bounty.zsh" ]] && source "$HOME/.config/zsh/bug-bounty.zsh"

# zsh-syntax-highlighting al final para evitar interferencias con widgets/completions
for _plugin in \
  "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" \
  /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
  /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
do
  [[ -f "$_plugin" ]] && source "$_plugin"
done
unset _plugin

# Local overrides (no se versiona)
[[ -f "$HOME/.config/zsh/local.zsh" ]] && source "$HOME/.config/zsh/local.zsh"
