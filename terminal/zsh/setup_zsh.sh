#!/bin/bash

ZSHRC="$HOME/.zshrc"
DOTFILES_DIR="$HOME/dotfiles/terminal/zsh"

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

# Cambiar shell por defecto a zsh
if [ "$SHELL" != "$(which zsh)" ]; then
  chsh -s "$(which zsh)"
  echo -e "$OK Shell por defecto cambiado a zsh"
else
  echo -e "$INFO Shell ya es zsh"
fi

echo -e "$OK Instalación completada. Reinicia la terminal o ejecuta: exec zsh"
