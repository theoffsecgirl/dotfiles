#!/bin/bash
set -e

USER_HOME="$HOME"
DOTFILES="$USER_HOME/dotfiles/terminal/zsh"
ZSH_CUSTOM="$USER_HOME/.zsh"
P10K_REPO="https://github.com/romkatv/powerlevel10k.git"

echo "Instalando dependencias..."
brew update
brew install zsh git curl unzip fzf lsd bat font-fira-code font-hack

echo "Instalando Powerlevel10k..."
if [ ! -d "$ZSH_CUSTOM/powerlevel10k" ]; then
  git clone --depth=1 "$P10K_REPO" "$ZSH_CUSTOM/powerlevel10k"
fi

# Copiar config .p10k.zsh
cp "$DOTFILES/themes/.p10k.zsh" "$USER_HOME/.p10k.zsh"

# Configurar .zshrc de usuario
USER_ZSHRC="$USER_HOME/.zshrc"
touch "$USER_ZSHRC"

add_source_user() {
  local file="$1"
  local line="[[ -f \"$DOTFILES/$file\" ]] && source \"$DOTFILES/$file\""
  grep -qxF "$line" "$USER_ZSHRC" || echo "$line" >> "$USER_ZSHRC"
}
add_source_user "exports.zsh"
add_source_user "aliases.zsh"
add_source_user "functions.zsh"
add_source_user "prompt.zsh"

# Enlazar .p10k.zsh desde home y theme
P10K_LINE='[[ -f "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"'
grep -qxF "$P10K_LINE" "$USER_ZSHRC" || echo "$P10K_LINE" >> "$USER_ZSHRC"
P10K_THEME_LINE="[[ -f \"$ZSH_CUSTOM/powerlevel10k/powerlevel10k.zsh-theme\" ]] && source \"$ZSH_CUSTOM/powerlevel10k/powerlevel10k.zsh-theme\""
grep -qxF "$P10K_THEME_LINE" "$USER_ZSHRC" || echo "$P10K_THEME_LINE" >> "$USER_ZSHRC"

echo "Cambiando shell por defecto a zsh..."
chsh -s "$(which zsh)"

echo "Instalación completada. Reinicia la terminal o ejecuta: exec zsh"
