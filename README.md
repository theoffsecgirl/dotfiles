<<<<<<< HEAD
# dotfiles
=======
### Dotfiles de theoffsecgirl: Portabilidad y Seguridad con Stow

Configura tu entorno de manera modular y personalizable para macOS y Linux, optimizado para bug bounty, hacking ético y automatización. Estos dotfiles están diseñados pensando en la portabilidad, facilidad de mantenimiento y seguridad.

#### 🚀 Instalación Rápida en Otro Equipo

1. **Instala Git y Stow:**
    - **En macOS:**

```Bash
brew install git stow
```

    - **En Linux (Debian/Ubuntu):**

```Bash
sudo apt install git stow -y
```

1. **Clona el repositorio en tu `$HOME`:**

```Bash
git clone https://github.com/theoffsecgirl/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

1. **Instala paquetes (si usas Homebrew):**

```Bash
brew bundle --file=~/dotfiles/Brewfile
```

1. **Ejecuta el script de inicio para configurar Git y crear los symlinks:**

```Bash
chmod +x init.sh
./init.sh
```

El script solicitará tu nombre y correo electrónico para Git y enlazará las configuraciones en tu sistema.

#### 🛠 Limpiar o Rehacer Symlinks

Si necesitas deshacer los enlaces y volver a crearlos, ejecuta:

```Bash
stow -D zsh nvim git ghostty homebrew scripts stow .
```

**Nota:** Solo debes versionar carpetas de configuración, nunca archivos sueltos como `Brewfile`.

#### 📁 Estructura del Repositorio

```other
dotfiles/
├── zsh/       # Configuración modular de Zsh (.zshrc, .p10k.zsh, etc.)
├── nvim/      # Configuración de Neovim (~/.config/nvim)
├── git/       # .gitconfig global, alias y extras
├── ghostty/   # Configuración del terminal Ghostty
├── homebrew/  # Scripts y configuraciones de Homebrew
├── scripts/   # Scripts útiles y de automatización
└── Brewfile   # Paquetes para instalar con Homebrew
```

#### 🔒 Seguridad por Defecto

El repositorio incluye un `.gitignore` para evitar subir archivos sensibles:

```other
*.key
*.pem
*.env
id_*
.aws/
.gcloud/
*.bak
*.swp
*.log
.gitconfig.local
```

No subas claves, tokens, credenciales ni datos personales. Mantén el bloque `[user]` de tu `.gitconfig` fuera del control de versiones.

#### 🦾 Ventajas

- **Configuración portátil y profesional:** Utiliza symlinks, evitando las copias manuales.
- **Modularidad:** Fácil de mantener y extender.
- **Seguridad por diseño:** Sin datos privados versionados.
- **Óptimo para hacking, bug bounty y automatización.**

Implementa estas configuraciones y mejora tu flujo de trabajo con facilidad y seguridad.
>>>>>>> 67a8048 (Dotfiles portables y seguros con Stow)
