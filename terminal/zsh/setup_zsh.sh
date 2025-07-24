#!/bin/bash

set -e

USER_HOME="$HOME"
ROOT_HOME="/root"
DOTFILES="$USER_HOME/dotfiles/terminal/zsh"
ZSH_CUSTOM="$USER_HOME/.zsh"
ROOT_ZSH_CUSTOM="$ROOT_HOME/.zsh"
P10K_REPO="https://github.com/romkatv/powerlevel10k.git"

# Colores
OK="\033[1;92m[OK]\033[0m"
INFO="\033[1;94m[*]\033[0m"
WARN="\033[1;93m[!]\033[0m"
ERR="\033[1;91m[✘]\033[0m"

echo -e "$INFO Instalando dependencias..."
sudo apt update && sudo apt install -y \
  zsh curl git unzip xclip fzf lsd bat \
  fonts-powerline fonts-firacode fonts-hack-ttf locales

echo -e "$INFO Instalando Powerlevel10k..."
if [ ! -d "$ZSH_CUSTOM/powerlevel10k" ]; then
  git clone --depth=1 "$P10K_REPO" "$ZSH_CUSTOM/powerlevel10k"
  echo -e "$OK Powerlevel10k instalado para usuario"
fi

if [ ! -d "$ROOT_ZSH_CUSTOM/powerlevel10k" ]; then
  sudo mkdir -p "$ROOT_ZSH_CUSTOM"
  sudo git clone --depth=1 "$P10K_REPO" "$ROOT_ZSH_CUSTOM/powerlevel10k"
  echo -e "$OK Powerlevel10k instalado para root"
fi

echo -e "$INFO Configurando .zshrc de usuario..."
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
add_source_user "themes/.p10k.zsh"

P10K_LINE="[[ -f \"$ZSH_CUSTOM/powerlevel10k/powerlevel10k.zsh-theme\" ]] && source \"$ZSH_CUSTOM/powerlevel10k/powerlevel10k.zsh-theme\""
grep -qxF "$P10K_LINE" "$USER_ZSHRC" || echo "$P10K_LINE" >> "$USER_ZSHRC"

echo -e "$OK .zshrc de usuario listo"

echo -e "$INFO Configurando .zshrc de root..."
sudo tee $ROOT_HOME/.zshrc > /dev/null <<EOF
[[ -f "$DOTFILES/exports.zsh" ]] && source "$DOTFILES/exports.zsh"
[[ -f "$DOTFILES/aliases.zsh" ]] && source "$DOTFILES/aliases.zsh"
[[ -f "$DOTFILES/functions.zsh" ]] && source "$DOTFILES/functions.zsh"
[[ -f "$DOTFILES/prompt.zsh" ]] && source "$DOTFILES/prompt.zsh"
[[ -f "$DOTFILES/themes/root/.p10k.zsh" ]] && source "$DOTFILES/themes/root/.p10k.zsh"
[[ -f "$ROOT_ZSH_CUSTOM/powerlevel10k/powerlevel10k.zsh-theme" ]] && source "$ROOT_ZSH_CUSTOM/powerlevel10k/powerlevel10k.zsh-theme"
EOF

echo -e "$OK .zshrc de root configurado"

echo -e "$INFO Cambiando shell por defecto a zsh..."
chsh -s "$(which zsh)"
sudo chsh -s "$(which zsh)" root

echo -e "$OK Instalación completada. Reinicia la terminal o ejecuta: exec zsh"
