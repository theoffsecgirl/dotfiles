# Dotfiles de theoffsecgirl

Este repositorio contiene mi entorno personal de configuración para macOS y Linux, todo gestionado con [GNU Stow](https://www.gnu.org/software/stow/) para garantizar portabilidad, respaldo y despliegue rápido en cualquier máquina.

## ¿Qué incluye?

- Configuración avanzada de **Zsh** con alias y el tema Powerlevel10k.
- **Tmux** ultra-personalizado para sesiones persistentes, multiplexación y compatibilidad total en terminal.
- Configuración de **Neovim** optimizada para desarrollo y hacking, incluyendo el esquema de colores Catppuccin, plugins esenciales y dashboard visual.
- Personalización de **Git** con alias útiles e integraciones (sin incluir usuario/email).
- **Brewfile** para simplificar la instalación de dependencias en macOS con un solo comando.
- **Scripts, atajos y un entorno Python aislado** para bug bounty y scripting rápido.
- Configuraciones para **otros programas** como GhosTTY, Alacritty, Homebrew, y más.
- Soporte para **terminales modernas** (iTerm2, Kitty, GhosTTY), y settings de fuentes y themes.
- Organización modular de configs usando Stow y estructura limpia, para facilitar migración y restores.

## Instalación rápida

```bash
git clone https://github.com/theoffsecgirl/dotfiles.git ~/dotfiles
cd ~/dotfiles
bash init.sh
```

Este proceso:
- Instala Homebrew y Stow si no están presentes (en macOS).
- Aplica cada módulo con copias de seguridad automáticas.
- Instala las dependencias del Brewfile (opcional).
- Prepara un entorno virtual de Python.
- Configura Neovim con el esquema de colores Catppuccin mínimo.
- Aplica configuraciones para tmux, Zsh, y terminales compatibles.

## Seguridad

- Nunca expongo mi información personal como usuarios de Git, claves privadas de SSH, ni datos sensibles.
- Archivos como `.gitconfig`, `.git-credentials`, `.ssh/`, etc., están en `.gitignore`.
- Puedes adaptar la configuración global copiando `gitconfig.example`.

## ¿Cómo está estructurado cada directorio?

- `stow/` → Cada directorio representa un módulo (zsh, nvim, tmux, git, homebrew…).
- `venvs/` → Para requisitos de Python, scripts, etc.
- `init.sh` → Script de bootstrap automatizado.

## Personalización

Puedes añadir o modificar módulos en `stow` según tu entorno. Se recomienda hacer un fork y mantener una rama propia si personalizas detalles particulares.

***

Hecho con ❤️ por @theoffsecgirl. Pull requests y sugerencias son bienvenidas. 

***

[1](https://www.gnu.org/software/stow/)
