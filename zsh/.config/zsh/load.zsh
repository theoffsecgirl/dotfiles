# Carga modular de configuración Zsh (portable Mac/Linux)

export PATH="$HOME/.local/bin:$PATH"

if command -v brew >/dev/null 2>&1; then
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi

  if [[ -d "$(brew --prefix)/share/zsh/site-functions" ]]; then
    fpath=("$(brew --prefix)/share/zsh/site-functions" $fpath)
  fi
fi

HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_DUPS HIST_REDUCE_BLANKS SHARE_HISTORY INC_APPEND_HISTORY

setopt AUTO_CD
setopt CORRECT
setopt NO_BEEP

if command -v fzf >/dev/null 2>&1; then
  if command -v brew >/dev/null 2>&1; then
    if [[ -f "$(brew --prefix)/opt/fzf/shell/key-bindings.zsh" ]]; then
      source "$(brew --prefix)/opt/fzf/shell/key-bindings.zsh"
    fi
    if [[ -f "$(brew --prefix)/opt/fzf/shell/completion.zsh" ]]; then
      source "$(brew --prefix)/opt/fzf/shell/completion.zsh"
    fi
  fi
fi

if command -v brew >/dev/null 2>&1; then
  if [[ -f "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
    source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
  fi
  if [[ -f "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
    source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  fi
fi

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
SHELL_UTILS_DIR="$DOTFILES_DIR/vendor/shell-utils"

[[ -f "$SHELL_UTILS_DIR/zsh/aliases-builtin.zsh" ]] && source "$SHELL_UTILS_DIR/zsh/aliases-builtin.zsh"
[[ -f "$SHELL_UTILS_DIR/zsh/aliases-bugbounty.zsh" ]] && source "$SHELL_UTILS_DIR/zsh/aliases-bugbounty.zsh"
[[ -f "$SHELL_UTILS_DIR/zsh/aliases-mac-containers.zsh" ]] && source "$SHELL_UTILS_DIR/zsh/aliases-mac-containers.zsh"
[[ -f "$SHELL_UTILS_DIR/zsh/functions-bugbounty.zsh" ]] && source "$SHELL_UTILS_DIR/zsh/functions-bugbounty.zsh"
[[ -f "$SHELL_UTILS_DIR/zsh/wrapper-exegol.zsh" ]] && source "$SHELL_UTILS_DIR/zsh/wrapper-exegol.zsh"

[[ -f "$SHELL_UTILS_DIR/git/git-aliases.conf" ]] && export GIT_ALIASES_FILE="$SHELL_UTILS_DIR/git/git-aliases.conf"

alias rm='rm -i'

[[ -f "$HOME/.config/zsh/local.zsh" ]] && source "$HOME/.config/zsh/local.zsh"
