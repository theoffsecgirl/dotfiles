#!/bin/bash

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
USER_HOME=$(eval echo ~$SUDO_USER)

echo "🌸 Iniciando instalación de tus dotfiles cuquis..."

# --------------------
# 🔍 Comprobación de dependencias
# --------------------

check_dep() {
    if ! command -v "$1" &> /dev/null; then
        echo "❌ Falta $1"
        MISSING+=("$1")
    else
        echo "✅ $1 instalado"
    fi
}

echo "🔍 Comprobando dependencias necesarias..."

MISSING=()
check_dep bspwm
check_dep sxhkd
check_dep polybar
check_dep rofi
check_dep kitty
check_dep picom
check_dep zsh
check_dep feh

if [ ${#MISSING[@]} -ne 0 ]; then
    echo -e "\n⚠️  Faltan los siguientes paquetes: ${MISSING[*]}"
    read -p "¿Quieres que los instalemos automáticamente con apt? (S/n) " resp
    if [[ "$resp" =~ ^[Ss]$ || -z "$resp" ]]; then
        sudo apt update
        sudo apt install -y "${MISSING[@]}"
    fi
fi

# --------------------
# 🔗 Enlaces simbólicos
# --------------------

link_file() {
    SRC="$1"
    DEST="$2"
    mkdir -p "$(dirname "$DEST")"
    ln -sf "$REPO_DIR/$SRC" "$DEST"
    echo "✅ Vinculado $DEST"
}

# .config
link_file config/bspwm/bspwmrc "$USER_HOME/.config/bspwm/bspwmrc"
for script in "$REPO_DIR/config/bspwm/scripts/"*; do
    fname=$(basename "$script")
    link_file "config/bspwm/scripts/$fname" "$USER_HOME/.config/bspwm/scripts/$fname"
done

link_file config/kitty/color.ini "$USER_HOME/.config/kitty/color.ini"
link_file config/kitty/kitty.conf "$USER_HOME/.config/kitty/kitty.conf"
link_file config/picom/picom.conf "$USER_HOME/.config/picom/picom.conf"
link_file config/polybar/colors_pastel.ini "$USER_HOME/.config/polybar/colors_pastel.ini"
link_file config/polybar/current.ini "$USER_HOME/.config/polybar/current.ini"
link_file config/polybar/launch.sh "$USER_HOME/.config/polybar/launch.sh"
link_file config/rofi/config.rasi "$USER_HOME/.config/rofi/config.rasi"
link_file config/rofi/powermenu.rasi "$USER_HOME/.config/rofi/powermenu.rasi"
link_file config/rofi/themes/theoffsecgirl-pastel.rasi "$USER_HOME/.config/rofi/themes/theoffsecgirl-pastel.rasi"
link_file config/sxhkd/sxhkdrc "$USER_HOME/.config/sxhkd/sxhkdrc"

# Zsh
link_file zsh/aliases.zsh "$USER_HOME/.zsh/aliases.zsh"
link_file zsh/exports.zsh "$USER_HOME/.zsh/exports.zsh"
link_file zsh/functions.zsh "$USER_HOME/.zsh/functions.zsh"
link_file zsh/prompt.zsh "$USER_HOME/.zsh/prompt.zsh"
link_file zsh/themes/p10k.zsh "$USER_HOME/.zsh/themes/p10k.zsh"

# Si es root, aplicar config de root
if [ "$EUID" -eq 0 ]; then
    link_file zsh/themes/root/.p10k.zsh /root/.p10k.zsh
fi

# Wallpaper en ruta esperada por bspwmrc
mkdir -p "$USER_HOME/wallpapers"
link_file wallpapers/fondo.png "$USER_HOME/wallpapers/fondo.png"

echo -e "\n🎀 ¡Dotfiles cuqui instalados y dependencias listas! Ejecuta tu WM y disfruta del rosa pastel. 🩷"
