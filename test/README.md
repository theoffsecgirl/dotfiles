# Tests

Suite de pruebas con [bats-core](https://github.com/bats-core/bats-core).

## Instalación de bats

```bash
# macOS
brew install bats-core

# Linux (cualquier distro)
git clone https://github.com/bats-core/bats-core.git /tmp/bats-core
sudo /tmp/bats-core/install.sh /usr/local
```

## Ejecución

```bash
# Todos los tests
bats test/

# Solo zsh
bats test/test_zsh.bats

# Solo dotfiles-ref (cobertura de cheatsheet)
bats test/test_dotfiles-ref.bats

# Con output detallado
bats --verbose-run test/

# Modo TAP (para CI)
bats --formatter tap test/
```

## Tests disponibles

### `test_zsh.bats`
Verificación de sintaxis zsh:
- `load.zsh`, `aliases-builtin.zsh`
- `$PLATFORM` se define correctamente al sourcear

### `test_dotfiles-ref.bats`
Salud básica del cheatsheet:
- `dotfiles-ref.zsh` tiene sintaxis zsh válida.
- Entradas críticas (`program-import-brief`, `tmux-recon`) existen en el cheatsheet.

## Convenciones

- Cada test usa un `$HOME` temporal limpio (`mktemp -d`) para no contaminar el sistema real.
