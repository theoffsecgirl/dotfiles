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

Pensado para:

- no perder tiempo configurando
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

Para ver qué haría stow sin aplicar cambios:

```bash
./install.sh --dry-run
```

Si algo falla:

```bash
hunt-doctor
```

---

## Workflow de bug bounty

### Target single-domain

```bash
mktarget example.com
scope example.com
webmap example.com
paramhunt-v2 example.com
```

Layout:

```text
$HUNTING_HOME/targets/example.com/
├── recon/
├── http/
├── fuzz/
├── js/
├── in/
│   └── resolvers.txt
├── out/
├── tmp/
├── burp/
├── notes/
│   └── summary.md
├── reports/
├── loot/
└── meta/
```

### Programa multi-dominio (privados típicos)

```bash
program-init example
cd "$HUNTING_HOME/targets/example"
```

Importar brief:

```bash
nvim in/brief.txt
program-import-brief example in/brief.txt
```

Validar scope:

```bash
nvim in/roots.txt
nvim in/scope-web.txt
nvim in/out-of-scope.txt
```

Recon:

```bash
scope-program example
webmap example
paramhunt-v2 example
```

Todo se mantiene en:

```text
$HUNTING_HOME/targets/example/
```

### Validación

```bash
type -a program-init scope-program program-import-brief scope webmap mktarget subscan
```

---

## Navegación rápida

```bash
cdh        # cd $HUNTING_HOME
cdt        # cd $HUNTING_HOME/targets
cdn        # cd $HUNTING_HOME/notes
cds        # cd $HUNTING_HOME/scripts
```

---

## Tips interactivos

```bash
tips
```

---

## Utilidades generales

| Comando | Comportamiento |
|---|---|
| `grh` | `git reset --hard HEAD` — muestra el diff y pide confirmación antes de ejecutar |
| `cat` | Usa `bat` automáticamente si está instalado (resaltado de sintaxis, sin paginación) |
| `myip` | Prueba tres servicios con timeout de 3s cada uno |
| `localip` | Funciona en macOS (`en0`) y Linux (`ip addr`) |
| `git wip` | Solo stagea ficheros ya rastreados (`add -u`), nunca ficheros nuevos sin seguimiento |

---

## Tools

```bash
bash ~/.dotfiles/tools/install-tools.sh
bash ~/.dotfiles/tools/update-tools.sh
```

---

## Uso ético

Solo en sistemas con permiso.

---

## Licencia

MIT
