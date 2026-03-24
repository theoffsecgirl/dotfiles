<div align="center">

```
 ██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗
 ██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝
 ██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗
 ██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║
 ██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║
 ╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝
```

**Entorno ofensivo para macOS — Bug Bounty & Pentesting**  
*by [TheOffSecGirl](https://github.com/theoffsecgirl)*

![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20Linux-lightgrey?style=flat-square)
![Shell](https://img.shields.io/badge/Shell-zsh-brightgreen?style=flat-square&logo=gnu-bash&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-red?style=flat-square)
![BugBounty](https://img.shields.io/badge/Bug%20Bounty-Ready-brightgreen?style=flat-square)

</div>

---

## ¿Qué hay aquí?

| Módulo | Descripción |
|--------|-------------|
| `zsh/` | Aliases ofensivos, prompt y config completa |
| `nvim/` | Config de Neovim (Lua) para desarrollo y ofensiva |
| `tmux/` | Layout y keybindings para sesiones de hunting |
| `ghostty/` | Config del terminal Ghostty |
| `git/` | Gitconfig y helpers |
| `macos/` | Bootstrap macOS + Brewfile |
| `scripts/` | Scripts para Raycast (`.local/bin`) |
| `containers/` | Debian Toolbox · Exegol · Kali VM |
| `hunting-template/` | Template de workspace por target |

---

## Instalación

```bash
git clone https://github.com/theoffsecgirl/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Bootstrap (instala Homebrew + paquetes)
./macos/bootstrap-macos.sh

# Aplicar configs
stow -t "$HOME" zsh git tmux nvim scripts
source ~/.zshrc

# Crear workspace de hunting
cp -r hunting-template ~/hunting

# Build del contenedor
cd containers/debian-toolbox
docker compose build
```

> Aplicar solo algunas partes:
> ```bash
> stow -t "$HOME" zsh       # solo zsh
> stow -t "$HOME" git       # solo git
> stow -t "$HOME" scripts   # solo scripts
> ```

---

## Uso diario

```bash
# Arrancar entorno
offsec-up && offsec

# Navegación rápida
cdh              # ~/hunting
cdt              # ~/hunting/targets
note "texto"     # nota con timestamp
notes            # ver notas de hoy

# Recon
subenum dom.com  # enum de subdominios
probe urls.txt   # probar lista de URLs
h                # httpx básico
hh               # httpx con detección de tech
```

---

## Stack de contenedores

- **Debian Toolbox** → entorno diario (httpx, ffuf, curl, jq, Python) — 80% del tiempo
- **Exegol** → recon pesado puntual
- **Kali VM** → AD, pivoting y red interna

---

## Estructura

```
~/.dotfiles/
├── containers/debian-toolbox/
├── scripts/.local/bin/
├── hunting-template/
├── zsh/.config/zsh/
│   └── bug-bounty.zsh
├── macos/
├── brew/
├── git/
├── tmux/
├── nvim/
├── ghostty/
├── CHEATSHEET.md
└── SETUP-BUGBOUNTY.md
```

📖 Setup completo explicado paso a paso → [SETUP-BUGBOUNTY.md](SETUP-BUGBOUNTY.md)

---

## Filosofía

No acumular herramientas, reducir fricción cognitiva. Cada cosa en su sitio, sin mezclar.

---

## Uso ético

> Usa este entorno **solo en sistemas propios, laboratorios o programas de bug bounty con autorización explícita.**

---

## Licencia

MIT · [TheOffSecGirl](https://theoffsecgirl.com)
