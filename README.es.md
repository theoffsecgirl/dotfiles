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

Es mi entorno real de trabajo para bug bounty — macOS primero, orientado a terminal, construido alrededor de un workflow reproducible.

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
```

Tras la instalación, configura tu workspace (ver [Configuración](#configuración)) y luego:

```bash
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

## Configuración

Toda la configuración real vive en `~/.config/zsh/load.zsh` — el `.zshrc` es mínimo por diseño.

Los overrides específicos de cada máquina van en `~/.config/zsh/local.zsh` — este archivo **no se versiona**. El instalador crea una plantilla automáticamente.

El override más importante es `HUNTING_HOME`:

```zsh
# ~/.config/zsh/local.zsh
export HUNTING_HOME="$HOME/Library/Mobile Documents/com~apple~CloudDocs/02_PROFESIONAL/bugbounty"
```

Si no se define aquí, el fallback es `~/targets` — funciona, pero no apunta a iCloud.

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

Outputs principales:

```text
recon/subdomains.txt
http/live.txt
http/httpx.jsonl
http/httpx_table.tsv
http/urls.txt
http/urls_clean.txt
http/api_candidates.txt
js/files.txt
fuzz/urls_with_params.txt
fuzz/params.txt
meta/*.json
```

### Programa multi-dominio

Útil cuando un programa privado/público tiene varios scopes web pero quieres un único workspace.

```bash
program-init example
cd "$HUNTING_HOME/targets/example"
```

Importar brief:

```bash
nvim in/brief.txt
program-import-brief example in/brief.txt
```

Validar scope antes del recon:

```bash
nvim in/roots.txt
nvim in/scope-web.txt
nvim in/out-of-scope.txt
```

Recon multi-dominio:

```bash
scope-program example
webmap example
paramhunt-v2 example
```

`scope-program` lee `in/roots.txt` y mantiene todo en `$HUNTING_HOME/targets/example/` — sin subcarpetas por dominio.

Outputs esperados:

```text
recon/subdomains.txt
recon/roots/<root>.subdomains.txt
http/live.txt
http/httpx.jsonl
http/httpx_table.tsv
http/roots/<root>.live.txt
meta/scope-program.json
meta/roots/<root>.scope.json
```

### Validación

```bash
type -a program-init scope-program program-import-brief scope webmap mktarget subscan
```

Todo debería resolverse a `~/.local/bin/*`. `tips` es una función de shell.

---

## Navegación rápida

```bash
cdh        # cd $HUNTING_HOME
cdt        # cd $HUNTING_HOME/targets
cdn        # cd $HUNTING_HOME/notes
cds        # cd $HUNTING_HOME/scripts
```

---

## Proxy (Burp Suite)

```bash
setproxy      # activa http_proxy + https_proxy → 127.0.0.1:8080
              # también define no_proxy=localhost,127.0.0.1 para que
              # las herramientas CLI no enruten tráfico local por Burp
unsetproxy    # elimina las tres variables
```

---

## Cheatsheet interactivo

```bash
bbref
```

Abre un cheatsheet de comandos de bug bounty organizado por categoría (setup, recon, http, fuzz, params, JS, secrets, wordlists, tmux, findings). ENTER copia el snippet seleccionado al portapapeles.

```bash
tips
```

Cheatsheet de shell general (git, proxy, navegación). También se abre con fzf + copia.

---

## Utilidades generales

| Comando | Comportamiento |
|---|---|
| `grh` | `git reset --hard HEAD` — muestra el diff y pide confirmación antes de ejecutar |
| `cat` | Usa `bat --style=plain` automáticamente si está instalado (resaltado de sintaxis, sin paginación, sin decoraciones) |
| `myip` | Prueba tres servicios con timeout de 3s cada uno |
| `localip` | Funciona en macOS (`en0`) y Linux (`ip addr`) |
| `git wip` | Solo stagea ficheros ya rastreados (`add -u`), nunca ficheros nuevos sin seguimiento |
| `setproxy` / `unsetproxy` | Activa/desactiva proxy Burp con `no_proxy` para localhost |
| `purge_outputs` | Elimina directorios `output/` y ficheros `.log` — pide confirmación |

---

## Tools

```bash
bash ~/.dotfiles/tools/install-tools.sh   # instala Go tools (ProjectDiscovery, tomnomnom)
bash ~/.dotfiles/tools/update-tools.sh    # las actualiza
```

Las dependencias de Homebrew se gestionan desde `brew/Brewfile` — fuente de verdad para macOS:

```bash
brew bundle --file=~/.dotfiles/brew/Brewfile
```

---

## Contenedor offsec (opcional)

```bash
offsec-build    # construye la imagen Debian
offsec-up       # arranca el contenedor (alias: offsec-start)
offsec-shell    # entra en zsh dentro del contenedor
offsec          # offsec-init + exec en un comando
offsec-rebuild  # para → elimina → reconstruye → arranca
```

El contenedor monta `$HUNTING_HOME` en `/work`.

---

## Auditoría de dotfiles

```bash
bash ~/.dotfiles/audit_dotfiles.sh ~/.dotfiles
```

Comprueba: conflictos de merge, CRLF, bashismos en scripts `sh`, errores de sintaxis bash/zsh, shellcheck (requiere `shellcheck` — incluido en el Brewfile), y funciones zsh duplicadas entre todos los ficheros cargados desde `load.zsh`.

---

## Estructura

```text
~/.dotfiles/
├── zsh/
│   ├── .zshrc                    # mínimo — carga load.zsh
│   └── .config/zsh/
│       ├── load.zsh              # punto de entrada modular
│       ├── aliases-general.zsh   # git, navegación, sistema
│       ├── bug-bounty.zsh        # workspace de hunting
│       └── bbref.zsh             # cheatsheet interactivo de bug bounty
├── tmux/
├── nvim/
├── ghostty/
├── scripts/
│   └── .local/bin/               # todos los scripts de hunting
├── vendor/
│   └── shell-utils/zsh/          # helpers cross-platform
├── brew/
│   └── Brewfile                  # fuente de verdad de paquetes macOS
├── tools/
│   ├── install-tools.sh
│   └── update-tools.sh
├── audit_dotfiles.sh
└── install.sh
```

Gestionado con [GNU Stow](https://www.gnu.org/software/stow/) — symlinks limpios y reversibles.

---

## Uso ético

Solo en sistemas con permiso.

---

## Licencia

MIT
