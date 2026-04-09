<div align="center">

```

██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗
██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝
██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗
██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║
██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║
╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝

````

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
````

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

* **host-first** → velocidad máxima
* contenedor opcional → aislamiento
* scripts > herramientas sueltas
* output estructurado siempre
* reproducibilidad total

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

| Tool           | Qué hace realmente          |
| -------------- | --------------------------- |
| `mktarget`     | estructura base + workspace |
| `scope-v2`     | subdomains + http probing   |
| `webmap-v2`    | crawling + endpoints útiles |
| `paramhunt-v2` | extracción de parámetros    |
| `hunt-doctor`  | sanity check del entorno    |

---

## 🩺 Diagnóstico

```bash
hunt-doctor
```

Ejemplo:

```
[OK] subfinder
[OK] httpx
[OK] katana
[OK] jq
[OK] webmap-v2
[WARN] claude (host only)
```

---

## 🐳 Contenedor (opcional)

```bash
offsec-up
offsec-shell
```

Uso recomendado:

* aislar tooling pesado
* reproducir entornos

---

## ⚙️ Gestión de dotfiles

Gestionado con **GNU Stow**:

* symlinks → limpio
* reversible
* sin copiar configs

Ubicación:

```
~/src/dotfiles
```

---

## 📂 Estructura

```
.
├── brew/                 # paquetes base
├── containers/           # docker tooling
├── docs/                 # documentación
├── hunting-template/     # base de targets
├── nvim/                 # editor
├── scripts/.local/bin/   # tooling ofensivo
├── scripts/.local/lib/   # helpers compartidos
├── tmux/                 # sesiones
├── vendor/               # shell-utils
└── zsh/                  # shell config
```

---

## ⚠️ Notas importantes

* `$HUNTING_HOME` → `~/hunting`
* todos los outputs van a disco (no stdout basura)
* scripts diseñados para chaining

---

## 🧪 Roadmap

* [ ] hardening `hunt-doctor`
* [ ] tests BATS reales
* [ ] mejorar `webmap-v2` output
* [ ] cross-platform clipboard tmux

---

## ⚖️ Uso ético

> Solo usar en sistemas propios o con autorización explícita.

---

## 📄 Licencia

MIT — [TheOffSecGirl](https://theoffsecgirl.com)

```

---

## Qué mejora esto (clave)

- añade **quick demo → engancha**
- cambia descripción → más creíble (no genérico)
- tooling explicado por **impacto real**
- workflow limpio (no ruido)
- introduce **estructura mental atacante**
- elimina cosas vagas
- añade roadmap (da sensación de proyecto vivo)

