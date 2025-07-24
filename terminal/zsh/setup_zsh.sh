#!/bin/bash

ZSHRC="$HOME/.zshrc"
DOTFILES_DIR="$HOME/dotfiles/terminal/zsh"
ZSH_CUSTOM="$HOME/.zsh"
P10K_DIR="$ZSH_CUSTOM/powerlevel10k"

# Colores
OK="\033[1;92m[OK]\033[0m"
INFO="\033[1;94m[*]\033[0m"
WARN="\033[1;93m[!]\033[0m"
ERR="\033[1;91m[✘]\033[0m"

# Instalar dependencias
echo -e "$INFO Instalando paquetes necesarios..."
sudo apt update && sudo apt install -y \
  zsh curl git unzip xclip \
  fzf lsd bat

# Instalar Powerlevel10k si no está
if [ ! -d "$P10K_DIR" ]; then
  echo -e "$INFO Instalando Powerlevel10k..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
  echo -e "$OK Powerlevel10k instalado en $P10K_DIR"
else
  echo -e "$INFO Powerlevel10k ya está instalado"
fi

# Crear .zshrc si no existe
if [ ! -f "$ZSHRC" ]; then
  echo "# .zshrc creado por setup_zsh.sh" > "$ZSHRC"
  echo -e "$OK Creado nuevo .zshrc"
fi

# Añadir línea si no existe
add_source_if_missing() {
  local file="$1"
  local line="[[ -f \"$DOTFILES_DIR/$file\" ]] && source \"$DOTFILES_DIR/$file\""
  if ! grep -Fxq "$line" "$ZSHRC"; then
    echo "$line" >> "$ZSHRC"
    echo -e "$OK Añadido a .zshrc: $file"
  else
    echo -e "$WARN Ya estaba en .zshrc: $file"
  fi
}

# Enlazar dotfiles
add_source_if_missing "exports.zsh"
add_source_if_missing "aliases.zsh"
add_source_if_missing "functions.zsh"
add_source_if_missing "prompt.zsh"
add_source_if_missing "themes/.p10k.zsh"

# Añadir Powerlevel10k si no está en .zshrc
P10K_SOURCE='[[ -f "$HOME/.zsh/powerlevel10k/powerlevel10k.zsh-theme" ]] && source "$HOME/.zsh/powerlevel10k/powerlevel10k.zsh-theme"'
if ! grep -Fxq "$P10K_SOURCE" "$ZSHRC"; then
  echo "$P10K_SOURCE" >> "$ZSHRC"
  echo -e "$OK Añadido Powerlevel10k al .zshrc"
else
  echo -e "$WARN Powerlevel10k ya estaba en el .zshrc"
fi

# Cambiar shell por defecto a zsh
if [ "$SHELL" != "$(which zsh)" ]; then
  chsh -s "$(which zsh)"
  echo -e "$OK Shell por defecto cambiado a zsh"
else
  echo -e "$INFO Shell ya es zsh"
fi

echo -e "$OK Instalación completada. Reinicia la terminal o ejecuta: exec zsh"
