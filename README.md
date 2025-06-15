# Rosepunk Zsh - Dotfiles Universales

Este repositorio contiene mi configuración personalizada para Zsh y Powerlevel10k con un estilo Rosepunk 🌹🦂. Está diseñado para ser compatible con la mayoría de las distribuciones de Linux y emuladores de terminal modernos.

---

## ✨ Características

-   **Prompt Agnóstico:** Prompt moderno y personalizable con Powerlevel10k.
-   **Instalador Inteligente:** Un script de instalación que detecta y instala las dependencias necesarias.
-   **Compatibilidad:** Funciona con gestores de paquetes `apt`, `dnf` y `pacman`.
-   **Configuración Modular:** Alias, funciones y variables en archivos separados para fácil mantenimiento.
-   **Adaptable:** Los alias para herramientas como `bat` o `lsd` solo se activan si están instaladas.

## ⚠️ Requisitos Previos

1.  **Zsh**: Debe estar instalado. El script intentará instalarlo si no lo encuentra.
2.  **Git**: Necesario para clonar el repositorio.
3.  **Nerd Font**: **Esencial para que los iconos (como el escorpión 🦂) se muestren correctamente**.
    -   Se recomienda [Hack Nerd Font](https://www.nerdfonts.com/font-downloads).
    -   Después de instalar la fuente en tu sistema, **debes configurarla en tu emulador de terminal** (GNOME Terminal, Konsole, Tilix, Alacritty, etc.).

## 🛠 Instalación

```bash
# 1. Clona el repositorio
git clone [https://github.com/theoffsecgirl/dotfiles.git](https://github.com/theoffsecgirl/dotfiles.git)
Bash

# 2. Ejecuta el instalador
cd dotfiles
chmod +x install.sh
./install.sh
El script se encargará de:
```

Instalar Oh My Zsh.
- Instalar plugins y herramientas recomendadas.
- Crear los enlaces simbólicos necesarios.
- Configurar tu ~/.zshrc sin sobreescribir tus configuraciones existentes.
Después de la instalación, reinicia tu terminal.

🤝 Contribuciones
Si quieres colaborar, abre un issue o un Pull Request. ¡Toda mejora es bienvenida!

📄 Licencia
Este proyecto es libre para uso personal y educativo.
