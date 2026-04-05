# Bug Bounty Operational Stack Setup

Guía detallada para montar el entorno completo desde cero.

---

## Arquitectura

```text
macOS / Linux Host
├── terminal
├── tmux
├── zsh + dotfiles
└── Docker / Colima
    └── Debian Toolbox
        ├── subfinder
        ├── httpx
        ├── katana
        ├── unfurl
        ├── ffuf
        ├── jq
        └── python3
```

---

## Instalación automática

```bash
git clone https://github.com/theoffsecgirl/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
offsec-bootstrap
hunt-doctor
```

`install.sh` instala dependencias base, aplica stow y crea `~/hunting`.

---

## Instalación manual

### 1. Clonar dotfiles
```bash
git clone https://github.com/theoffsecgirl/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

### 2. Instalar dependencias
#### macOS
```bash
brew bundle --file=brew/Brewfile
```

#### Linux
```bash
sudo apt install -y stow zsh tmux neovim fzf bat ripgrep fd-find unzip jq
```

### 3. Aplicar dotfiles
```bash
stow -t "$HOME" zsh git tmux nvim scripts
source ~/.zshrc
```

### 4. Bootstrap y validación
```bash
offsec-bootstrap
hunt-doctor
```

### 5. Contenedor
```bash
cd ~/.dotfiles/containers/debian-toolbox
docker compose build
offsec-up
offsec-shell
offsec-bootstrap
hunt-doctor
```

---

## Modelo operativo

### Host
Usa el host para:
- Git
- dotfiles
- Claude Code
- edición y documentación

### Contenedor
Usa el contenedor para:
- recon
- crawling
- extracción de parámetros
- fuzzing

---

## Uso diario

### Flujo normal
```bash
offsec-up
offsec-shell
offsec-bootstrap
hunt-doctor

cdh
cdt
note "hallazgo"
notes
```

### Recon
#### En el contenedor
```bash
mktarget example.com
scope-v2 example.com
webmap-v2 example.com
paramhunt-v2 example.com
```

#### En el host
```bash
claude-recon example.com
claude-hypotheses example.com
```

---

## Artefactos generados

### `scope-v2`
- `recon/subdomains.txt`
- `http/live.txt`
- `http/httpx.jsonl`
- `http/httpx_table.tsv`
- `meta/scope.json`

### `webmap-v2`
- `http/katana.jsonl`
- `http/urls.txt`
- `http/urls_clean.txt`
- `http/api_candidates.txt`
- `http/graphql.txt`
- `js/files.txt`
- `meta/webmap.json`

### `paramhunt-v2`
- `fuzz/params.txt`
- `fuzz/params_by_url.tsv`
- `fuzz/sensitive_params.txt`
- `fuzz/params_by_host.jsonl`
- `meta/paramhunt.json`

### Claude
- `ai/recon.json`
- `ai/hypotheses.json`

---

## Troubleshooting

### Los scripts no aparecen en PATH
```bash
offsec-bootstrap
hunt-doctor
```

### En contenedor faltan scripts
```bash
/root/.dotfiles/scripts/.local/bin/offsec-bootstrap
/root/.dotfiles/scripts/.local/bin/hunt-doctor
```

### `claude` no existe en el contenedor
Es esperado. Ejecuta:
- recon en contenedor
- `claude-recon` y `claude-hypotheses` en host

### Stow da conflictos en host
Usa bootstrap después de instalar:
```bash
offsec-bootstrap
```

---

## Seguridad

- `~/.dotfiles` montado en contenedor como read-only
- SSH keys read-only
- identidad Git en `~/.gitconfig.local`
- workspace en `~/hunting` montado en `/work`

---

## Recursos

- [ProjectDiscovery tools](https://github.com/projectdiscovery)
- [Exegol Docs](https://exegol.readthedocs.io/)
- [bats-core](https://github.com/bats-core/bats-core)
