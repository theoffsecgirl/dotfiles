<div align="center">

![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20Linux-lightgrey?style=flat-square)
![Shell](https://img.shields.io/badge/Shell-zsh-brightgreen?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-red?style=flat-square)

**Dotfiles personales**
*by [TheOffSecGirl](https://github.com/theoffsecgirl)*

> 🇬🇧 [English version](README.md)

</div>

## Qué es esto

Un setup de dotfiles orientado a macOS y terminal, gestionado con [GNU Stow](https://www.gnu.org/software/stow/) y un `Makefile`. Cubre configuración de shell (zsh), Neovim, tmux, Ghostty y git.

El pipeline de bug bounty / pentesting (scripts de recon, containers, plantilla de workspace de hunting) vivía antes en este repo. Se ha migrado a un repo separado y privado. Este repo ya no lo contiene ni depende de él.

## Instalación

> ⚠️ **¿Mac recién formateada o nueva (sin Homebrew)?** Salta directamente a `make macos` más abajo — `make install` solo fallará con `stow: No such file or directory` porque Homebrew y Stow aún no están instalados.

```bash
git clone git@github.com:theoffsecgirl/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
make install
exec zsh
```

`make install` ejecuta `stow -t $HOME runcom config bin` y `brew bundle --file=install/Brewfile`. Úsalo solo si Homebrew ya está instalado.

Para simular los cambios de Stow sin aplicarlos:

```bash
stow -n -v -t "$HOME" runcom config bin
```

En una Mac nueva, `make macos` instala Homebrew por sí mismo y luego delega en `make install` — **usa este primero en una máquina nueva**:

```bash
make macos
```

La configuración específica de cada máquina vive en `~/.config/zsh/local.zsh`, que no se versiona.

## Targets del Makefile

```bash
make help     # lista todos los targets
make install  # stow runcom/config/bin + brew bundle
make macos    # bootstrap de una Mac nueva (Homebrew + make install)
make test     # corre la suite de tests con bats
make update   # brew update/upgrade + re-aplica stow
make link     # solo re-aplica los symlinks de stow (tras un git pull)
make clean    # elimina los symlinks creados por stow
make edit     # abre el repo en $EDITOR
```

## Comandos útiles

```bash
dotfiles-ref   # cheatsheet interactivo de este setup de dotfiles
tips           # cheatsheet interactivo de aliases/funciones de shell
tmux-popup     # terminal flotante en tmux (popup)
tmux-sessionizer  # selector rápido de proyectos/sesiones con fzf
theme          # cambiar el tema de la terminal (ver "Temas")

mkproject nombre dir1,dir2,dir3  # crear carpeta de proyecto con subcarpetas
ezsh           # abrir el directorio zsh de los dotfiles en $EDITOR
reloadzsh      # relanzar una sesión de zsh limpia
showaliases    # listar todos los aliases activos
extra archivo.tar.gz  # descomprimir cualquier formato (tar/zip/rar/7z/gz/bz2)
gotodir nombre # cd al primer directorio que matchee un fragmento de nombre
quickvenv      # crear y activar un .venv local
updateall      # update_system (paquetes del SO) + pip + plugins de nvim
```

## Temas

La terminal tiene selector de temas. Un solo comando cambia a la vez **Ghostty, el prompt de Starship, fzf, tmux, fastfetch y Neovim**. Estética minimal: sin dibujos, emojis ni frases; fastfetch solo muestra la información:

```bash
theme                    # selector con fzf y vista previa de cada paleta
theme paper-latte        # aplicar un tema directamente
theme list               # ver todos (★ = el actual)
theme preview mono-ink
theme random             # sorpresa
theme reset              # volver a neon-fuchsia
```

| Tema | Vibe |
|---|---|
| `neon-fuchsia` | Cyber neón: fucsia, rosa y cian (el de la marca, por defecto) |
| `mono-ink` | Minimalista: grises de tinta con un único acento rojo |
| `soft-concrete` | Minimal soft: piedra, topo, óxido suave y gris azulado |
| `high-contrast` | Máxima legibilidad: negro puro, blanco y primarios intensos |
| `paper-latte` | **Claro**: papel crema, terracota y mostaza (para el día) |

### Galería

<table>
<tr><td align="center"><img src="docs/themes/neon-fuchsia.png" width="420" alt="neon-fuchsia"><br><code>neon-fuchsia</code></td><td align="center"><img src="docs/themes/mono-ink.png" width="420" alt="mono-ink"><br><code>mono-ink</code></td></tr>
<tr><td align="center"><img src="docs/themes/soft-concrete.png" width="420" alt="soft-concrete"><br><code>soft-concrete</code></td><td align="center"><img src="docs/themes/high-contrast.png" width="420" alt="high-contrast"><br><code>high-contrast</code></td></tr>
<tr><td align="center"><img src="docs/themes/paper-latte.png" width="420" alt="paper-latte"><br><code>paper-latte</code></td><td></td></tr>
</table>

La terminal actual cambia al momento; en el resto de pestañas de Ghostty pulsa `Cmd+Shift+,` y Neovim lo coge al reabrirlo. La elección se guarda en `~/.local/state/theme/` (fuera del repo).

**Crear un tema nuevo:** copia cualquier `config/.config/themes/*.theme`, cambia los colores y ya aparece en `theme list`. Para uno claro, añade `THEME_MODE="light"` y `bright="<color de texto más oscuro>"` (mira `paper-latte`). Para su imagen de la galería: `python3 docs/themes/gen-previews.py`.

## Tests

```bash
cd ~/.dotfiles
make test
```

## Estructura

```text
~/.dotfiles/
├── runcom/   # .zshrc, .zprofile
├── config/   # zsh/, nvim/, tmux/, ghostty/, git/
├── install/  # Brewfile
├── macos/    # bootstrap-macos.sh
├── bin/      # utilidades genéricas (tmux-popup, tmux-sessionizer)
├── test/
├── docs/
└── Makefile
```

Gestionado con GNU Stow.

## Licencia

MIT
