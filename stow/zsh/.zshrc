# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

#!/usr/bin/env zsh

# Detectar plataforma
case "$(uname)" in
    Darwin) PLATFORM="macos" ;;
    Linux)  PLATFORM="linux" ;;
    *)      PLATFORM="other" ;;
esac

# Cargar configuración modular
[[ -f "$HOME/.config/zsh/exports.zsh" ]] && source "$HOME/.config/zsh/exports.zsh"
[[ -f "$HOME/.config/zsh/aliases.zsh" ]] && source "$HOME/.config/zsh/aliases.zsh"
[[ -f "$HOME/.config/zsh/functions.zsh" ]] && source "$HOME/.config/zsh/functions.zsh"

# Powerlevel10k prompt
[[ -f "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"
[[ -f "$HOME/.zsh/powerlevel10k/powerlevel10k.zsh-theme" ]] && source "$HOME/.zsh/powerlevel10k/powerlevel10k.zsh-theme"

# Starship prompt DESACTIVADO
# command -v starship >/dev/null && eval "$(starship init zsh)"
# eval "$(starship init zsh)"

# Editor por defecto
if command -v nvim >/dev/null 2>&1; then
    export EDITOR="nvim"
    export VISUAL="nvim"
fi

# Plugins de Zsh
source ~/.zsh-alias-tips/alias-tips.plugin.zsh
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Docker CLI completions
fpath=(/Users/theoffsecgirl/.docker/completions $fpath)
autoload -Uz compinit
compinit
