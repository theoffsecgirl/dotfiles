#!/bin/bash

ZSHRC="$HOME/.zshrc"
DOTFILES_DIR="$HOME/dotfiles/terminal/zsh"

# Función para añadir una línea al .zshrc si no existe
add_source_if_missing() {
  local file="$1"
  local line="[[ -f \"$DOTFILES_DIR/$file\" ]] && source \"$DOTFILES_DIR/$file\""
  if ! grep -Fxq "$line" "$ZSHRC"; then
    echo "$line" >> "$ZSHRC"
    echo "Añadido al .zshrc: $line"
  else
    echo "Ya existe en .zshrc: $line"
  fi
}

# Crear .zshrc si no existe
if [ ! -f "$ZSHRC" ]; then
  echo "# .zshrc creado por setup_zsh.sh" > "$ZSHRC"
  echo "Creado nuevo .zshrc"
fi

# Añadir fuentes de dotfiles
add_source_if_missing "exports.zsh"
add_source_if_missing "aliases.zsh"
add_source_if_missing "functions.zsh"
add_source_if_missing "prompt.zsh"
add_source_if_missing "themes/.p10k.zsh"

# Cambiar shell por defecto a zsh si no lo es ya
if [ "$SHELL" != "$(which zsh)" ]; then
  chsh -s "$(which zsh)"
  echo "Shell por defecto cambiado a zsh"
fi

echo "Instalación completada. Reinicia la terminal para aplicar cambios."
