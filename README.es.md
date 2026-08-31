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

El pipeline de bug bounty / pentesting (scripts de recon, containers, plantilla de workspace de hunting) vivía antes en este repo. Se ha migrado, con todo su historial de commits, a [theoffsecgirl/bugbounty-toolkit](https://github.com/theoffsecgirl/bugbounty-toolkit) — un repo separado y privado. Este repo ya no lo contiene ni depende de él.

## Instalación

```bash
git clone git@github.com:theoffsecgirl/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
make install
exec zsh
```

`make install` ejecuta `stow -t $HOME runcom config bin` y `brew bundle --file=install/Brewfile`.

Para simular los cambios de Stow sin aplicarlos:

```bash
stow -n -v -t "$HOME" runcom config bin
```

En una Mac nueva, `make macos` instala Homebrew por sí mismo y luego delega en `make install`:

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
make clean    # elimina los symlinks creados por stow
make edit     # abre el repo en $EDITOR
```

## Comandos útiles

```bash
dotfiles-ref   # cheatsheet interactivo de este setup de dotfiles
tmux-popup     # terminal flotante en tmux (popup)
tmux-sessionizer  # selector rápido de proyectos/sesiones con fzf
```

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
