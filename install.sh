#!/bin/bash

echo -e "\033[1;95m[+] Instalando entorno Rosepunk para Zsh + Tilix...\033[0m"

# Crear estructura de carpetas si no existen
mkdir -p ~/dotfiles/zsh
mkdir -p ~/dotfiles/themes

# Mover dotfiles si están en la carpeta actual
mv ./zsh/*.zsh ~/dotfiles/zsh/ 2>/dev/null
mv ./themes/.p10k.zsh ~/dotfiles/themes/.p10k.zsh 2>/dev/null

# Crear enlace simbólico para .p10k.zsh en home
ln -sf ~/dotfiles/themes/.p10k.zsh ~/.p10k.zsh

# Crear o actualizar ~/.zshrc
cat > ~/.zshrc << 'EOF'
# ─── INSTANT PROMPT ──────────────────────────────────────────────────────────────
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ─── OH MY ZSH ───────────────────────────────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# ─── DOTFILES ────────────────────────────────────────────────────────────────────
source ~/dotfiles/zsh/exports.zsh
source ~/dotfiles/zsh/aliases.zsh
source ~/dotfiles/zsh/functions.zsh
source ~/dotfiles/zsh/prompt.zsh
EOF

echo -e "\033[1;92m[✔] Instalación completada. Reinicia tu terminal o ejecuta: source ~/.zshrc\033[0m"
