# dotfiles

Mis dotfiles para macOS orientados a bug bounty web/API.

## Qué hay aquí

### En el host (macOS)
- Zsh con aliases para ofensiva
- Brewfile para reproducir el setup
- Configs de Git, tmux, nvim
- Scripts para Raycast

### Contenedores
- **Debian Toolbox** → mi entorno diario (httpx, ffuf, curl, jq, Python)
- **Exegol** → cuando necesito herramientas más pesadas
- **Kali VM** → para cosas de AD o red interna

### Workspace
- Template de carpetas para organizar targets
- Sistema de notas rápidas
- Templates de Python venv

## Instalación

```bash
git clone https://github.com/theoffsecgirl/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Bootstrap (instala Homebrew + paquetes)
./macos/bootstrap-macos.sh

# Aplicar configs
stow -t "$HOME" zsh git tmux nvim scripts
source ~/.zshrc

# Crear workspace de hunting
cp -r hunting-template ~/hunting

# Tu nombre y email en Git
nvim ~/.gitconfig

# Build del contenedor
cd containers/debian-toolbox
docker compose build

# Configurar Raycast
chmod +x ~/.local/bin/offsec-*
# Raycast → Settings → Script Commands → Add Directory → ~/.local/bin
```

## Uso normal

### Arrancar
```bash
# Desde Raycast: Cmd+Space → "Start Offsec Toolbox"
# O desde terminal:
offsec-up && offsec
```

### Primera vez dentro del contenedor
```bash
cd /root/.dotfiles
stow -t "$HOME" zsh git tmux
source ~/.zshrc
```

### Aliases que uso
```bash
cdh              # ir a ~/hunting
cdt              # ir a ~/hunting/targets
cdn              # ir a ~/hunting/notes

h                # httpx básico
hh               # httpx con detección de tech
subenum dom.com  # enum de subdominios
probe urls.txt   # probar lista de URLs

note "texto"     # nota rápida con timestamp
notes            # ver notas de hoy

offsec           # entrar al contenedor
offsec-restart   # reiniciar contenedor
```

## Docs

Si quieres ver todo el setup explicado paso a paso, revisa [SETUP-BUGBOUNTY.md](SETUP-BUGBOUNTY.md).

## Estructura

```
~/.dotfiles/
├── containers/debian-toolbox/    # el contenedor principal
├── scripts/.local/bin/           # scripts para Raycast
├── hunting-template/             # template del workspace
├── zsh/.config/zsh/
│   └── bug-bounty.zsh           # aliases ofensivos
├── macos/                        # bootstrap macOS
├── brew/                         # Brewfile
├── git/
├── tmux/
├── nvim/
└── SETUP-BUGBOUNTY.md           # docs completas
```

## Aplicar solo algunas cosas

```bash
cd ~/.dotfiles
stow -t "$HOME" zsh       # solo zsh
stow -t "$HOME" git       # solo git
stow -t "$HOME" scripts   # solo scripts
```

## Personalizar

- Aliases propios → `~/.config/zsh/local.zsh` (no se sube a git)
- Git config → edita `~/.gitconfig`
- Más herramientas → edita `containers/debian-toolbox/Dockerfile` y rebuild

## Filosofía

No acumular herramientas, reducir fricción cognitiva.

- Web/API → Debian Toolbox (la uso el 80% del tiempo)
- Recon pesado → Exegol (puntual)
- AD/pivoting → Kali VM (específico)

Cada cosa en su sitio, sin mezclar.
