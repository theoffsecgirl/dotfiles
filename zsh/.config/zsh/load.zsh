# Carga modular de configuración Zsh (Mac-first)
# Este fichero se debe sourcear desde ~/.zshrc

# Path base
export PATH="$HOME/.local/bin:$PATH"

# Homebrew (Apple Silicon / Intel) — se cachea para no pagar el coste en cada bloque
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
if [[ -n "$BREW_PREFIX" && -d "$BREW_PREFIX/share/zsh/site-functions" ]]; then
  fpath=("$BREW_PREFIX/share/zsh/site-functions" $fpath)
fi
compinit -u

# Historial sensato
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_DUPS HIST_REDUCE_BLANKS SHARE_HISTORY INC_APPEND_HISTORY

# Opciones de calidad de vida
setopt AUTO_CD CORRECT NO_BEEP

# FZF (si está instalado)
if command -v fzf >/dev/null 2>&1 && [[ -n "$BREW_PREFIX" ]]; then
  [[ -f "$BREW_PREFIX/opt/fzf/shell/key-bindings.zsh" ]] && \
    source "$BREW_PREFIX/opt/fzf/shell/key-bindings.zsh"
  [[ -f "$BREW_PREFIX/opt/fzf/shell/completion.zsh" ]] && \
    source "$BREW_PREFIX/opt/fzf/shell/completion.zsh"
fi

# Syntax highlighting + autosuggestions (opcionales)
[[ -n "$BREW_PREFIX" && -f "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] && \
  source "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

[[ -n "$BREW_PREFIX" && -f "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && \
  source "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# Prompt (starship opcional)
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# -------------------------
# Tu núcleo: shell-utils
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

# Bug bounty workspace aliases y funciones
[[ -f "$HOME/.config/zsh/bug-bounty.zsh" ]] && source "$HOME/.config/zsh/bug-bounty.zsh"

# Git aliases (si existe)
[[ -f "$SHELL_UTILS_DIR/git/git-aliases.conf" ]] && \
  export GIT_ALIASES_FILE="$SHELL_UTILS_DIR/git/git-aliases.conf"

# Local overrides (no se versiona)
[[ -f "$HOME/.config/zsh/local.zsh" ]] && source "$HOME/.config/zsh/local.zsh"
