<div align="center">

![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20Linux-lightgrey?style=flat-square)
![Shell](https://img.shields.io/badge/Shell-zsh-brightgreen?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-red?style=flat-square)
![Status](https://img.shields.io/badge/Status-Stable-brightgreen?style=flat-square)

````
 ██████╗  ██████╗ ███████╗███████╗██╗██╗     ███████╗███████╗
 ██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝
 ██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  █████╗  
 ██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ██╔══╝  
 ██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████╗
 ╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝
````

**Dotfiles para bug bounty y pentesting**  
*by [TheOffSecGirl](https://github.com/theoffsecgirl)*

> 🇬🇧 [English version](README.md)

</div>

---

## Qué es esto

Esto no son “dotfiles bonitos”.

Es mi entorno real de trabajo para bug bounty.

Está pensado para:

- no perder tiempo configurando cosas
- tener siempre el mismo workflow
- automatizar lo repetitivo
- ir directo a encontrar bugs

---

## Setup

```bash
git clone git@github.com:theoffsecgirl/dotfiles.git ~/src/dotfiles
cd ~/src/dotfiles
./install.sh --non-interactive --no-shell-change
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
scope-v2 example.com
```

---

### 3. Mapping

```bash
webmap-v2 example.com
```

---

### 4. Params

```bash
paramhunt-v2 example.com
```

---

## Workflow real

```
recon → mapping → params → vuln hunting
```

---

## Contenedor (opcional)

```bash
offsec-up
offsec-shell
```

---

## Dotfiles

Gestionados con stow:

- symlinks
- limpio
- reversible

---

## Nota

No es un framework.

Son scripts que uso todos los días.

---

## Uso ético

Solo en sistemas con permiso.

---

## Licencia

MIT
