<div align="center">

```
 ██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗
 ██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝
 ██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗
 ██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║
 ██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║
 ╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝
```

**Offensive dotfiles — Bug Bounty & Pentesting workflow**  
*by [TheOffSecGirl](https://github.com/theoffsecgirl)*

![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20Linux-lightgrey?style=flat-square)
![Shell](https://img.shields.io/badge/Shell-zsh-brightgreen?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-red?style=flat-square)
![Status](https://img.shields.io/badge/Status-Stable-brightgreen?style=flat-square)

</div>

---

## ⚡ Qué es esto

Entorno de trabajo para **bug bounty real**, diseñado para:

- eliminar fricción
- estandarizar workflows
- automatizar recon → mapping → explotación
- ser portable entre máquinas

---

## ⚡ Setup (1 comando mental)

```bash
git clone git@github.com:theoffsecgirl/dotfiles.git ~/src/dotfiles
cd ~/src/dotfiles
./install.sh --non-interactive --no-shell-change
exec zsh
```

---

## 🚀 Quick demo

```bash
mktarget example.com
scope-v2 example.com
webmap-v2 example.com
paramhunt-v2 example.com
```

Resultado:

```
~/hunting/targets/example.com/
├── http/
├── recon/
├── params/
└── notes/
```

---

## 🧠 Filosofía

- **host-first** → velocidad máxima
- contenedor opcional → aislamiento
- scripts > herramientas sueltas
- output estructurado siempre
- reproducibilidad total

---

## 🧪 Workflow real

### 1. Crear target
```bash
mktarget example.com
```

### 2. Recon
```bash
scope-v2 example.com
```

### 3. Mapping (crawl + endpoints)
```bash
webmap-v2 example.com
```

### 4. Param discovery
```bash
paramhunt-v2 example.com
```

---

## 🔧 Tooling clave

| Tool            | Qué hace realmente |
|-----------------|------------------|
| mktarget        | estructura base + workspace |
| scope-v2        | subdomains + http probing |
| webmap-v2       | crawling + endpoints útiles |
| paramhunt-v2    | extracción de parámetros |
| hunt-doctor     | sanity check del entorno |

---

## 🩺 Diagnóstico

```bash
hunt-doctor
```

---

## 🐳 Contenedor (opcional)

```bash
offsec-up
offsec-shell
```

---

## ⚙️ Gestión de dotfiles

Gestionado con **GNU Stow**:

- symlinks → limpio
- reversible
- sin copiar configs

Ubicación:

```
~/src/dotfiles
```

---

## 📂 Estructura

```
.
├── brew/
├── containers/
├── docs/
├── hunting-template/
├── nvim/
├── scripts/.local/bin/
├── scripts/.local/lib/
├── tmux/
├── vendor/
└── zsh/
```

---

## ⚠️ Notas importantes

- $HUNTING_HOME → ~/hunting
- outputs siempre a disco
- scripts pensados para chaining

---

## ⚖️ Uso ético

> Solo usar en sistemas propios o con autorización explícita.

---

## 📄 Licencia

MIT — https://theoffsecgirl.com
