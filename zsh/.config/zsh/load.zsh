# Carga modular de configuración Zsh (Mac-first)
# Este fichero se debe sourcear desde ~/.zshrc

# Path base
export PATH="$HOME/.local/bin:$PATH"

# Homebrew (Apple Silicon / Intel)
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# Completion (brew)
if [[ -d "$(brew --prefix 2>/dev/null)/share/zsh/site-functions" ]]; then
  fpath=("$(brew --prefix)/share/zsh/site-functions" $fpath)
fi

# Historial sensato
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_DUPS HIST_REDUCE_BLANKS SHARE_HISTORY INC_APPEND_HISTORY

# Opciones de calidad de vida
setopt AUTO_CD
setopt CORRECT
setopt NO_BEEP

# FZF (si está instalado)
if command -v fzf >/dev/null 2>&1; then
  # fzf keybindings y completion (brew)
  if [[ -f "$(brew --prefix 2>/dev/null)/opt/fzf/shell/key-bindings.zsh" ]]; then
    source "$(brew --prefix)/opt/fzf/shell/key-bindings.zsh"
  fi
  if [[ -f "$(brew --prefix 2>/dev/null)/opt/fzf/shell/completion.zsh" ]]; then
    source "$(brew --prefix)/opt/fzf/shell/completion.zsh"
  fi
fi

# Syntax highlighting + autosuggestions (opcionales)
if [[ -f "$(brew --prefix 2>/dev/null)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
  source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
if [[ -f "$(brew --prefix 2>/dev/null)/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
  source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

# Prompt (starship opcional)
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# -------------------------
# Tu núcleo: shell-utils
# -------------------------
# Ruta del repo dotfiles (resuelve symlink)
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
SHELL_UTILS_DIR="$DOTFILES_DIR/vendor/shell-utils"

# Cargar aliases y funciones
if [[ -f "$SHELL_UTILS_DIR/zsh/aliases-builtin.zsh" ]]; then
  source "$SHELL_UTILS_DIR/zsh/aliases-builtin.zsh"
fi
if [[ -f "$SHELL_UTILS_DIR/zsh/aliases-bugbounty.zsh" ]]; then
  source "$SHELL_UTILS_DIR/zsh/aliases-bugbounty.zsh"
fi
if [[ -f "$SHELL_UTILS_DIR/zsh/aliases-mac-containers.zsh" ]]; then
  source "$SHELL_UTILS_DIR/zsh/aliases-mac-containers.zsh"
fi
if [[ -f "$SHELL_UTILS_DIR/zsh/functions-bugbounty.zsh" ]]; then
  source "$SHELL_UTILS_DIR/zsh/functions-bugbounty.zsh"
fi
if [[ -f "$SHELL_UTILS_DIR/zsh/wrapper-exegol.zsh" ]]; then
  source "$SHELL_UTILS_DIR/zsh/wrapper-exegol.zsh"
fi

# Git aliases (si existe)
if [[ -f "$SHELL_UTILS_DIR/git/git-aliases.conf" ]]; then
  export GIT_ALIASES_FILE="$SHELL_UTILS_DIR/git/git-aliases.conf"
fi

# Seguridad: evita ejecutar por accidente en / (alias rmrf ya existe, pero...)
alias rm='rm -i'

# Local overrides (no se versiona)
if [[ -f "$HOME/.config/zsh/local.zsh" ]]; then
  source "$HOME/.config/zsh/local.zsh"
fi
