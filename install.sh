#!/bin/bash

# --- Funciones de Utilidad ---

# Función para imprimir mensajes en colores
print_msg() {
    case "$1" in
        "info") echo -e "\033[1;94m[i] $2\033[0m" ;;
        "success") echo -e "\033[1;92m[✔] $2\033[0m" ;;
        "warn") echo -e "\033[1;93m[!] $2\033[0m" ;;
        "error") echo -e "\033[1;91m[✘] $2\033[0m" >&2; exit 1 ;;
    esac
}

# Función para verificar si un comando existe
command_exists() {
    command -v "$1" &>/dev/null
}

# --- Detección del Gestor de Paquetes ---

detect_package_manager() {
    if command_exists apt; then
        PKG_MANAGER="apt"
        UPDATE_CMD="sudo apt update"
        INSTALL_CMD="sudo apt install -y"
        BAT_PKG="bat"
        if ! command_exists bat && command_exists batcat; then BAT_PKG="bat"; fi
        LSD_PKG="lsd"
    elif command_exists dnf; then
        PKG_MANAGER="dnf"
        UPDATE_CMD="sudo dnf check-update"
        INSTALL_CMD="sudo dnf install -y"
        BAT_PKG="bat"
        LSD_PKG="lsd"
    elif command_exists pacman; then
        PKG_MANAGER="pacman"
        UPDATE_CMD="sudo pacman -Syu"
        INSTALL_CMD="sudo pacman -S --noconfirm"
        BAT_PKG="bat"
        LSD_PKG="lsd"
    else
        print_warn "Gestor de paquetes no soportado. Deberás instalar las dependencias manualmente."
        PKG_MANAGER="unsupported"
    fi
}

# --- Script Principal ---

print_msg "info" "Iniciando la instalación del entorno Rosepunk Zsh..."
detect_package_manager

# --- Verificación e Instalación de Dependencias ---

print_msg "info" "Verificando dependencias básicas..."
dependencies=("zsh" "git" "curl" "wget")
for dep in "${dependencies[@]}"; do
    if ! command_exists "$dep"; then
        print_warn "El comando '$dep' no se encuentra."
        if [ "$PKG_MANAGER" != "unsupported" ]; then
            read -p "¿Deseas intentar instalarlo ahora? (s/n): " choice
            if [[ "$choice" == "s" || "$choice" == "S" ]]; then
                print_msg "info" "Instalando '$dep'..."
                eval "$INSTALL_CMD $dep"
            else
                print_error "La instalación no puede continuar sin '$dep'."
            fi
        else
            print_error "Por favor, instala '$dep' manualmente y vuelve a ejecutar el script."
        fi
    fi
done

# --- Instalación de Oh My Zsh ---

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    print_msg "info" "Instalando Oh My Zsh..."
    # Ejecutamos el instalador de Oh My Zsh de forma no interactiva.
    # Creará un archivo .zshrc por defecto si no existe.
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    print_msg "success" "Oh My Zsh ya está instalado."
fi

# --- Instalación de Plugins y Herramientas ---

ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
# Powerlevel10k
if [ ! -d "${ZSH_CUSTOM}/themes/powerlevel10k" ]; then
    print_msg "info" "Instalando tema Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM}/themes/powerlevel10k"
else
    print_msg "success" "Powerlevel10k ya está instalado."
fi

# Zsh Plugins
plugins_to_install=(
    "https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM}/plugins/zsh-autosuggestions"
    "https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting"
)
for item in "${plugins_to_install[@]}"; do
    repo=$(echo "$item" | cut -d' ' -f1)
    target=$(echo "$item" | cut -d' ' -f2)
    if [ ! -d "$target" ]; then
        print_msg "info" "Instalando plugin desde $repo..."
        git clone "$repo" "$target"
    fi
done

# Herramientas recomendadas
if [ "$PKG_MANAGER" != "unsupported" ]; then
    print_msg "info" "Instalando herramientas recomendadas (neofetch, bat, lsd)..."
    eval "$UPDATE_CMD" >/dev/null 2>&1
    eval "$INSTALL_CMD neofetch $BAT_PKG $LSD_PKG"
else
    print_warn "No se pudo instalar neofetch, bat, lsd. Instálalos manually si los deseas."
fi

# --- Configuración de Dotfiles ---

print_msg "info" "Configurando dotfiles y enlaces simbólicos..."
DOTFILES_DIR="$HOME/dotfiles"
REPO_DIR="$(pwd)" # Asume que el script se ejecuta desde la raíz del repo

mkdir -p "$DOTFILES_DIR/zsh"
mkdir -p "$DOTFILES_DIR/themes"

print_msg "info" "Copiando archivos de configuración a $DOTFILES_DIR..."
cp "$REPO_DIR"/zsh/*.zsh "$DOTFILES_DIR/zsh/"
cp "$REPO_DIR"/themes/p10k.zsh "$DOTFILES_DIR/themes/.p10k.zsh"

ln -sf "$DOTFILES_DIR/themes/.p10k.zsh" "$HOME/.p10k.zsh"

# --- Modificación Segura de ~/.zshrc ---

ZSHRC_FILE="$HOME/.zshrc"
print_msg "info" "Verificando y configurando $ZSHRC_FILE..."

# Definimos el bloque de configuración PERSONALIZADO
CUSTOM_SNIPPET=$(cat <<'EOF'
# --- Rosepunk Dotfiles Configuration ---
# Carga de la configuración modular de Rosepunk
if [ -d "$HOME/dotfiles" ]; then
    source "$HOME/dotfiles/zsh/exports.zsh"
    source "$HOME/dotfiles/zsh/aliases.zsh"
    source "$HOME/dotfiles/zsh/functions.zsh"
    source "$HOME/dotfiles/zsh/prompt.zsh"
fi
# --- Fin Rosepunk Dotfiles ---
EOF
)

# Comprobamos si el .zshrc actual ya carga Oh My Zsh
if [ -f "$ZSHRC_FILE" ] && grep -q "source \$ZSH/oh-my-zsh.sh" "$ZSHRC_FILE"; then
    # El archivo parece un .zshrc válido. Nos aseguramos de que tenga la config correcta.
    print_msg "info" "$ZSHRC_FILE es válido. Asegurando configuración..."
    sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$ZSHRC_FILE"
    sed -i 's/^plugins=.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' "$ZSHRC_FILE"
    
    if ! grep -q "# --- Rosepunk Dotfiles Configuration ---" "$ZSHRC_FILE"; then
        echo -e "\n$CUSTOM_SNIPPET" >> "$ZSHRC_FILE"
    fi
else
    # El archivo no existe o está incompleto. Lo creamos/reemplazamos con una versión ideal.
    print_warn "$ZSHRC_FILE no existe o está incompleto. Creando uno nuevo y completo..."
    [ -f "$ZSHRC_FILE" ] && mv "$ZSHRC_FILE" "$ZSHRC_FILE.bak_$(date +%F-%T)"
    
    # Creamos el archivo .zshrc completo y correcto
    cat > "$ZSHRC_FILE" << EOF
# Path to your Oh My Zsh installation.
export ZSH="\$HOME/.oh-my-zsh"

# Set the name of the theme to load.
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of plugins.
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

# Load Oh My Zsh.
source \$ZSH/oh-my-zsh.sh

$CUSTOM_SNIPPET
EOF
    print_msg "success" "$ZSHRC_FILE ha sido creado con la configuración completa."
fi

# --- Finalización ---

# Cambiar la shell por defecto a Zsh si no lo es
if [[ "$SHELL" != */zsh ]]; then
    print_msg "info" "Cambiando la shell por defecto a Zsh. Se requerirá tu contraseña."
    if chsh -s "$(which zsh)"; then
        print_msg "success" "Shell por defecto cambiada a Zsh."
    else
        print_warn "No se pudo cambiar la shell. Hazlo manualmente con: chsh -s $(which zsh)"
    fi
fi

print_msg "warn" "IMPORTANTE: Para que los iconos se vean bien, necesitas una 'Nerd Font' instalada y configurada en tu terminal."
print_msg "success" "¡Instalación completada! Cierra sesión y vuelve a entrar para que todos los cambios surtan efecto."
