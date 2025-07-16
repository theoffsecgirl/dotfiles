#!/bin/bash

DOTFILES_DIR="$HOME/dotfiles"
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$HOME/.dotfiles_backup"

REQUIRED_COMMANDS=(zsh git bat fzf lsd polybar kitty rofi picom bspwm sxhkd)

echo "🛠 Instalando entorno pastel cuqui de TheOffSecGirl..."

# ─── Comprobar dependencias ───
echo "🔍 Comprobando dependencias..."
for cmd in "${REQUIRED_COMMANDS[@]}"; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "❌ Falta $cmd. Instálalo antes de continuar."
    else
        echo "✅ $cmd encontrado."
    fi
done

# ─── Crear backups ───
echo "📦 Haciendo backup en $BACKUP_DIR..."
mkdir -p "$BACKUP_DIR"
cp -r "$CONFIG_DIR" "$BACKUP_DIR/config"
cp -r "$HOME/.p10k.zsh" "$BACKUP_DIR/" 2>/dev/null
cp -r "$HOME/.zshrc" "$BACKUP_DIR/" 2>/dev/null

# ─── Instalar wallpapers ───
echo "🖼 Copiando wallpaper..."
mkdir -p "$HOME/Pictures/wallpapers"
cp -u "$DOTFILES_DIR/wallpapers/fondo.png" "$HOME/Pictures/wallpapers/"

# ─── Instalar .config ───
echo "🔗 Enlazando configuraciones..."
for item in bspwm kitty picom polybar rofi sxhkd; do
    rm -rf "$CONFIG_DIR/$item"
    ln -s "$DOTFILES_DIR/config/$item" "$CONFIG_DIR/$item"
done

# ─── Enlazar scripts personalizados ───
echo "📜 Enlazando scripts personalizados..."
mkdir -p "$CONFIG_DIR/bspwm/scripts"
for script in "$DOTFILES_DIR/config/bspwm/scripts"/*.sh; do
    ln -sf "$script" "$CONFIG_DIR/bspwm/scripts/"
done

# ─── Rofi themes ───
echo "🎨 Instalando temas de Rofi..."
mkdir -p "$CONFIG_DIR/rofi/themes"
cp -u "$DOTFILES_DIR/config/rofi/themes/"*.rasi "$CONFIG_DIR/rofi/themes/"

# ─── Instalar zsh ───
echo "🌸 Configurando Zsh..."
mkdir -p "$HOME/.config/zsh"
ln -sf "$DOTFILES_DIR/zsh/aliases.zsh" "$HOME/.config/zsh/"
ln -sf "$DOTFILES_DIR/zsh/exports.zsh" "$HOME/.config/zsh/"
ln -sf "$DOTFILES_DIR/zsh/functions.zsh" "$HOME/.config/zsh/"
ln -sf "$DOTFILES_DIR/zsh/prompt.zsh" "$HOME/.config/zsh/"
ln -sf "$DOTFILES_DIR/.p10k.zsh" "$HOME/.p10k.zsh"

# Añadir a .zshrc si no está
if ! grep -q "source ~/.config/zsh/aliases.zsh" "$HOME/.zshrc" 2>/dev/null; then
    echo "source ~/.config/zsh/aliases.zsh" >> "$HOME/.zshrc"
    echo "source ~/.config/zsh/exports.zsh" >> "$HOME/.zshrc"
    echo "source ~/.config/zsh/functions.zsh" >> "$HOME/.zshrc"
    echo "source ~/.config/zsh/prompt.zsh" >> "$HOME/.zshrc"
fi

# ─── Si hay .p10k.zsh para root ───
if [ -f "$DOTFILES_DIR/root/.p10k.zsh" ]; then
    sudo cp "$DOTFILES_DIR/root/.p10k.zsh" /root/
    echo "✅ Copiado .p10k.zsh para root"
fi

# ─── Ejecutar setup_zsh si existe ───
if [ -f "$DOTFILES_DIR/zsh/setup_zsh.sh" ]; then
    echo "⚙️ Ejecutando setup_zsh.sh..."
    bash "$DOTFILES_DIR/zsh/setup_zsh.sh"
fi

# ─── Mensaje final ───
echo -e "\n🌈 Instalación completada. Reinicia bspwm o tu sesión para ver los cambios."
