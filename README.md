# theoffsecgirl/dotfiles

Dotfiles para macOS pensados para **bug bounty y ofensiva web/API**.

## 🎯 Stack incluido

### 🖥️ Host (macOS)
- **Zsh** modular con aliases ofensivos
- **Brewfile** reproducible
- **Git** config + global ignore
- **tmux** básico
- **nvim** estructura base
- **Scripts Raycast** para orquestación

### 🐳 Contenedores
- **Debian Toolbox** - entorno diario (httpx, ffuf, curl, jq, Python)
- Integración con **Exegol** para tooling pesado
- Soporte **Kali VM** (UTM) para AD/red interna

### 📁 Workspace
- Template `hunting/` con estructura organizada
- Python venv templates
- Sistema de notas rápidas

## 🚀 Instalación rápida

```bash
# Clonar
git clone https://github.com/theoffsecgirl/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Bootstrap macOS (Homebrew + configs)
./macos/bootstrap-macos.sh

# Aplicar dotfiles
stow -t "$HOME" zsh git tmux nvim scripts

# Recargar shell
source ~/.zshrc

# Crear workspace
cp -r hunting-template ~/hunting

# Configurar Git (edita con tus datos)
nvim ~/.gitconfig

# Build contenedor toolbox
cd containers/debian-toolbox
docker compose build

# Configurar Raycast
chmod +x ~/.local/bin/offsec-* ~/.local/bin/exegol-start ~/.local/bin/kali-start
# Raycast → Settings → Script Commands → Add Directory → ~/.local/bin
```

## 💡 Uso diario

### Arrancar entorno
```bash
# Desde Raycast (Cmd+Space)
"Start Offsec Toolbox" → "Offsec Shell"

# O desde terminal
offsec-up && offsec
```

### Dentro del contenedor (primera vez)
```bash
cd /root/.dotfiles
stow -t "$HOME" zsh git tmux
source ~/.zshrc
```

### Aliases útiles
```bash
# Navegación
cdh              # cd ~/hunting
cdt              # cd ~/hunting/targets
cdn              # cd ~/hunting/notes
cds              # cd ~/hunting/scripts

# HTTP/Recon
h                # httpx silencioso
hh               # httpx + tech detect
subenum dom.com  # subdomain enum
probe urls.txt   # probar lista URLs

# Notas
note "texto"     # nota rápida
notes            # ver notas de hoy

# Contenedor
offsec           # shell directo
offsec-restart   # restart
offsec-rebuild   # rebuild
```

## 📚 Documentación completa

Revisa **[SETUP-BUGBOUNTY.md](SETUP-BUGBOUNTY.md)** para:
- Arquitectura detallada
- Workflow recomendado
- Troubleshooting
- Personalización

## 🗂️ Estructura

```
~/.dotfiles/
├── containers/
│   └── debian-toolbox/       # Contenedor principal
├── scripts/.local/bin/       # Scripts Raycast
├── hunting-template/         # Template workspace
├── zsh/.config/zsh/
│   └── bug-bounty.zsh       # Aliases ofensivos
├── macos/                    # Bootstrap macOS
├── brew/                     # Brewfile
├── git/                      # Git config
├── tmux/                     # tmux config
├── nvim/                     # nvim estructura
└── SETUP-BUGBOUNTY.md       # Docs completas
```

## ⚙️ Aplicar módulos individuales

```bash
cd ~/.dotfiles
stow -t "$HOME" zsh       # Solo zsh
stow -t "$HOME" git       # Solo git
stow -t "$HOME" tmux      # Solo tmux
stow -t "$HOME" scripts   # Scripts Raycast
```

## 🔧 Personalización

- **Aliases propios**: `~/.config/zsh/local.zsh` (no se versiona)
- **Git config**: edita `~/.gitconfig` con tu nombre/email
- **Herramientas extra**: edita `containers/debian-toolbox/Dockerfile`

## 🎯 Filosofía

**Reducir fricción cognitiva, no acumular herramientas.**

- **Web/API** → Debian Toolbox (80% del tiempo)
- **Recon masivo** → Exegol (puntual)
- **AD/pivoting** → Kali VM (específico)

Sin mezclar. Sin ruido.
