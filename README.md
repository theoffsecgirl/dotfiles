<div align="center">

```
 ██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗
 ██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝
 ██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗
 ██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║
 ██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║
 ╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝
```

**Entorno ofensivo para macOS y Linux — Bug Bounty & Pentesting**  
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
| `zsh/` | Aliases ofensivos, funciones de bug bounty, prompt y config completa |
| `nvim/` | Config de Neovim (Lua) — LSP, Telescope, dashboard, snippets |
| `tmux/` | Layout y keybindings para sesiones de hunting |
| `ghostty/` | Config del terminal Ghostty (macOS) |
| `git/` | Gitconfig base + helpers (identidad en `~/.gitconfig.local`) |
| `brew/` | Brewfile completo (base + ProjectDiscovery + containers + Go) |
| `scripts/` | Scripts ejecutables en `~/.local/bin/` |
| `containers/` | Debian Toolbox con httpx, ffuf, subfinder, nuclei, anew |
| `hunting-template/` | Template de workspace por target |
| `tests/` | Suite bats para scripts y zsh |
| `CHEATSHEET.md` | Referencia rápida de todos los comandos |

---

## Instalación rápida

```bash
git clone https://github.com/theoffsecgirl/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

`install.sh` detecta macOS o Linux y hace todo automáticamente:
- macOS: instala Homebrew → `brew bundle` → stow
- Linux (apt/dnf/pacman): instala dependencias base → stow
- Aplica todos los paquetes con stow
- Crea `~/hunting/{targets,notes,scripts}`
- Avisa si falta `~/.gitconfig.local` (identidad git)

> Aplicar solo partes:
> ```bash
> stow -t "$HOME" zsh       # solo zsh
> stow -t "$HOME" tmux      # solo tmux
> stow -t "$HOME" nvim      # solo nvim
> ```

---

## Configuración de identidad Git

La identidad (nombre y email) **no se versiona**. Créala una sola vez:

```bash
cat > ~/.gitconfig.local << 'EOF'
[user]
    name  = Tu Nombre
    email = tu@email.com
EOF
```

---

## Uso diario

```bash
# Arrancar contenedor
offsec-up && offsec-shell

# Navegación rápida
cdh              # ~/hunting
cdt              # ~/hunting/targets
note "texto"     # nota con timestamp
notes            # ver notas de hoy

# Recon
mktarget dom.com     # crea estructura completa del target
scope dom.com        # subdominios + hosts vivos
webmap dom.com       # crawl katana → urls.txt + js
paramhunt dom.com    # parámetros únicos
subscan dom.com      # tabla httpx con status + título
```

📖 Referencia completa → [CHEATSHEET.md](CHEATSHEET.md)

---

## Stack de contenedores

- **Debian Toolbox** → entorno diario (httpx, ffuf, subfinder, nuclei, anew…) — 80% del tiempo
- **Exegol** → recon pesado puntual
- **Kali VM** → AD, pivoting y red interna

Actualizar versiones de herramientas sin tocar el Dockerfile:
```bash
cd ~/.dotfiles/containers/debian-toolbox
docker compose build --build-arg HTTPX_VERSION=1.6.11
```

---

## Tests

```bash
brew install bats-core   # macOS
bats tests/              # todos los tests
bats --verbose-run tests/ # con detalle
```

---

## Estructura

```
~/.dotfiles/
├── install.sh              ← bootstrap universal (macOS + Linux)
├── CHEATSHEET.md           ← referencia rápida de comandos
├── SETUP-BUGBOUNTY.md      ← guía de instalación detallada
├── brew/Brewfile
├── containers/debian-toolbox/
├── git/
├── ghostty/
├── hunting-template/
├── macos/
├── nvim/.config/nvim/
├── scripts/.local/bin/
├── tests/
├── tmux/
├── vendor/
└── zsh/.config/zsh/
```

---

## Filosofía

No acumular herramientas, reducir fricción cognitiva. Cada cosa en su sitio, sin mezclar.

---

## Uso ético

> Usa este entorno **solo en sistemas propios, laboratorios o programas de bug bounty con autorización explícita.**

---

## Licencia

MIT · [TheOffSecGirl](https://theoffsecgirl.com)
