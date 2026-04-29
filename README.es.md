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

Si algo falla:

```bash
hunt-doctor
```

---

## Workflow de bug bounty

### 1. Crear target

```bash
mktarget example.com
```

Layout oficial:

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

### 2. Enumeración y HTTP

```bash
scope example.com
```

Salida:

```text
recon/subdomains.txt
http/live.txt
http/httpx.jsonl
http/httpx_table.tsv
meta/scope.json
```

### 3. Crawl y mapeo

```bash
webmap example.com
```

Salida:

```text
http/urls.txt
http/urls_clean.txt
http/api_candidates.txt
http/graphql.txt
js/files.txt
meta/webmap.json
```

### 4. Parámetros

```bash
paramhunt-v2 example.com
```

Salida:

```text
fuzz/urls_with_params.txt
fuzz/params.txt
meta/paramhunt.json
```

### Flujo recomendado

```bash
mktarget example.com
scope example.com
webmap example.com
paramhunt-v2 example.com
```

Validación:

```bash
type -a scope webmap mktarget subscan
```

Todos deben resolver a `~/.local/bin/*`.

---

## Navegación rápida

```bash
cdh        # cd $HUNTING_HOME
cdt        # cd $HUNTING_HOME/targets
cdn        # cd $HUNTING_HOME/notes
cds        # cd $HUNTING_HOME/scripts
```

---

## Tools

Scripts versionados:

```text
tools/install-tools.sh
tools/update-tools.sh
```

Ignorados:

```text
tools/bin/
tools/src/
```

Reinstalar:

```bash
bash ~/.dotfiles/tools/install-tools.sh
```

---

## Estructura

```text
~/.dotfiles/
├── zsh/
├── tmux/
├── nvim/
├── git/
├── ghostty/
├── scripts/
├── tools/
└── install.sh
```

---

## Uso ético

Solo en sistemas con permiso.

---

## Licencia

MIT
