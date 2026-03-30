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
bats tests/

# Solo scripts
bats tests/test_scripts.bats

# Solo zsh
bats tests/test_zsh.bats

# Con output detallado
bats --verbose-run tests/

# Modo TAP (para CI)
bats --formatter tap tests/
```

## Tests disponibles

### `test_scripts.bats`
Smoke tests para `scripts/.local/bin/`:
- `jwt-decode` — sin args, token real
- `fuzzdirs` — sin args, sin `$WORDLISTS`, sin wordlist
- `paramhunt` — sin args, sin `urls.txt`
- `webmap` — sin args, sin `live.txt`
- `race-run` — sin args, fichero inexistente
- `mktarget` — sin args, creación de estructura
- `scope` — sin args, check de dependencias
- `subscan` — sin args

### `test_zsh.bats`
Verificación de sintaxis zsh:
- `load.zsh`, `aliases-builtin.zsh`, `aliases-bugbounty.zsh`
- `functions-bugbounty.zsh`, `bug-bounty.zsh`, `wrapper-exegol.zsh`
- `$PLATFORM` se define correctamente al sourcear

## Convenciones

- Cada test usa un `$HOME` temporal limpio (`mktemp -d`) para no contaminar el sistema real.
- Los tests de scripts solo verifican comportamiento de error (smoke test), no ejecutan herramientas externas (`subfinder`, `httpx`, etc.).
