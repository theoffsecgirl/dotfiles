#!/bin/bash

# Cambiar shell por defecto a zsh
chsh -s "$(which zsh)"

# Añadir líneas al .zshrc solo si no existen
ZSHRC="$HOME/.zshrc"

declare -a LINES=(
  'source ~/dotfiles/zsh/exports.zsh'
  'source ~/dotfiles/zsh/aliases.zsh'
  'source ~/dotfiles/zsh/functions.zsh'
  'source ~/dotfiles/zsh/exports.zsh'

)

for line in "${LINES[@]}"; do
  if ! grep -Fxq "$line" "$ZSHRC"; then
    echo "$line" >> "$ZSHRC"
    echo "Añadido al .zshrc: $line"
  else
    echo "Ya existe en .zshrc: $line"
  fi
done

# Recargar configuración actual
source "$ZSHRC"

echo "Shell por defecto cambiado a zsh y dotfiles cargados en .zshrc"
echo "Por favor, cierra y vuelve a abrir la terminal para usar zsh como shell por defecto."
