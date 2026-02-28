# Bug Bounty Operational Stack Setup

Guía completa para montar tu entorno de bug bounty con los dotfiles.

## 🎯 Arquitectura

```
macOS Host
├── OrbStack / Docker Desktop
├── Raycast (orquestación)
├── Ghostty (terminal)
└── dotfiles
    |
    ├── Debian Toolbox (80% trabajo diario)
    │   └── httpx, ffuf, curl, jq, python
    |
    ├── Exegol (tooling pesado puntual)
    │   └── nuclei, subfinder, masivo
    |
    └── UTM Kali VM (AD, pivoting, exploit dev)
```

## 📦 Prerequisitos

### macOS Host
```bash
# Instalar Homebrew si no lo tienes
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Instalar dependencias base
brew install git stow

# Docker (elige uno)
brew install orbstack     # Recomendado (más ligero)
# O Docker Desktop
brew install --cask docker

# Raycast
brew install --cask raycast

# Ghostty (opcional, pero recomendado)
brew install --cask ghostty
```

### Python tools (opcional)
```bash
# Exegol (para tooling pesado)
pipx install exegol
```

## 🚀 Instalación

### 1. Clonar dotfiles
```bash
git clone https://github.com/theoffsecgirl/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

### 2. Aplicar dotfiles base
```bash
# Bootstrap macOS (instala Brewfile, configura sistema)
./macos/bootstrap-macos.sh

# Aplicar configs
stow -t "$HOME" zsh
stow -t "$HOME" git
stow -t "$HOME" tmux
stow -t "$HOME" nvim
stow -t "$HOME" scripts

# Recargar shell
source ~/.zshrc
```

### 3. Configurar Git
Edita `~/.gitconfig` con tu nombre y email:
```bash
nvim ~/.gitconfig
```

### 4. Crear estructura de hunting
```bash
cp -r ~/.dotfiles/hunting-template ~/hunting
```

### 5. Build contenedor Debian Toolbox
```bash
cd ~/.dotfiles/containers/debian-toolbox
docker compose build
```

### 6. Configurar Raycast scripts
```bash
# Dar permisos de ejecución
chmod +x ~/.local/bin/offsec-*
chmod +x ~/.local/bin/exegol-start
chmod +x ~/.local/bin/kali-start

# En Raycast:
# Settings → Extensions → Script Commands → Add Directory
# Añadir: ~/.local/bin
```

## 🎮 Uso diario

### Flujo normal (80% del tiempo)

#### Opción 1: Raycast (recomendado)
1. `Cmd + Space` → "Start Offsec Toolbox"
2. `Cmd + Space` → "Offsec Shell"

#### Opción 2: Terminal directo
```bash
# Arrancar contenedor
offsec-up

# Entrar al shell
offsec

# Dentro del contenedor, aplicar dotfiles la primera vez
cd /root/.dotfiles
stow -t "$HOME" zsh git tmux
source ~/.zshrc
```

### Workspace dentro del contenedor
```bash
# Estructura montada en /work
cd /work

# Navegar rápido (aliases)
cdh    # ~/hunting
cdt    # ~/hunting/targets
cdn    # ~/hunting/notes
cds    # ~/hunting/scripts

# Trabajo en un target
cd /work/targets/example.com
mkdir recon vulns

# Enumeración
echo "example.com" | httpx -silent -tech-detect -status-code

# Fuzzing
ffuf -u https://example.com/FUZZ -w /usr/share/wordlists/common.txt -c -mc all -fc 404

# Scripts Python
cd /work/scripts
python3 -m venv venv
source venv/bin/activate
pip install httpx requests
```

### Aliases útiles (ya incluidos)
```bash
# HTTP
h        # httpx silencioso
hh       # httpx con tech detect
hhh      # httpx full info

# Fuzzing
f        # ffuf con colores

# Recon
subenum domain.com    # Subdomain enum rápido
probe urls.txt        # Probar lista de URLs

# Notas
note "found XSS in /search"   # Nota rápida
notes                         # Ver notas de hoy

# Contenedor
offsec              # Shell directo
offsec-restart      # Restart
offsec-rebuild      # Rebuild completo
```

### Tooling pesado (Exegol)
```bash
# Desde Raycast
Cmd + Space → "Start Exegol"

# O desde terminal
exegol-start

# Uso puntual, no vivas aquí
exegol start web
nuclei -l targets.txt -t ~/nuclei-templates/
exegol stop web
```

### VM Kali (red interna, AD, exploit dev)
```bash
# Desde Raycast
Cmd + Space → "Start Kali VM"

# O desde terminal
kali-start
```

## 🔧 Personalización

### Añadir herramientas al toolbox
Edita `~/.dotfiles/containers/debian-toolbox/Dockerfile`:
```dockerfile
# Ejemplo: añadir nuclei
RUN go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
```

Rebuild:
```bash
offsec-rebuild
```

### Aliases personalizados
Edita `~/.config/zsh/local.zsh` (no se versiona):
```bash
alias myalias='my command'
```

### Python tools globales en toolbox
Dentro del contenedor:
```bash
pip3 install --user tool-name
```

## 📚 Estructura de archivos

```
~/.dotfiles/
├── containers/
│   └── debian-toolbox/        # Contenedor principal
│       ├── Dockerfile
│       ├── docker-compose.yml
│       └── README.md
├── scripts/.local/bin/
│   ├── offsec-up              # Raycast: arrancar
│   ├── offsec-shell           # Raycast: shell
│   ├── exegol-start           # Raycast: Exegol
│   └── kali-start             # Raycast: Kali VM
├── hunting-template/          # Template workspace
│   ├── targets/
│   ├── notes/
│   ├── scripts/
│   └── templates/
├── zsh/.config/zsh/
│   └── bug-bounty.zsh         # Aliases ofensivos
└── SETUP-BUGBOUNTY.md         # Esta guía

~/hunting/                     # Tu workspace real
├── targets/
│   └── example.com/
│       ├── recon/
│       ├── vulns/
│       └── notes.md
├── notes/
├── scripts/
└── templates/
```

## 🐛 Troubleshooting

### Contenedor no arranca
```bash
cd ~/.dotfiles/containers/debian-toolbox
docker compose logs
```

### Dotfiles no se aplican en contenedor
```bash
# Dentro del contenedor
cd /root/.dotfiles
stow -t "$HOME" zsh git tmux
source ~/.zshrc
```

### Raycast no encuentra scripts
```bash
# Verificar permisos
ls -la ~/.local/bin/offsec-*

# Si no son ejecutables
chmod +x ~/.local/bin/offsec-*

# Raycast: Settings → Extensions → Script Commands → Reload
```

### httpx/ffuf no encontrados en contenedor
```bash
# Verificar PATH
echo $PATH | grep go

# Si no está, añadir a ~/.zshrc:
export PATH="/usr/local/go/bin:/root/go/bin:$PATH"
```

## 🎓 Workflow recomendado

### Día típico
1. **Mañana**: `Cmd+Space` → "Start Offsec Toolbox"
2. **Recon**: dentro del contenedor, `cdh && cd targets/newdomain.com`
3. **Enum**: `subenum newdomain.com | tee subs.txt`
4. **Probe**: `probe subs.txt`
5. **Notas**: `note "found interesting endpoint /api/v2/admin"`
6. **Testing**: scripts Python en `/work/scripts` con venv
7. **Tarde**: si necesitas tooling pesado → Exegol

### No mezclar entornos
- **Web/API** → Debian toolbox
- **Recon masivo** → Exegol
- **Red interna/AD** → Kali VM

## 🔐 Seguridad

- SSH keys montadas read-only
- No puertos expuestos por defecto
- Contenedor efímero (rebuild fácil)
- Workspace separado del contenedor
- No root en host

## 📖 Recursos

- [Exegol Docs](https://exegol.readthedocs.io/)
- [OrbStack](https://orbstack.dev/)
- [Raycast Script Commands](https://github.com/raycast/script-commands)
- [httpx](https://github.com/projectdiscovery/httpx)
- [ffuf](https://github.com/ffuf/ffuf)

---

**¿Dudas?** Abre un issue en el repo o revisa la documentación de cada herramienta.
