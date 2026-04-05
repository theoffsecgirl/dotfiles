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

## Qué hay aquí

| Módulo | Descripción |
|--------|-------------|
| `zsh/` | Aliases ofensivos, funciones de bug bounty, prompt y config |
| `nvim/` | Config de Neovim |
| `tmux/` | Layout y keybindings para sesiones de hunting |
| `git/` | Gitconfig base + helpers |
| `brew/` | Brewfile completo |
| `scripts/` | Scripts en `~/.local/bin/` |
| `containers/` | Debian Toolbox con tooling ofensivo |
| `tests/` | Tests |
| `CHEATSHEET.md` | Referencia rápida |
| `SETUP-BUGBOUNTY.md` | Setup detallado |
| `AI-WORKFLOW.md` | Flujo IA para recon e hipótesis |

---

## Instalación rápida

```bash
git clone https://github.com/theoffsecgirl/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
offsec-bootstrap
hunt-doctor
```

---

## Modelo operativo

### Host
Úsalo para:
- Git
- dotfiles
- Claude Code
- edición y documentación

### Contenedor (`offsec-toolbox`)
Úsalo para:
- `subfinder`
- `httpx`
- `katana`
- `unfurl`
- `ffuf`
- `jq`
- `python3`
- `scope-v2`
- `webmap-v2`
- `paramhunt-v2`

---

## Uso diario

```bash
# Arrancar contenedor
offsec-up && offsec-shell

# Bootstrap dentro del contenedor
offsec-bootstrap
hunt-doctor

# Navegación rápida
cdh
cdt
note "texto"
notes
```

---

## Pipeline recomendado

### En el contenedor
```bash
mktarget example.com
scope-v2 example.com
webmap-v2 example.com
paramhunt-v2 example.com
```

### En el host
```bash
claude-recon example.com
claude-hypotheses example.com
```

---

## Bootstrap

```bash
offsec-bootstrap
```

Enlaza scripts de `~/.dotfiles/scripts/.local/bin/` a `~/.local/bin/` de forma idempotente y hace backup si encuentra conflictos.

---

## Doctor

```bash
hunt-doctor
```

Valida:
- tooling ofensivo
- scripts enlazados
- disponibilidad de Claude Code

---

## Stack de contenedores

- **Debian Toolbox** → entorno diario
- **Exegol** → recon pesado puntual
- **Kali VM** → AD, pivoting y red interna

Actualizar versiones de herramientas:

```bash
cd ~/.dotfiles/containers/debian-toolbox
docker compose build --build-arg HTTPX_VERSION=1.6.11
```

---

## Filosofía

Reducir fricción cognitiva y convertir recon en pipeline reproducible.

---

## Uso ético

> Usa este entorno solo en sistemas propios, laboratorios o programas con autorización explícita.

---

## Licencia

MIT · [TheOffSecGirl](https://theoffsecgirl.com)
