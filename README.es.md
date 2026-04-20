<div align="center">

![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20Linux-lightgrey?style=flat-square)
![Shell](https://img.shields.io/badge/Shell-zsh-brightgreen?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-red?style=flat-square)
![Status](https://img.shields.io/badge/Status-Stable-brightgreen?style=flat-square)



**Dotfiles para bug bounty y pentesting**  
*by [TheOffSecGirl](https://github.com/theoffsecgirl)*

> 🇬🇧 [English version](README.md)

</div>

---

## Qué es esto

Esto no son "dotfiles bonitos".

Es mi entorno real de trabajo para bug bounty.

Está pensado para:

- no perder tiempo configurando cosas
- tener siempre el mismo workflow
- automatizar lo repetitivo
- ir directo a encontrar bugs

---

## Setup

```bash
git clone git@github.com:theoffsecgirl/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
exec zsh
```

Si algo falla:

```bash
hunt-doctor
```

---

## Cómo se usa (lo importante)

### 1. Crear target

```bash
mktarget example.com
```

Workspace:

```
~/hunting/targets/example.com
```

---

### 2. Recon

```bash
recon example.com
```

Ejecuta subenum → probe → nota automática. Los subdominios se guardan en `~/hunting/targets/example.com/subdomains.txt`.

```bash
subenum example.com   # solo subdominios
scope example.com     # filtrar in-scope
```

---

### 3. Nuclei

```bash
nuc -l urls.txt       # nuclei -silent
nucl urls.txt         # contra CVEs, guarda resultado
```

---

### 4. HTTP

```bash
h      # httpx -silent
hh     # httpx + tech-detect + status-code
hhh    # httpx + tech-detect + title + web-server
f      # ffuf -c -mc all -fc 404
```

---

### 5. Cheatsheet interactivo

```bash
tips
```

Abre un buscador fzf con todos los aliases organizados por categoría (git, recon, docker, navegación, utilidades). Escribe para filtrar, ESC para salir.

---

## Navegación rápida

[`zoxide`](https://github.com/ajeetdsouza/zoxide) aprende los directorios que más usas:

```bash
z hunting       # salta a ~/hunting
z dotfiles      # salta a ~/.dotfiles
zi              # selector interactivo con fzf
dotfiles        # alias directo a ~/.dotfiles
hunting         # alias directo a ~/hunting
```

---

## Historial avanzado

[`atuin`](https://github.com/atuinsh/atuin) reemplaza el historial de zsh con búsqueda semántica y contexto (directorio, exit code, duración):

```bash
Ctrl+R   # búsqueda interactiva del historial
```

---

## Aliases git

| Alias | Comando |
|-------|--------|
| `gs` | `git status -sb` |
| `gl` | `git log --oneline --graph --decorate -20` |
| `gd` | `git diff` |
| `gds` | `git diff --staged` |
| `gc 'msg'` | `git commit -m` |
| `gca` | `git commit --amend --no-edit` |
| `gco` | `git checkout` |
| `gcb` | `git checkout -b` |
| `gst` / `gstp` | `git stash` / `git stash pop` |
| `glog` | log completo con grafo |

---

## Herramientas incluidas

Instaladas automáticamente en `~/.local/tools/` con `./install.sh`:

| Herramienta | Uso |
|-------------|-----|
| `webxray` | Scanner web ofensivo: XSS, SQLi, headers, WAF bypass |
| `pathraider` | LFI y path traversal con bypass de encoding |
| `bbcopilot` | Asistente IA para bug bounty con vault local |
| `takeovflow` | Subdomain takeover detection |
| `bluedeath` | Herramienta ofensiva shell |

Actualizar todas:

```bash
bash ~/.dotfiles/tools/update-tools.sh
```

---

## Contenedor offsec (opcional)

```bash
offsec-up       # levantar contenedor
offsec-shell    # entrar al contenedor
offsec          # exec directo a zsh en el contenedor
```

---

## Estructura

```
~/.dotfiles/
├── zsh/
│   └── .config/zsh/
│       ├── load.zsh           # carga principal
│       ├── bug-bounty.zsh     # funciones y aliases de recon
│       └── aliases-general.zsh # aliases de productividad
├── tmux/
├── nvim/
├── git/
├── ghostty/
├── scripts/
├── tools/
│   ├── install-tools.sh
│   └── update-tools.sh
└── install.sh
```

Gestionado con stow — symlinks limpios y reversibles.

---

## Uso ético

Solo en sistemas con permiso.

---

## Licencia

MIT
