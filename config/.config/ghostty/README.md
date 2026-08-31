# Ghostty Terminal Config

Config optimizada para bug bounty con Ghostty.

## Instalar

```bash
brew install --cask ghostty
```

## Aplicar config

```bash
cd ~/.dotfiles
stow -t "$HOME" ghostty
```

## Font (recomendada)

```bash
brew install --cask font-jetbrains-mono-nerd-font
```

Si no tienes Nerd Fonts, cambia en `config`:

```
font-family = "SF Mono"
```

## Keybinds

### Básicos
- `Cmd+T` - nueva tab
- `Cmd+W` - cerrar tab
- `Cmd+N` - nueva ventana
- `Cmd+H` - nueva tab en ~/hunting

### Splits
- `Ctrl+Shift+\` - split vertical
- `Ctrl+Shift+-` - split horizontal

### Clipboard
- `Ctrl+Shift+C` - copiar
- `Ctrl+Shift+V` - pegar

## Theme

Usa Catppuccin Mocha por defecto. Para cambiar:

```
theme = dark:tokyo-night
# O
theme = light:solarized-light
```

Ver temas disponibles:
```bash
ghostty +list-themes
```

## Personalización

Edita `~/.config/ghostty/config` directamente.

Docs: https://ghostty.org/docs
