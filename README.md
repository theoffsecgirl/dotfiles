# theoffsecgirl/dotfiles (Mac-first)

Dotfiles para macOS (y compatibles con Linux) pensados para **bug bounty / ofensiva**.

## Qué incluye
- **Zsh** modular (carga tu núcleo `vendor/shell-utils`)
- **Brewfile** reproducible
- **Git** (`.gitconfig` + global ignore)
- **tmux** básico
- Estructura para **nvim** (añade tu config en `nvim/.config/nvim`)

## Instalación (macOS)
```bash
git clone https://github.com/theoffsecgirl/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./macos/bootstrap-macos.sh
```

## Aplicar solo módulos (stow)
```bash
cd ~/.dotfiles
stow -t "$HOME" zsh
stow -t "$HOME" git
stow -t "$HOME" tmux
```

## Notas
- Cambia `git/.gitconfig` (nombre/email).
- Overrides locales (no versionados): `~/.config/zsh/local.zsh`
