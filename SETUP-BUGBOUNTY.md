# Bug Bounty Operational Stack Setup

Guía detallada para montar el entorno completo desde cero.

---

## 🎯 Arquitectura

```
macOS / Linux Host
├── Ghostty (terminal) o cualquier terminal
├── tmux (sesiones)
├── zsh + dotfiles
└── Docker / Colima
    |
    ├── Debian Toolbox (80% trabajo diario)
    │   └── httpx, ffuf, subfinder, nuclei, anew, starship
    |
    ├── Exegol (tooling pesado puntual)
    └── Kali VM (AD, pivoting, exploit dev)
```

---

## 📦 Instalación automática (recomendado)

```bash
git clone https://github.com/theoffsecgirl/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

`install.sh` detecta el sistema y hace todo: instala dependencias, aplica stow, crea workspace.

---

## 🔧 Instalación manual paso a paso

### 1. Clonar dotfiles
```bash
git clone https://github.com/theoffsecgirl/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

### 2. macOS: Homebrew + Brewfile
```bash
# Instalar Homebrew si no lo tienes
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Instalar todo el stack (base + ProjectDiscovery + containers + Go)
brew bundle --file=brew/Brewfile
```

### 3. Linux: dependencias base
```bash
# Debian/Ubuntu
sudo apt install -y stow zsh tmux neovim fzf bat ripgrep fd-find

# Arch
sudo pacman -S --noconfirm stow zsh tmux neovim fzf bat ripgrep fd
```

### 4. Aplicar dotfiles con stow
```bash
stow -t "$HOME" zsh git tmux nvim scripts
source ~/.zshrc
```

### 5. Configurar identidad Git

La identidad personal **no se versiona**. Créala en `~/.gitconfig.local`:

```bash
cat > ~/.gitconfig.local << 'EOF'
[user]
    name  = Tu Nombre
    email = tu@email.com
EOF
```

> `~/.gitconfig` incluye automáticamente `~/.gitconfig.local` si existe.

### 6. Crear workspace de hunting
```bash
cp -r ~/.dotfiles/hunting-template ~/hunting
# o deja que install.sh lo cree: ~/hunting/{targets,notes,scripts}
```

### 7. Build contenedor Debian Toolbox
```bash
cd ~/.dotfiles/containers/debian-toolbox
docker compose build
```

El container incluye por defecto: `httpx`, `ffuf`, `subfinder`, `nuclei`, `anew`, `starship`, `zsh`, `tmux`, `nvim`, `jq`, `python3`.

Actualizar una herramienta sin editar el Dockerfile:
```bash
docker compose build --build-arg HTTPX_VERSION=1.6.11
```

### 8. Raycast (macOS, opcional)
```bash
brew install --cask raycast

# Los scripts de ~/.local/bin/ ya tienen permiso de ejecución
# En Raycast: Settings → Extensions → Script Commands → Add Directory → ~/.local/bin
```

---

## 🎮 Uso diario

### Flujo normal

```bash
# Arrancar contenedor
offsec-up        # o: docker compose -f ~/.dotfiles/containers/debian-toolbox/docker-compose.yml up -d
offsec-shell     # shell dentro del container

# Dentro del container (workspace en /work)
cdh              # cd ~/hunting
cdt              # cd ~/hunting/targets
note "hallazgo"  # nota con timestamp
notes            # últimas 20 notas de hoy
```

### Flujo de recon completo

```bash
# 1. Crear estructura del target
mktarget example.com

# 2. Subdominios + hosts vivos
scope example.com

# 3. Crawl URLs y JS
webmap example.com

# 4. Extraer parámetros únicos
paramhunt example.com

# 5. Fuzz de directorios
fuzzdirs https://example.com

# 6. Tabla de endpoints vivos
subscan example.com
```

📖 Referencia completa de comandos → [CHEATSHEET.md](CHEATSHEET.md)

---

## 🐛 Troubleshooting

### Contenedor no arranca
```bash
cd ~/.dotfiles/containers/debian-toolbox
docker compose logs
docker compose down && docker compose up -d
```

### Dotfiles no se aplican en el container
El container monta `~/.dotfiles` en `/root/.dotfiles:ro`.
Dentro del container:
```bash
cd /root/.dotfiles && stow -t "$HOME" zsh git tmux && source ~/.zshrc
```

### Git no tiene identidad dentro del container
El container monta `~/.gitconfig.local`. Si no existe en el host:
```bash
# En el host
cat > ~/.gitconfig.local << 'EOF'
[user]
    name  = Tu Nombre
    email = tu@email.com
EOF
# Reiniciar el container para que monte el fichero
docker compose restart
```

### Herramienta no encontrada en el container
Las herramientas están en `/usr/local/bin/`. Verifica:
```bash
which httpx subfinder nuclei ffuf anew
```
Si falta alguna, rebuild con la versión deseada:
```bash
docker compose build --build-arg SUBFINDER_VERSION=2.6.7
```

### stow da conflictos
```bash
# Ver qué conflictos hay sin aplicar
stow -nv -t "$HOME" zsh

# Forzar (sobreescribe symlinks existentes)
stow --adopt -t "$HOME" zsh && git checkout zsh/
```

### bats no disponible
```bash
brew install bats-core          # macOS
sudo apt install bats           # Debian/Ubuntu
```

---

## 🔐 Seguridad del entorno

- SSH keys montadas **read-only** en el container
- Identidad git en `~/.gitconfig.local` — no versionada
- `tmux-resurrect` sin captura de contenido de panes (evita persistir tokens)
- No puertos expuestos por defecto en docker-compose
- Workspace separado del filesystem del container (`~/hunting` → `/work`)

---

## 📚 Recursos

- [ProjectDiscovery tools](https://github.com/projectdiscovery)
- [Exegol Docs](https://exegol.readthedocs.io/)
- [OrbStack](https://orbstack.dev/) (alternativa ligera a Docker Desktop)
- [bats-core](https://github.com/bats-core/bats-core)
- [tmux Plugin Manager](https://github.com/tmux-plugins/tpm)

---

**¿Dudas?** Abre un issue en el repo.
