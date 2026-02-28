# Debian Toolbox - Bug Bounty Container

Contenedor ligero para trabajo diario de bug bounty web/API.

## ¿Qué incluye?

### Herramientas pinneadas
- **httpx** - HTTP toolkit
- **ffuf** - Fuzzer rápido
- **curl** / **httpie** / **jq** - Manipulación HTTP/JSON

### Entorno
- Python 3 + venv
- Go runtime
- Neovim + tmux
- Zsh + starship prompt
- Tus dotfiles montados

## Uso

### Build
```bash
cd ~/.dotfiles/containers/debian-toolbox
docker compose build
```

### Arrancar
```bash
docker compose up -d
```

### Shell interactivo
```bash
docker exec -it offsec-toolbox zsh
```

### Parar
```bash
docker compose down
```

## Montajes

- `~/hunting` → `/work` (persistente)
- `~/.dotfiles` → `/root/.dotfiles` (read-only)
- `~/.ssh` → `/root/.ssh` (read-only)
- `~/.gitconfig` → `/root/.gitconfig` (read-only)

## Aplicar dotfiles dentro del contenedor

```bash
cd /root/.dotfiles
stow -t "$HOME" zsh git tmux
source ~/.zshrc
```

## Añadir herramientas custom

Edita el `Dockerfile` y añade en la sección correspondiente.
Luego rebuild:

```bash
docker compose down
docker compose build --no-cache
docker compose up -d
```
